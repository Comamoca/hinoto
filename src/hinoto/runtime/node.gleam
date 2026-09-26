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
import gleam/javascript/promise.{type Promise}

@target(javascript)
import gleam/option.{type Option, None, Some}

@target(javascript)
import hinoto.{type Hinoto, type JsRequest, type JsResponse}

@target(javascript)
import hinoto/body.{type Body}

@target(javascript)
import hinoto/websocket.{type WebSocketHandler}

@target(javascript)
/// Default port used when none is specified
const default_port = 3000

@target(javascript)
/// Type representing the Node.js runtime environment passed through Hinoto's
/// context. It carries the underlying Node.js request bindings needed for
/// WebSocket upgrades.
pub type NodeEnv

@target(javascript)
/// Empty context type alias kept for backward-compatible naming.
pub type NodeContext = Nil

@target(javascript)
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
pub fn to_gleam_request(req: JsRequest) -> Promise(Request(Body))

@target(javascript)
/// Converts a Gleam HTTP response to a Node.js response
/// Note: Returns JsResponse directly for better performance (no unnecessary Promise wrapping)
@external(javascript, "./ffi.node.mjs", "toNodeResponse")
pub fn to_node_response(resp: Response(Body)) -> JsResponse

@target(javascript)
/// External FFI function that performs the actual WebSocket upgrade.
/// Returns the raw JavaScript Response object.
@external(javascript, "./ffi.node.mjs", "doUpgradeWebSocket")
fn do_upgrade_websocket(
  req: JsRequest,
  hinoto: Hinoto(NodeEnv, Body),
  handler: WebSocketHandler(state, NodeEnv),
  initial_state: state,
) -> JsResponse

@target(javascript)
/// Upgrades the current request to a WebSocket in Node.js.
///
/// This function must be called from within a handler that received the
/// raw `JsRequest` as its first argument. The Hinoto instance must carry
/// a `NodeEnv` context provided by `node.handler`.
pub fn upgrade_websocket(
  req: JsRequest,
  hinoto: Hinoto(NodeEnv, Body),
  handler: WebSocketHandler(state, NodeEnv),
  initial_state: state,
) -> Promise(Hinoto(NodeEnv, Body)) {
  let js_response = do_upgrade_websocket(req, hinoto, handler, initial_state)

  promise.resolve(
    hinoto.Hinoto(
      request: hinoto.request,
      response: response.new(101)
        |> response.set_body(body.WebSocketBody(js_response)),
      context: hinoto.context,
    )
  )
}

@target(javascript)
/// External FFI function that interfaces with Node.js HTTP server
@external(javascript, "./ffi.node.mjs", "serve")
fn hono_serve(
  fetch: fn(JsRequest, NodeEnv) -> Promise(JsResponse),
  port: Int,
  callback: fn(Info) -> Nil,
) -> Nil

@target(javascript)
/// Creates a handler for Node.js server with Hinoto
///
/// This function wraps your application handler to work with Node.js HTTP server.
/// The handler receives both the raw `JsRequest` and the Hinoto instance, which
/// is required for WebSocket upgrades.
///
/// ## Example (Promise-based handler)
/// ```gleam
/// import hinoto
/// import hinoto/runtime/node
/// import gleam/http/response
/// import gleam/javascript/promise
///
/// pub fn main() {
///   let handler = node.handler(fn(req, hinoto_instance) {
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
  app_handler: fn(JsRequest, Hinoto(NodeEnv, Body)) -> Promise(Hinoto(NodeEnv, Body)),
) -> fn(JsRequest, NodeEnv) -> Promise(JsResponse) {
  fn(req: JsRequest, env: NodeEnv) {
    use gleam_request <- promise.await(to_gleam_request(req))

    let hinoto_instance =
      hinoto.Hinoto(
        request: gleam_request,
        response: body.default_response_body(),
        context: env,
      )

    use updated_hinoto <- promise.await(app_handler(req, hinoto_instance))
    // Optimization: Wrap in promise.resolve only when needed for return type
    promise.resolve(to_node_response(updated_hinoto.response))
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
  fetch: fn(JsRequest, NodeEnv) -> Promise(JsResponse),
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
