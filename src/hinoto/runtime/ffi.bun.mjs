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
  WebSocketBody,
  StringBody,
  BitArrayBody,
  BlobBody,
  ArrayBufferBody,
  TypedArrayBody,
  DataViewBody,
  FormDataBody,
  ReadableStreamBody,
  URLSearchParamsBody,
  EmptyBody
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
 * Converts a Bun Request to a Gleam HTTP Request
 * @param {Request} req - The Bun Request object
 * @returns {Promise<Object>} Gleam HTTP Request object
 */
export async function toGleamRequest(req) {
  const url = new URL(req.url);

  // Optimization: Skip body reading for GET/HEAD/OPTIONS/TRACE requests
  const body = shouldReadBody(req.method) ? await req.text() : "";

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
 * Converts a Gleam HTTP Response to a Bun Response
 * @param {Object} resp - The Gleam HTTP Response object
 * @returns {Response} Bun Response object
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
  console.warn(`Unknown body type: ${body.constructor.name}. Returning null.`);
  return null;
}

export function toBunResponse(resp) {
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

function wrapWebSocket(socket) {
  return { inner: socket };
}

function toWebSocketMessage(message) {
  if (typeof message === "string") {
    return new Text(message);
  }
  if (message instanceof ArrayBuffer) {
    return new Binary(new Uint8Array(message));
  }
  if (ArrayBuffer.isView(message)) {
    return new Binary(new Uint8Array(message.buffer));
  }
  // Fallback for Bun Buffer or other types.
  return new Text(String(message));
}

export function websocketHandler(handler) {
  return {
    open(ws) {
      Promise.resolve(handler.on_open(wrapWebSocket(ws), ws.data, undefined))
        .then(new_state => { ws.data = new_state; })
        .catch(err => console.error("WebSocket on_open error:", err));
    },
    message(ws, message) {
      const msg = toWebSocketMessage(message);
      Promise.resolve(handler.on_message(wrapWebSocket(ws), ws.data, undefined, msg))
        .then(new_state => { ws.data = new_state; })
        .catch(err => console.error("WebSocket on_message error:", err));
    },
    close(ws, code, message) {
      Promise.resolve(handler.on_close(wrapWebSocket(ws), ws.data, undefined))
        .catch(err => console.error("WebSocket on_close error:", err));
    },
    error(ws, error) {
      console.error("WebSocket error:", error);
      Promise.resolve(handler.on_close(wrapWebSocket(ws), ws.data, undefined))
        .catch(err => console.error("WebSocket on_close error:", err));
    },
  };
}

export function upgradeWebSocket(server, req, initial_state) {
  const success = server.upgrade(req, { data: initial_state });
  if (success) {
    return undefined;
  }
  return new Response("WebSocket upgrade failed", { status: 400 });
}

export function serve(fetch, websocket, port, hostname) {
  const server = Bun.serve({
    port: port,
    hostname: hostname,
    fetch,
    websocket,
  });
  console.log(`Listening on http://localhost:${server.port}`);
}
