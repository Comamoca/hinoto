import { serve as hono_serve } from "@hono/node-server";
import { List } from "../../../prelude.mjs";

/**
 * Converts a Node.js/Hono Request to a Gleam HTTP Request
 * @param {Request} req - The Request object
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
    query: url.search ? url.search.substring(1) : null,
  };
}

/**
 * Converts a Gleam HTTP Response to a Node.js Response
 * @param {Object} resp - The Gleam HTTP Response object
 * @returns {Promise<Response>} Node.js Response object
 */
export function toNodeResponse(resp) {
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

export function serve(fetch, port, callback) {
  try {
    const server = hono_serve({ fetch, port }, callback);

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
