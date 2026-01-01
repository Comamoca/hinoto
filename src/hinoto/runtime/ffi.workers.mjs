/**
 * FFI functions for Cloudflare Workers runtime
 */

import { List } from "../../../prelude.mjs";
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
  EmptyBody
} from "../body.mjs";

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
    method: req.method.toUpperCase(),
    headers: headers,
    body: body,
    scheme: url.protocol.replace(':', ''),
    host: url.hostname,
    port: url.port ? parseInt(url.port) : (url.protocol === 'https:' ? 443 : 80),
    path: url.pathname,
    query: url.search ? url.search.substring(1) : undefined,
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
