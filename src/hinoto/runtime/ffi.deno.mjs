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
  RequestBody,
  EmptyBody
} from "../body.mjs";
import { Text, Binary, Close, Ping, Pong } from "../websocket.mjs";

/**
 * Converts a Deno Request to a Gleam HTTP Request
 * @param {Request} req - The Deno Request object
 * @returns {Promise<Object>} Gleam HTTP Request object
 *
 * Note: Body is passed as-is (lazy evaluation). Use read_text(), read_json(), etc. to read it.
 * Keeping the original Request also lets `upgrade_websocket` reach it.
 */
export async function toGleamRequest(req) {
  const url = new URL(req.url);

  // Optimization: Pass Request object wrapped in RequestBody for lazy body reading
  const body = new RequestBody(req);

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
 * Converts a Gleam HTTP Response to a Deno Response
 * @param {Object} resp - The Gleam HTTP Response object
 * @returns {Response} Deno Response object
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
  if (body instanceof RequestBody) {
    console.warn("RequestBody should not be used in Response. Returning null.");
    return null;
  }
  console.warn(`Unknown body type: ${body.constructor.name}. Returning null.`);
  return null;
}

export function toDenoResponse(resp) {
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
  return new Text(String(event.data));
}

export function upgradeWebSocket(req, handler, initial_state, ctx) {
  const { socket, response } = Deno.upgradeWebSocket(req);

  let state = initial_state;
  const wrapped = wrapWebSocket(socket);

  socket.addEventListener("open", () => {
    Promise.resolve(handler.on_open(wrapped, state, ctx))
      .then(new_state => { state = new_state; })
      .catch(err => console.error("WebSocket on_open error:", err));
  });

  socket.addEventListener("message", event => {
    const message = toWebSocketMessage(event);
    Promise.resolve(handler.on_message(wrapped, state, ctx, message))
      .then(new_state => { state = new_state; })
      .catch(err => console.error("WebSocket on_message error:", err));
  });

  socket.addEventListener("close", () => {
    Promise.resolve(handler.on_close(wrapped, state, ctx))
      .catch(err => console.error("WebSocket on_close error:", err));
  });

  socket.addEventListener("error", event => {
    console.error("WebSocket error:", event);
    Promise.resolve(handler.on_close(wrapped, state, ctx))
      .catch(err => console.error("WebSocket on_close error:", err));
  });

  return response;
}

export function serve(fetch, port, hostname) {
  Deno.serve(
    { port: port, hostname: hostname },
    fetch,
  );
}
