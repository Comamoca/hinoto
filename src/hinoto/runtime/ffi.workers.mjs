/**
 * FFI functions for Cloudflare Workers runtime
 */

import { List } from "../../../prelude.mjs";

/**
 * Converts a Cloudflare Workers Request to a Gleam HTTP Request
 * @param {Request} req - The Cloudflare Workers Request object
 * @returns {Promise<Object>} Gleam HTTP Request object
 */
export async function toGleamRequest(req) {
  const url = new URL(req.url);
  const body = await req.text();

  // Convert headers to Gleam List using List.fromArray
  const headersArray = Array.from(req.headers.entries());
  const headers = List.fromArray(headersArray);

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
 * Converts a Gleam HTTP Response to a Cloudflare Workers Response
 * @param {Object} resp - The Gleam HTTP Response object
 * @returns {Promise<Response>} Cloudflare Workers Response object
 */
export function toWorkersResponse(resp) {
  const headers = new Headers();

  // Convert Gleam List to JavaScript array using toArray()
  if (resp.headers && resp.headers.toArray) {
    const headersList = resp.headers.toArray();
    headersList.forEach(([key, value]) => {
      headers.set(key, value);
    });
  }

  return Promise.resolve(new Response(resp.body, {
    status: resp.status,
    headers: headers,
  }));
}
