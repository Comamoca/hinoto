import { serve as hono_serve } from "@hono/node-server";
import { STATUS_CODES } from "node:http";
import { WebSocketServer } from "ws";
import { List, Ok } from "../../../prelude.mjs";
import { Some, None } from "../../../gleam_stdlib/gleam/option.mjs";
import {
  parse_method,
  Get,
  Post,
  Put,
  Delete,
  Head,
  Options,
  Patch,
  Trace,
  Connect,
  Other,
} from "../../../gleam_http/gleam/http.mjs";
import {
  StringBody,
  BitArrayBody,
  BlobBody,
  ArrayBufferBody,
  TypedArrayBody,
  DataViewBody,
  FormDataBody,
  ReadableStreamBody,
  URLSearchParamsBody,
  EmptyBody,
  WebSocketBody,
} from "../body.mjs";
import { Text, Binary, Close, Ping, Pong } from "../websocket.mjs";

/**
 * Checks if the request body should be read based on HTTP method
 * @param {string} method - HTTP method
 * @returns {boolean} true if body should be read
 */
function shouldReadBody(method) {
  const m = method.toUpperCase();
  // Don't read body for methods that typically don't have one
  return !['GET', 'HEAD', 'OPTIONS', 'TRACE'].includes(m);
}

/**
 * Converts a Node.js request to a Gleam HTTP request
 * @param {Request} req - The Request object
 * @returns {Promise<Object>} Gleam HTTP Request object
 */
export async function toGleamRequest(req) {
  const url = new URL(req.url);

  // Optimization: Skip body reading for GET/HEAD/OPTIONS/TRACE requests
  const rawBody = shouldReadBody(req.method) ? await req.text() : "";
  const body = new StringBody(rawBody);

  // Optimization: Use spread operator for more efficient header conversion
  const headers = List.fromArray([...req.headers]);

  return {
    method: (() => {
      const result = parse_method(req.method.toUpperCase());
      return result instanceof Ok ? result[0] : new Other(req.method.toUpperCase());
    })(),
    headers: headers,
    body: body,
    scheme: url.protocol.replace(':', ''),
    host: url.hostname,
    port: url.port ? parseInt(url.port) : (url.protocol === 'https:' ? 443 : 80),
    path: url.pathname,
    query: url.search ? new Some(url.search.substring(1)) : new None(),
  };
}

/**
 * Converts Body type to JavaScript Response body
 * @param {Body} body - The Gleam Body type
 * @returns {BodyInit | null} JavaScript Response body
 */
function convertBodyToJS(body) {
  if (body instanceof StringBody) {
    return body[0];
  }
  if (body instanceof BitArrayBody) {
    return body[0].buffer;
  }
  if (body instanceof BlobBody) {
    return body[0];
  }
  if (body instanceof ArrayBufferBody) {
    return body[0];
  }
  if (body instanceof TypedArrayBody) {
    return body[0];
  }
  if (body instanceof DataViewBody) {
    return body[0];
  }
  if (body instanceof FormDataBody) {
    return body[0];
  }
  if (body instanceof ReadableStreamBody) {
    return body[0];
  }
  if (body instanceof URLSearchParamsBody) {
    return body[0];
  }
  if (body instanceof EmptyBody) {
    return null;
  }
  if (body instanceof WebSocketBody) {
    return body[0];
  }

  // Unknown body type: return null
  console.warn(`Unknown body type: ${body.constructor.name}. Returning null.`);
  return null;
}

/**
 * Converts a Gleam HTTP Response to a Node.js Response
 * @param {Object} resp - The Gleam HTTP Response object
 * @returns {Response} Node.js Response object
 */
export function toNodeResponse(resp) {
  // WebSocket handshake responses are pre-built by the runtime FFI.
  if (resp.body instanceof WebSocketBody) {
    return resp.body[0];
  }

  const headers = new Headers();

  // Optimization: Use for...of instead of forEach for better performance
  if (resp.headers && resp.headers.toArray) {
    const headersList = resp.headers.toArray();
    for (const [key, value] of headersList) {
      headers.set(key, value);
    }
  }

  const body = convertBodyToJS(resp.body);

  // Optimization: Return Response directly (no need for Promise.resolve)
  return new Response(body, {
    status: resp.status,
    headers: headers,
  });
}

/**
 * Creates a Request-like object from a Node.js IncomingMessage for upgrade events.
 */
function createUpgradeRequest(request) {
  const protocol = request.socket?.encrypted ? 'https' : 'http';
  const url = new URL(request.url ?? '/', `${protocol}://${request.headers.host ?? 'localhost'}`);
  const headers = new Headers();
  for (const key in request.headers) {
    const value = request.headers[key];
    if (!value) {
      continue;
    }
    headers.append(key, Array.isArray(value) ? value[0] : value);
  }
  return new Request(url, { headers });
}

/**
 * Rejects a WebSocket upgrade request with the given status.
 */
function rejectUpgrade(socket, status, responseHeaders) {
  const responseLines = ['Connection: close', 'Content-Length: 0'];
  if (responseHeaders) {
    responseHeaders.forEach((value, key) => {
      const lower = key.toLowerCase();
      if (
        lower !== 'connection' &&
        lower !== 'content-length' &&
        lower !== 'keep-alive' &&
        lower !== 'upgrade'
      ) {
        responseLines.push(`${key}: ${value}`);
      }
    });
  }

  socket.end(
    `HTTP/1.1 ${status.toString()} ${STATUS_CODES[status] ?? ''}\r\n` +
      `${responseLines.join('\r\n')}\r\n` +
      '\r\n'
  );
}

/**
 * Wraps a raw JavaScript WebSocket into the Hinoto WebSocket wrapper.
 */
function wrapWebSocket(socket) {
  return { inner: socket };
}

/**
 * Converts a JavaScript MessageEvent into a Hinoto WebSocketMessage variant.
 */
function toWebSocketMessage(event) {
  if (typeof event.data === "string") {
    return new Text(event.data);
  }
  if (event.data instanceof ArrayBuffer) {
    return new Binary(new Uint8Array(event.data));
  }
  if (ArrayBuffer.isView(event.data)) {
    return new Binary(new Uint8Array(event.data.buffer));
  }
  // Fallback: stringify unknown data.
  return new Text(String(event.data));
}

/**
 * Upgrades a Node.js request to a WebSocket.
 *
 * @param {Request} req - The Hinoto-facing Request object
 * @param {Object} hinoto - The Hinoto instance containing the Node env
 * @param {Object} handler - Gleam WebSocketHandler record
 * @param {*} initial_state - Initial handler state
 * @returns {Response} 101 Switching Protocols Response
 */
export function doUpgradeWebSocket(req, hinoto, handler, initial_state) {
  const env = hinoto.context;
  const incoming = env.incoming;
  const socket = incoming?._hinoto_socket;
  const head = incoming?._hinoto_head;
  const wss = incoming?._hinoto_wss;

  if (!incoming || !socket || !head || !wss) {
    return new Response(null, { status: 400 });
  }

  let state = initial_state;

  wss.handleUpgrade(incoming, socket, head, (ws) => {
    const wrapped = wrapWebSocket(ws);

    ws.on("open", () => {
      Promise.resolve(handler.on_open(wrapped, state, env))
        .then(new_state => { state = new_state; })
        .catch(err => console.error("WebSocket on_open error:", err));
    });

    ws.on("message", (data, isBinary) => {
      const wrapped = wrapWebSocket(ws);
      let message;
      if (isBinary) {
        message = new Binary(new Uint8Array(data.buffer, data.byteOffset, data.byteLength));
      } else if (typeof data === "string") {
        message = new Text(data);
      } else {
        message = new Text(String(data));
      }
      Promise.resolve(handler.on_message(wrapped, state, env, message))
        .then(new_state => { state = new_state; })
        .catch(err => console.error("WebSocket on_message error:", err));
    });

    ws.on("close", () => {
      const wrapped = wrapWebSocket(ws);
      Promise.resolve(handler.on_close(wrapped, state, env))
        .catch(err => console.error("WebSocket on_close error:", err));
    });

    ws.on("error", (error) => {
      console.error("WebSocket error:", error);
      const wrapped = wrapWebSocket(ws);
      Promise.resolve(handler.on_close(wrapped, state, env))
        .catch(err => console.error("WebSocket on_close error:", err));
    });
  });

  return new Response(null, { status: 101 });
}

export function serve(fetch, port, callback) {
  try {
    const server = hono_serve({ fetch, port }, callback);
    const wss = new WebSocketServer({ noServer: true });

    server.on("upgrade", async (request, socket, head) => {
      if (request.headers.upgrade?.toLowerCase() !== 'websocket') {
        return;
      }

      // Attach socket and head so the Hinoto handler can perform the upgrade.
      request._hinoto_socket = socket;
      request._hinoto_head = head;
      request._hinoto_wss = wss;

      let response;
      try {
        response = await fetch(createUpgradeRequest(request), { incoming: request });
      } catch (err) {
        console.error("WebSocket upgrade handler error:", err);
        rejectUpgrade(socket, 500);
        return;
      }

      if (response.status !== 101) {
        rejectUpgrade(socket, response.status, response.headers);
      }
    });

    // Handle server errors properly
    server.on("error", (err) => {
      if (err.code === "EADDRINUSE") {
        console.error(
          `Error: Port ${port} is already in use. Please try a different port or stop the process using port ${port}.`,
        );
        process.exit(1);
      } else {
        console.error("Server error:", err);
        process.exit(1);
      }
    });

    return server;
  } catch (err) {
    console.error("Failed to start server:", err);
    process.exit(1);
  }
}
