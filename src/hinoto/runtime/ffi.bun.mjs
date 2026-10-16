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
 * Converts a Bun Request to a Gleam HTTP Request
 * @param {Request} req - The Bun Request object
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
  if (body instanceof RequestBody) {
    console.warn("RequestBody should not be used in Response. Returning null.");
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

/**
 * Bun requires the `websocket` handler to be registered on `Bun.serve`, before
 * any request is routed. To keep `upgrade_websocket` looking like the other
 * runtimes, we register one generic dispatcher and carry the per-connection
 * Hinoto handler in `ws.data` instead. As a side effect each route may use its
 * own handler, which a single server-wide handler could not do.
 */
const dispatcher = {
  open(ws) {
    runCallback(ws, (handler, state) =>
      handler.on_open(wrapWebSocket(ws), state, undefined),
    );
  },
  message(ws, message) {
    const msg = toWebSocketMessage(message);
    runCallback(ws, (handler, state) =>
      handler.on_message(wrapWebSocket(ws), state, undefined, msg),
    );
  },
  close(ws) {
    const { handler, state } = ws.data;
    Promise.resolve(handler.on_close(wrapWebSocket(ws), state, undefined))
      .catch(err => console.error("WebSocket on_close error:", err));
  },
  error(ws, error) {
    console.error("WebSocket error:", error);
    const { handler, state } = ws.data;
    Promise.resolve(handler.on_close(wrapWebSocket(ws), state, undefined))
      .catch(err => console.error("WebSocket on_close error:", err));
  },
};

/**
 * Runs a state-returning handler callback, serialising it after any callback
 * still in flight so that rapid messages cannot drop a state update.
 */
function runCallback(ws, call) {
  const data = ws.data;
  data.queue = Promise.resolve(data.queue)
    .then(() => call(data.handler, data.state))
    .then(new_state => { data.state = new_state; })
    .catch(err => console.error("WebSocket handler error:", err));
}

/**
 * Remembers the Bun server on the Request so that `upgrade_websocket` can find
 * it without the caller having to thread it through.
 */
export function attachServer(req, server) {
  req._hinoto_server = server;
  return req;
}

export function upgradeWebSocket(req, handler, initial_state) {
  const server = req._hinoto_server;
  if (!server) {
    console.error("WebSocket upgrade attempted without a Bun server binding.");
    return new Response("WebSocket upgrade failed", { status: 400 });
  }

  const success = server.upgrade(req, {
    data: { handler, state: initial_state, queue: Promise.resolve() },
  });
  if (success) {
    // Bun treats a missing response from `fetch` as a completed upgrade.
    return undefined;
  }
  return new Response("WebSocket upgrade failed", { status: 400 });
}

export function serve(fetch, port, hostname) {
  const server = Bun.serve({
    port: port,
    hostname: hostname,
    fetch,
    websocket: dispatcher,
  });
  console.log(`Listening on http://localhost:${server.port}`);
}
