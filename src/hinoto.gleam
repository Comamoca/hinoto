/// Hinoto - A web framework written in Gleam, designed for multiple JavaScript runtimes!
///
/// This library provides a simple and ergonomic way to handle HTTP requests and responses
/// in various JavaScript runtime environments.
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}

@target(javascript)
import hinoto/body.{type Body}

@target(javascript)
import gleam/javascript/promise.{
  type Promise, await as promise_await, resolve as promise_resolve,
}

/// Common JavaScript request type used across all JavaScript runtimes
/// (Node.js, Deno, Bun, Cloudflare Workers)
///
/// Note: This type is only used in JavaScript targets. It's defined for all targets
/// to allow import statements in runtime modules, but has no meaning in Erlang.
pub type JsRequest

/// Common JavaScript response type used across all JavaScript runtimes
/// (Node.js, Deno, Bun, Cloudflare Workers)
///
/// Note: This type is only used in JavaScript targets. It's defined for all targets
/// to allow import statements in runtime modules, but has no meaning in Erlang.
pub type JsResponse

/// The core Hinoto type that encapsulates an HTTP request-response cycle.
///
/// This type is parameterized over both a context type and a body type,
/// allowing for flexible context management and body handling depending
/// on your application's needs.
///
/// ## Fields
/// - `request`: The incoming HTTP request
/// - `response`: The HTTP response
/// - `context`: The context data (environment, execution context, etc.)
///
/// ## Type Parameters
/// - `context`: The type of context data (e.g., Cloudflare Workers ExecutionContext)
/// - `body`: The type of request/response body (typically String or BitArray)
pub type Hinoto(context, body) {
  Hinoto(request: Request(body), response: Response(body), context: context)
}

/// Sets a new response for the Hinoto instance.
///
/// This function creates a new Hinoto instance with the provided response,
/// while preserving the existing request and context.
///
/// ## Parameters
/// - `hinoto`: The current Hinoto instance
/// - `response`: The new response to set
///
/// ## Returns
/// A new Hinoto instance with the updated response
pub fn set_response(
  hinoto: Hinoto(context, body),
  response: Response(body),
) -> Hinoto(context, body) {
  Hinoto(request: hinoto.request, response: response, context: hinoto.context)
}

/// Default response handler that returns a simple "Hello from hinoto!" message.
///
/// This function creates a basic HTTP 200 OK response with a plain text body.
/// It's used as the default response when no custom handler is provided.
///
/// ## Returns
/// A Response with status 200 and "Hello from hinoto!" text
pub fn default_response() -> Response(String) {
  response.new(200)
  |> response.set_body("Hello from hinoto!")
}

@target(javascript)
/// Default response handler with Body type (JavaScript target only)
///
/// This function creates a basic HTTP 200 OK response with a StringBody.
/// It's used as the default response in JavaScript runtimes with Body type support.
///
/// ## Returns
/// A Response with status 200 and StringBody("Hello from hinoto!")
pub fn default_response_body() -> Response(Body) {
  response.new(200)
  |> response.set_body(body.StringBody("Hello from hinoto!"))
}

/// Updates the request in a Hinoto instance.
///
/// This function creates a new Hinoto instance with the provided request,
/// while preserving the existing response and context.
///
/// ## Parameters
/// - `hinoto`: The current Hinoto instance
/// - `request`: The new request to set
///
/// ## Returns
/// A new Hinoto instance with the updated request
pub fn set_request(
  hinoto: Hinoto(context, body),
  request: Request(body),
) -> Hinoto(context, body) {
  Hinoto(request: request, response: hinoto.response, context: hinoto.context)
}

/// Updates the context in a Hinoto instance.
///
/// This function creates a new Hinoto instance with the provided context,
/// while preserving the existing request and response.
///
/// ## Parameters
/// - `hinoto`: The current Hinoto instance
/// - `context`: The new context to set
///
/// ## Returns
/// A new Hinoto instance with the updated context
pub fn set_context(
  hinoto: Hinoto(old_context, body),
  context: new_context,
) -> Hinoto(new_context, body) {
  Hinoto(request: hinoto.request, response: hinoto.response, context: context)
}

@target(javascript)
/// Applies a handler function to the request and updates the response.
///
/// This is a convenience function that takes a handler which processes
/// the request and returns a response (wrapped in a Promise for JavaScript target).
/// The response is then set on the Hinoto instance.
///
/// ## JavaScript Target
/// The handler must return a `Promise(Response(body))`. Use `promise.resolve()`
/// for synchronous responses or `promise.await()` with `use` syntax for async operations.
///
/// ## Erlang Target
/// The handler returns a `Response(body)` directly (synchronous).
///
/// ## Parameters
/// - `hinoto`: The current Hinoto instance
/// - `handler`: A function that takes a request and returns a response (Promise for JS, direct for Erlang)
///
/// ## Returns
/// A new Hinoto instance with the response updated by the handler
///
/// ## Example (JavaScript)
/// ```gleam
/// // Synchronous response (returns Promise(Hinoto))
/// let result_promise = hinoto
/// |> handle(fn(req) {
///   promise.resolve(
///     response.new(200)
///     |> response.set_body("Processed!")
///   )
/// })
///
/// // Asynchronous response
/// let result_promise = hinoto
/// |> handle(fn(req) {
///   use data <- promise.await(fetch_data())
///   promise.resolve(
///     response.new(200)
///     |> response.set_body(data)
///   )
/// })
/// ```
///
/// ## Example (Erlang)
/// ```gleam
/// hinoto
/// |> handle(fn(req) {
///   response.new(200)
///   |> response.set_body("Processed!")
/// })
/// ```
pub fn handle(
  hinoto: Hinoto(context, body),
  handler: fn(Request(body)) -> Promise(Response(body)),
) -> Promise(Hinoto(context, body)) {
  use resp <- promise.await(handler(hinoto.request))
  promise.resolve(set_response(hinoto, resp))
}

@target(erlang)
pub fn handle(
  hinoto: Hinoto(context, body),
  handler: fn(Request(body)) -> Response(body),
) -> Hinoto(context, body) {
  set_response(hinoto, handler(hinoto.request))
}
