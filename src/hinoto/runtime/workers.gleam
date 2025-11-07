/// Cloudflare Workers runtime support for Hinoto
///
/// This module provides types and functions specific to Cloudflare Workers runtime.
@target(javascript)
import gleam/http/request.{type Request}

@target(javascript)
import gleam/http/response.{type Response}

@target(javascript)
import gleam/javascript/promise.{type Promise, await as promise_await}

@target(javascript)
import hinoto.{type Hinoto, type JsRequest, type JsResponse}

@target(javascript)
/// Type representing Cloudflare Workers execution context
pub type WorkersContext

@target(javascript)
/// Converts a Cloudflare Workers request to a Gleam HTTP request
@external(javascript, "./ffi.workers.mjs", "toGleamRequest")
pub fn to_gleam_request(req: JsRequest) -> Promise(Request(String))

@target(javascript)
/// Converts a Gleam HTTP response to a Cloudflare Workers response
@external(javascript, "./ffi.workers.mjs", "toWorkersResponse")
pub fn to_workers_response(resp: Response(String)) -> Promise(JsResponse)

@target(javascript)
/// Creates a fetch handler for Cloudflare Workers
///
/// This function wraps your application handler to work with Cloudflare Workers'
/// fetch event handler interface using Promise-based async operations.
///
/// **Important**: In JavaScript targets, the `hinoto.handle` function returns a
/// `Promise(Hinoto)`, so you must use `promise.await` to handle the result.
///
/// ## Parameters
/// - `handler`: Your application handler that processes Hinoto instances and
///   returns a Promise of the updated instance
///
/// ## Returns
/// A Promise-based function that can be used as a Cloudflare Workers fetch handler
///
/// ## Example (Promise-based handler)
/// ```gleam
/// import hinoto
/// import hinoto/runtime/workers
/// import gleam/http/response
/// import gleam/javascript/promise
///
/// pub fn main() {
///   workers.serve(fn(hinoto) {
///     use updated_hinoto <- promise.await(
///       hinoto
///       |> hinoto.handle(fn(_req) {
///         promise.resolve(
///           response.new(200)
///           |> response.set_body("Hello from Cloudflare Workers!")
///         )
///       })
///     )
///     promise.resolve(updated_hinoto)
///   })
/// }
/// ```
pub fn serve(
  handler: fn(Hinoto(WorkersContext, String)) ->
    Promise(Hinoto(WorkersContext, String)),
) -> fn(JsRequest, WorkersContext) -> Promise(JsResponse) {
  fn(req: JsRequest, ctx: WorkersContext) {
    use gleam_request <- promise.await(to_gleam_request(req))

    let hinoto =
      hinoto.Hinoto(
        request: gleam_request,
        response: hinoto.default_response(),
        context: ctx,
      )

    use updated_hinoto <- promise.await(handler(hinoto))
    to_workers_response(updated_hinoto.response)
  }
}
