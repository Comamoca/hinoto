import { List } from "../../../prelude.mjs";

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
 * Converts a Deno Request to a Gleam HTTP Request
 * @param {Request} req - The Deno Request object
 * @returns {Promise<Object>} Gleam HTTP Request object
 */
export async function toGleamRequest(req) {
  const url = new URL(req.url);

  // Optimization: Skip body reading for GET/HEAD/OPTIONS/TRACE requests
  const body = shouldReadBody(req.method) ? await req.text() : "";

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
 * Converts a Gleam HTTP Response to a Deno Response
 * @param {Object} resp - The Gleam HTTP Response object
 * @returns {Response} Deno Response object
 */
export function toDenoResponse(resp) {
  const headers = new Headers();

  // Optimization: Use for...of instead of forEach for better performance
  if (resp.headers && resp.headers.toArray) {
    const headersList = resp.headers.toArray();
    for (const [key, value] of headersList) {
      headers.set(key, value);
    }
  }

  // Optimization: Return Response directly (no need for Promise.resolve)
  return new Response(resp.body, {
    status: resp.status,
    headers: headers,
  });
}

export function serve(fetch, port, hostname) {
  Deno.serve(
    { port: port, hostname: hostname },
    fetch,
  );
}
