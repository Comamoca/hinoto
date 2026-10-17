/**
 * FFI functions for Cloudflare Workers runtime
 */

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
  RequestBody,
  StringBody,
  BitArrayBody,
  BlobBody,
  ArrayBufferBody,
  TypedArrayBody,
  DataViewBody,
  FormDataBody,
  ReadableStreamBody,
  URLSearchParamsBody,
  WebSocketBody,
  EmptyBody
} from "../body.mjs";
import { Text, Binary, Close, Ping, Pong } from "../websocket.mjs";

/**
 * Converts a Cloudflare Workers Request to a Gleam HTTP Request
 * @param {Request} req - The Cloudflare Workers Request object
 * @returns {Object} Gleam HTTP Request object
 *
 * Note: Body is passed as-is (lazy evaluation). Use read_text(), read_json(), etc. to read it.
 */
export function toGleamRequest(req) {
  const url = new URL(req.url);

  // Optimization: Pass Request object wrapped in RequestBody for lazy body reading
  // Body will be read only when explicitly requested via read_text(), read_json(), etc.
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
 * Converts Body type to JavaScript Response body
 * @param {Body} body - The Gleam Body type
 * @returns {BodyInit | null} JavaScript Response body
 */
function convertBodyToJS(body) {
  // StringBody: return string directly
  if (body instanceof StringBody) {
    return body[0];
  }

  // BitArrayBody: convert BitArray to Uint8Array
  if (body instanceof BitArrayBody) {
    return body[0].buffer;
  }

  // BlobBody: return Blob directly
  if (body instanceof BlobBody) {
    return body[0];
  }

  // ArrayBufferBody: return ArrayBuffer directly
  if (body instanceof ArrayBufferBody) {
    return body[0];
  }

  // TypedArrayBody: return TypedArray directly
  if (body instanceof TypedArrayBody) {
    return body[0];
  }

  // DataViewBody: return DataView directly
  if (body instanceof DataViewBody) {
    return body[0];
  }

  // FormDataBody: return FormData directly
  if (body instanceof FormDataBody) {
    return body[0];
  }

  // ReadableStreamBody: return ReadableStream directly
  if (body instanceof ReadableStreamBody) {
    return body[0];
  }

  // URLSearchParamsBody: return URLSearchParams directly
  if (body instanceof URLSearchParamsBody) {
    return body[0];
  }

  // EmptyBody: return null
  if (body instanceof EmptyBody) {
    return null;
  }

  // WebSocketBody: return the pre-built Response object directly
  if (body instanceof WebSocketBody) {
    return body[0];
  }

  // RequestBody: should not be used in Response, but if it is, return null
  if (body instanceof RequestBody) {
    console.warn("RequestBody should not be used in Response. Returning null.");
    return null;
  }

  // Unknown body type: return null
  console.warn(`Unknown body type: ${body.constructor.name}. Returning null.`);
  return null;
}

/**
 * Converts a Gleam HTTP Response to a Cloudflare Workers Response
 * @param {Object} resp - The Gleam HTTP Response object
 * @returns {Response} Cloudflare Workers Response object
 */
export function toWorkersResponse(resp) {
  // WebSocket handshake responses are pre-built by the runtime FFI.
  // Return them directly without wrapping in a new Response.
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

  // Convert Body type to JavaScript Response body
  const body = convertBodyToJS(resp.body);

  // Optimization: Return Response directly (no need for Promise.resolve)
  return new Response(body, {
    status: resp.status,
    headers: headers,
  });
}

/**
 * Wraps a raw JavaScript WebSocket into the Hinoto WebSocket wrapper.
 */
function wrapWebSocket(socket) {
  return { inner: socket };
}

/**
 * Converts a JavaScript MessageEvent into a Hinot WebSocketMessage variant.
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
 * Upgrades a Cloudflare Workers request to a WebSocket.
 *
 * @param {Request} req - The incoming Request object
 * @param {Object} handler - Gleam WebSocketHandler record
 * @param {*} initial_state - Initial handler state
 * @param {*} ctx - Cloudflare Workers execution context
 * @returns {Response} 101 Switching Protocols Response
 */
export function upgradeWebSocket(req, handler, initial_state, ctx) {
  const pair = new WebSocketPair();
  const client = pair[0];
  const server = pair[1];

  server.accept();

  let state = initial_state;
  const socket = wrapWebSocket(server);

  server.addEventListener("open", () => {
    Promise.resolve(handler.on_open(socket, state, ctx))
      .then(new_state => { state = new_state; })
      .catch(err => console.error("WebSocket on_open error:", err));
  });

  server.addEventListener("message", event => {
    const message = toWebSocketMessage(event);
    Promise.resolve(handler.on_message(socket, state, ctx, message))
      .then(new_state => { state = new_state; })
      .catch(err => console.error("WebSocket on_message error:", err));
  });

  server.addEventListener("close", () => {
    Promise.resolve(handler.on_close(socket, state, ctx))
      .catch(err => console.error("WebSocket on_close error:", err));
  });

  server.addEventListener("error", event => {
    console.error("WebSocket error:", event);
    Promise.resolve(handler.on_close(socket, state, ctx))
      .catch(err => console.error("WebSocket on_close error:", err));
  });

  return new Response(null, { status: 101, webSocket: client });
}
