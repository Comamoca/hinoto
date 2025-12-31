////
//// Runtime module for Mist (Erlang HTTP server)
////
//// This module provides utilities for running Hinoto applications with the Mist
//// HTTP server on the Erlang runtime. It handles conversion between Hinoto's
//// Request/Response types and Mist's Connection/ResponseData types.
////

@target(erlang)
import gleam/bytes_tree
@target(erlang)
import gleam/erlang/process
@target(erlang)
import gleam/http/request.{type Request}
@target(erlang)
import gleam/http/response.{type Response}
@target(erlang)
import gleam/option
@target(erlang)
import mist.{type Connection, type ResponseData}

/// Default hostname used when none is specified
const default_hostname = "0.0.0.0"

/// Default port used when none is specified
const default_port = 3000

@target(erlang)
/// The core Hinoto type for Mist runtime (Erlang target only).
///
/// This type encapsulates an HTTP request-response cycle specifically for
/// the Mist HTTP server on the Erlang runtime. It uses Mist's Connection type
/// as the body type.
///
/// ## Fields
/// - `request`: The incoming HTTP request with Connection body
/// - `response`: The HTTP response with Connection body
/// - `context`: The context data (environment, execution context, etc.)
///
/// ## Type Parameters
/// - `context`: The type of context data
///
/// ## Example
/// ```gleam
/// import hinoto/runtime/mist.{type HinotoMist}
/// import gleam/http/response
///
/// pub fn my_handler(hinoto: HinotoMist(Nil)) -> HinotoMist(Nil) {
///   let new_response = response.new(200)
///     |> response.set_body("Hello from Mist!")
///
///   HinotoMist(
///     request: hinoto.request,
///     response: new_response,
///     context: hinoto.context
///   )
/// }
/// ```
pub type HinotoMist(context) {
  HinotoMist(
    request: Request(Connection),
    response: Response(Connection),
    context: context,
  )
}

@target(erlang)
/// Converts a Hinoto Response(String) to a Mist Response(ResponseData)
///
/// This function converts a string-based response to Mist's ResponseData format,
/// wrapping the body in Bytes for transmission.
///
/// ## Parameters
/// - `hinoto_response`: The response from a Hinoto handler
///
/// ## Returns
/// A Response(ResponseData) that Mist can send to the client
@target(erlang)
fn convert_response(hinoto_response: Response(String)) -> Response(ResponseData) {
  let body_data =
    hinoto_response.body
    |> bytes_tree.from_string
    |> mist.Bytes

  response.new(hinoto_response.status)
  |> response.set_body(body_data)
}

/// Creates a Mist handler from a Hinoto-style handler function
///
/// This function takes a handler that works with Request(Connection) and Response(String)
/// and converts it to a Mist-compatible handler that works with Response(ResponseData).
///
/// ## Parameters
/// - `hinoto_handler`: A function that takes Request(Connection) and returns Response(String)
///
/// ## Returns
/// A Mist-compatible handler function
///
/// ## Example
/// ```gleam
/// let my_handler = fn(req: Request(Connection)) {
///   response.new(200)
///   |> response.set_body("Hello from Hinoto!")
/// }
///
/// let mist_handler = mist.handler(my_handler)
/// ```
@target(erlang)
pub fn handler(
  hinoto_handler: fn(Request(Connection)) -> Response(String),
) -> fn(Request(Connection)) -> Response(ResponseData) {
  fn(mist_request: Request(Connection)) {
    let hinoto_response = hinoto_handler(mist_request)
    convert_response(hinoto_response)
  }
}

/// Starts an HTTP server using Mist
///
/// This function provides a convenient interface to start a Mist HTTP server
/// with a Hinoto-style handler. It handles the conversion between Hinoto and
/// Mist types automatically.
///
/// ## Parameters
/// - `hinoto_handler`: A function that takes Request(Connection) and returns Response(String)
/// - `port`: Optional port number to listen on (defaults to 3000)
/// - `hostname`: Optional hostname to bind to (defaults to "0.0.0.0")
///
/// ## Returns
/// Result indicating success or failure
///
/// ## Example
/// ```gleam
/// import hinoto/runtime/mist
/// import gleam/option.{Some, None}
/// import mist.{type Connection}
///
/// let my_handler = fn(req: Request(Connection)) {
///   response.new(200)
///   |> response.set_body("Hello!")
/// }
///
/// // Start server with default settings
/// mist.start_server(my_handler, None, None)
///
/// // Start server on specific port
/// mist.start_server(my_handler, Some(8080), None)
/// ```
@target(erlang)
pub fn start_server(
  hinoto_handler: fn(Request(Connection)) -> Response(String),
  port: option.Option(Int),
  hostname: option.Option(String),
) {
  let mist_handler = handler(hinoto_handler)

  let actual_port = case port {
    option.Some(p) -> p
    option.None -> default_port
  }

  let actual_hostname = case hostname {
    option.Some(h) -> h
    option.None -> default_hostname
  }

  let assert Ok(_) =
    mist_handler
    |> mist.new
    |> mist.port(actual_port)
    |> mist.bind(actual_hostname)
    |> mist.start

  process.sleep_forever()
}
