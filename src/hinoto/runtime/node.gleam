////
//// Runtime module for Node.js
////
//// This module provides utilities for running Hinoto applications in the Node.js runtime.
//// It handles the setup and configuration of HTTP servers specifically for Node.js,
//// utilizing the Hono.js Node.js adapter.
////

@target(javascript)
import gleam/http/request.{type Request}

@target(javascript)
import gleam/http/response.{type Response}

@target(javascript)
import gleam/int

@target(javascript)
import gleam/io

@target(javascript)
import gleam/javascript/promise.{type Promise, await as promise_await}

@target(javascript)
import gleam/option.{None, Some}

@target(javascript)
import hinoto.{type Hinoto, type JsRequest, type JsResponse}

@target(javascript)
/// Default port used when none is specified
const default_port = 3000

/// Server address information provided by Node.js when the server starts
///
/// This type contains information about the address the server is bound to,
/// including the IP address, address family, and port number.
pub type Info {
  Info(address: String, family: String, port: Int)
}

@target(javascript)
/// Converts a Node.js request to a Gleam HTTP request
@external(javascript, "./ffi.node.mjs", "toGleamRequest")
pub fn to_gleam_request(req: JsRequest) -> Promise(Request(String))

@target(javascript)
/// Converts a Gleam HTTP response to a Node.js response
@external(javascript, "./ffi.node.mjs", "toNodeResponse")
pub fn to_node_response(resp: Response(String)) -> Promise(JsResponse)

@target(javascript)
/// External FFI function that interfaces with Node.js HTTP server via Hono.js adapter
@external(javascript, "./ffi.node.mjs", "serve")
fn hono_serve(
  fetch: fn(JsRequest) -> Promise(JsResponse),
  port: Int,
  callback: fn(Info) -> Nil,
) -> Nil

@target(javascript)
/// Creates a handler for Node.js server with Hinoto
///
/// This function wraps your application handler to work with Node.js HTTP server.
/// The handler uses Promise-based async operations for handling requests.
///
/// **Important**: In JavaScript targets, the `hinoto.handle` function returns a
/// `Promise(Hinoto)`, so you must use `promise.await` to handle the result.
///
/// ## Parameters
/// - `app_handler`: Your application handler that processes Hinoto instances and
///   returns a Promise of the updated instance
///
/// ## Returns
/// A Promise-based function that can be used with `start_server`
///
/// ## Example (Promise-based handler)
/// ```gleam
/// import hinoto
/// import hinoto/runtime/node
/// import gleam/http/response
/// import gleam/javascript/promise
///
/// pub fn main() {
///   let handler = node.handler(fn(hinoto_instance) {
///     use updated_hinoto <- promise.await(
///       hinoto_instance
///       |> hinoto.handle(fn(_req) {
///         promise.resolve(
///           response.new(200)
///           |> response.set_body("Hello from Node.js!")
///         )
///       })
///     )
///     promise.resolve(updated_hinoto)
///   })
///   node.start_server(handler, None, None)
/// }
/// ```
pub fn handler(
  app_handler: fn(Hinoto(Nil, String)) -> Promise(Hinoto(Nil, String)),
) -> fn(JsRequest) -> Promise(JsResponse) {
  fn(req: JsRequest) {
    use gleam_request <- promise.await(to_gleam_request(req))

    let hinoto_instance =
      hinoto.Hinoto(
        request: gleam_request,
        response: hinoto.default_response(),
        context: Nil,
      )

    use updated_hinoto <- promise.await(app_handler(hinoto_instance))
    to_node_response(updated_hinoto.response)
  }
}

@target(javascript)
/// Starts an HTTP server using Node.js runtime
///
/// This function provides a convenient interface to start a server with optional
/// port and callback configuration. If values are not provided, defaults will be used.
/// The callback function is called when the server successfully starts listening.
///
/// ## Parameters
///
/// - `fetch`: A function that handles incoming HTTP requests and returns a Promise of JsResponse
/// - `port`: Optional port number to listen on (defaults to 3000)
/// - `callback`: Optional callback function called when server starts (defaults to logging the URL)
///
/// ## Examples
///
/// ```gleam
/// import hinoto/runtime/node
/// import gleam/option.{Some, None}
/// import gleam/io
///
/// // Start server with default settings
/// node.start_server(my_fetch_handler, None, None)
///
/// // Start server on specific port
/// node.start_server(my_fetch_handler, Some(8080), None)
///
/// // Start server with custom callback
/// let custom_callback = fn(info) {
///   io.println("Server running on port " <> int.to_string(info.port))
/// }
/// node.start_server(my_fetch_handler, Some(8080), Some(custom_callback))
/// ```
///
pub fn start_server(
  fetch: fn(JsRequest) -> Promise(JsResponse),
  port: Option(Int),
  callback: Option(fn(Info) -> Nil),
) {
  case port, callback {
    Some(port), None -> hono_serve(fetch, port, default_callback)
    None, Some(callback) -> hono_serve(fetch, default_port, callback)
    Some(port), Some(callback) -> hono_serve(fetch, port, callback)
    None, None -> hono_serve(fetch, default_port, default_callback)
  }
}

@target(javascript)
/// Default callback function used when no custom callback is provided
///
/// This function logs a message indicating the server is listening and provides
/// the localhost URL for easy access during development.
fn default_callback(info: Info) {
  io.println("Listening on http://localhost:" <> int.to_string(info.port))
}
