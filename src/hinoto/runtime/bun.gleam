////
//// Runtime module for Bun
////
//// This module provides utilities for running Hinoto applications in the Bun runtime.
//// It handles the setup and configuration of HTTP servers specifically for Bun.
////

@target(javascript)
import gleam/http/request.{type Request}

@target(javascript)
import gleam/http/response.{type Response}

@target(javascript)
import gleam/javascript/promise.{type Promise, await as promise_await}

@target(javascript)
import gleam/option.{type Option, None, Some}

@target(javascript)
import hinoto.{type Hinoto, type JsRequest, type JsResponse}

@target(javascript)
/// Default hostname used when none is specified
const default_hostname = "0.0.0.0"

@target(javascript)
/// Default port used when none is specified
const default_port = 3000

@target(javascript)
/// Converts a Bun request to a Gleam HTTP request
@external(javascript, "./ffi.bun.mjs", "toGleamRequest")
pub fn to_gleam_request(req: JsRequest) -> Promise(Request(String))

@target(javascript)
/// Converts a Gleam HTTP response to a Bun response
/// Note: Returns JsResponse directly for better performance (no unnecessary Promise wrapping)
@external(javascript, "./ffi.bun.mjs", "toBunResponse")
pub fn to_bun_response(resp: Response(String)) -> JsResponse

@target(javascript)
/// External FFI function that interfaces with Bun's HTTP server
@external(javascript, "./ffi.bun.mjs", "serve")
fn bun_serve(
  fetch: fn(JsRequest) -> Promise(JsResponse),
  port: Int,
  hostname: String,
) -> Nil

@target(javascript)
/// Creates a handler for Bun server with Hinoto
///
/// This function wraps your application handler to work with Bun's HTTP server.
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
/// import hinoto/runtime/bun
/// import gleam/http/response
/// import gleam/javascript/promise
///
/// pub fn main() {
///   let handler = bun.handler(fn(hinoto_instance) {
///     use updated_hinoto <- promise.await(
///       hinoto_instance
///       |> hinoto.handle(fn(_req) {
///         promise.resolve(
///           response.new(200)
///           |> response.set_body("Hello from Bun!")
///         )
///       })
///     )
///     promise.resolve(updated_hinoto)
///   })
///   bun.start_server(handler, None, None)
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
    // Optimization: Wrap in promise.resolve only when needed for return type
    promise.resolve(to_bun_response(updated_hinoto.response))
  }
}

@target(javascript)
/// Starts an HTTP server using Bun's runtime (with handler function)
///
/// This function provides a convenient interface to start a server with optional
/// port and hostname configuration. If values are not provided, defaults will be used.
///
/// ## Parameters
///
/// - `fetch`: A function that handles incoming HTTP requests and returns a Promise of JsResponse
/// - `port`: Optional port number to listen on (defaults to 3000)
/// - `hostname`: Optional hostname to bind to (defaults to "0.0.0.0")
///
/// ## Example
///
/// ```gleam
/// import hinoto/runtime/bun
/// import gleam/option.{None}
///
/// let my_handler = bun.handler(fn(hinoto_instance) {
///   // ... your handler logic
/// })
/// bun.start_server(my_handler, None, None)
/// ```
pub fn start_server(
  fetch: fn(JsRequest) -> Promise(JsResponse),
  port: Option(Int),
  hostname: Option(String),
) {
  case port, hostname {
    Some(port), Some(hostname) -> bun_serve(fetch, port, hostname)
    Some(port), None -> bun_serve(fetch, port, default_hostname)
    None, Some(hostname) -> bun_serve(fetch, default_port, hostname)
    None, None -> bun_serve(fetch, default_port, default_hostname)
  }
}

@target(javascript)
/// Starts an HTTP server using Bun's runtime (low-level)
///
/// This is a low-level function that takes a raw JsRequest handler.
/// For most use cases, prefer using `handler` and `start_server` instead.
///
/// ## Parameters
///
/// - `fetch`: A Promise-based function that handles incoming HTTP requests
/// - `port`: Optional port number to listen on (defaults to 3000)
/// - `hostname`: Optional hostname to bind to (defaults to "0.0.0.0")
///
/// ## Example (Promise-based handler)
///
/// ```gleam
/// import hinoto
/// import hinoto/runtime/bun
/// import gleam/http/response
/// import gleam/javascript/promise
/// import gleam/option.{None}
///
/// pub fn main() {
///   let fetch_handler = fn(req) {
///     promise.resolve(
///       response.new(200)
///       |> response.set_body("Hello from Bun!")
///     )
///   }
///
///   bun.serve(fetch_handler, None, None)
/// }
/// ```
///
pub fn serve(
  fetch: fn(JsRequest) -> Promise(JsResponse),
  port: Option(Int),
  hostname: Option(String),
) {
  start_server(fetch, port, hostname)
}
