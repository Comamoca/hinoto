/// Hinoto - A web framework written in Gleam, designed for multiple JavaScript runtimes!
///
/// This library provides a simple and ergonomic way to handle HTTP requests and responses
/// in a Cloudflare Workers or similar JavaScript runtime environment.
import conversation.{
  type JsRequest, type JsResponse, type RequestBody, type ResponseBody,
}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/javascript/promise.{type Promise}

/// Represents the execution context for a request.
/// This is typically provided by the runtime environment (e.g., Cloudflare Workers).
pub type Context {
  Context
}

/// Represents the environment variables and configuration.
/// This contains runtime-specific environment data.
pub type Environment {
  Environment
}

/// The default context type that combines environment and execution context.
/// This is the most commonly used context type for standard request handling.
pub type DefaultContext {
  DefaultContext(env: Environment, context: Context)
}

/// The core Hinoto type that encapsulates an HTTP request-response cycle.
///
/// This type is parameterized over a context type, allowing for flexible
/// context management depending on your application's needs.
///
/// ## Fields
/// - `request`: The incoming HTTP request
/// - `response`: A promise that resolves to the HTTP response
/// - `ctx`: The context data (environment, execution context, etc.)
pub type Hinoto(context) {
  Hinoto(
    request: Request(RequestBody),
    response: Promise(Response(ResponseBody)),
    context: context,
  )
}

/// Sets a new response for the Hinoto instance.
///
/// This function creates a new Hinoto instance with the provided response,
/// while preserving the existing request and context.
///
/// ## Parameters
/// - `hinoto`: The current Hinoto instance
/// - `response`: The new response promise to set
///
/// ## Returns
/// A new Hinoto instance with the updated response
pub fn set_response(
  hinoto: Hinoto(context),
  response: Promise(Response(ResponseBody)),
) {
  Hinoto(request: hinoto.request, response:, context: hinoto.context)
}

/// Handles an incoming JavaScript request using the provided handler function.
///
/// This is the main entry point for processing HTTP requests. It converts
/// a JavaScript request to a Gleam request, processes it through your handler,
/// and converts the response back to a JavaScript response.
///
/// ## Parameters
/// - `req`: The incoming JavaScript request object
/// - `env`: The environment configuration
/// - `context`: The execution context
/// - `handler`: A function that processes the Hinoto instance and returns a modified one
///
/// ## Returns
/// A promise that resolves to a JavaScript response object
///
/// ## Example
/// ```gleam
/// let my_handler = fn(hinoto) {
///   hinoto
///   |> update_response(promise.resolve(response.new(200)))
/// }
///
/// handle_request(req, env, ctx, my_handler)
/// ```
pub fn handle_request(
  req: JsRequest,
  context: context,
  handler: fn(Hinoto(context)) -> Hinoto(context),
) -> Promise(JsResponse) {
  let hinoto =
    handler(Hinoto(
      request: conversation.to_gleam_request(req),
      response: default_handler(),
      context: context,
    ))

  hinoto.response
  |> promise.map(conversation.to_js_response)
}

/// Default response handler that returns a simple "Hello from hinoto!" message.
///
/// This function creates a basic HTTP 200 OK response with a plain text body.
/// It's used as the default response when no custom handler is provided.
///
/// ## Returns
/// A promise that resolves to a Response with status 200 and "Hello from hinoto!" text
pub fn default_handler() -> Promise(Response(ResponseBody)) {
  response.new(200)
  |> response.set_body(conversation.Text("Hello from hinoto!"))
  |> promise.resolve
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
pub fn update_request(
  hinoto: Hinoto(context),
  request: Request(RequestBody),
) -> Hinoto(context) {
  Hinoto(request:, response: hinoto.response, context: hinoto.context)
}

/// Updates the response in a Hinoto instance.
///
/// This function creates a new Hinoto instance with the provided response,
/// while preserving the existing request and context.
///
/// ## Parameters
/// - `hinoto`: The current Hinoto instance
/// - `response`: The new response promise to set
///
/// ## Returns
/// A new Hinoto instance with the updated response
pub fn update_response(
  hinoto: Hinoto(context),
  response: Promise(Response(ResponseBody)),
) -> Hinoto(context) {
  Hinoto(request: hinoto.request, response:, context: hinoto.context)
}

/// Updates the environment in a Hinoto instance.
///
/// Note: This function currently updates the response instead of the environment.
/// This appears to be a bug and should be fixed to update the environment in the context.
///
/// ## Parameters
/// - `hinoto`: The current Hinoto instance
/// - `response`: The new response promise to set (should be environment instead)
///
/// ## Returns
/// A new Hinoto instance with the updated response
pub fn update_environment(
  hinoto: Hinoto(context),
  response: Promise(Response(ResponseBody)),
) -> Hinoto(context) {
  Hinoto(request: hinoto.request, response:, context: hinoto.context)
}

/// Applies a handler function to the request and updates the response.
///
/// This is a convenience function that takes a handler which processes
/// the request and returns a response promise. The response is then
/// set on the Hinoto instance.
///
/// ## Parameters
/// - `hinoto`: The current Hinoto instance
/// - `handler`: A function that takes a request and returns a response promise
///
/// ## Returns
/// A new Hinoto instance with the response updated by the handler
///
/// ## Example
/// ```gleam
/// let my_handler = fn(req) {
///   response.new(200)
///   |> response.set_body(conversation.Text("Processed!"))
///   |> promise.resolve
/// }
///
/// hinoto |> handle(my_handler)
/// ```
pub fn handle(
  hinoto: Hinoto(context),
  handler: fn(Request(RequestBody)) -> Promise(Response(ResponseBody)),
) -> Hinoto(context) {
  set_response(hinoto, handler(hinoto.request))
}

// pub fn fetch(
//   handler: fn(Hinoto(context)) -> Hinoto(context),
// ) -> fn(JsRequest) -> Promise(JsResponse) {
//   let wrap = fn(request: JsRequest) -> Promise(JsResponse) { promise.resolve }

//   wrap
// }

pub fn fetch(handler) {
  let ctx = Context

  fn(req: JsRequest) -> Promise(JsResponse) {
    handle_request(req, ctx, handler)
  }
}
