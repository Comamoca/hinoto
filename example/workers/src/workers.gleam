import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/javascript/promise.{type Promise}
import gleam/string
import hinoto.{type Hinoto}
import hinoto/body.{type Body}
import hinoto/runtime/workers.{type WorkersContext}

pub fn main() {
  workers.serve(fn(hinoto: Hinoto(WorkersContext, Body)) -> Promise(
    Hinoto(WorkersContext, Body),
  ) {
    use hinoto <- promise.await(
      hinoto
      |> hinoto.handle(handler),
    )
    promise.resolve(hinoto)
  })
}

pub fn handler(req) {
  case request.path_segments(req) {
    [] ->
      create_response(200, "<h1>Hello, Hinoto with Cloudflare Workers!</h1>")
    ["greet", name] ->
      create_response(200, string.concat(["Hello! ", name, "!"]))
    // Issue #22 verification: check req.method type at GET /method-check
    ["method-check"] -> verify_method(req)
    _ -> create_response(404, "<h1>Not Found</h1>")
  }
  |> promise.resolve
}

/// Issue #22: Verify that req.method is parsed as http.Method type
///
/// Expected: GET /method-check returns req.method == http.Get as True
/// Bug symptom: req.method was the string "GET", so == http.Get returned False
pub fn verify_method(req: request.Request(Body)) {
  let method_value = string.inspect(req.method)

  // Compare against each http.Method variant
  let is_get = req.method == http.Get
  let is_post = req.method == http.Post
  let is_put = req.method == http.Put
  let is_delete = req.method == http.Delete

  // Verify pattern matching works correctly
  let matched_method = case req.method {
    http.Get -> "Matched: http.Get"
    http.Post -> "Matched: http.Post"
    http.Put -> "Matched: http.Put"
    http.Delete -> "Matched: http.Delete"
    _ ->
      "Matched: _ (fallback) <- Issue #22: method is not parsed as http.Method type"
  }

  let body =
    string.join(
      [
        "=== Issue #22 Method Verification ===",
        "",
        "req.method raw value: " <> method_value,
        "",
        "== Equality checks ==",
        "req.method == http.Get: " <> string.inspect(is_get),
        "req.method == http.Post: " <> string.inspect(is_post),
        "req.method == http.Put: " <> string.inspect(is_put),
        "req.method == http.Delete: " <> string.inspect(is_delete),
        "",
        "== Pattern match result ==",
        matched_method,
        "",
        "Expected for GET request: Matched: http.Get",
      ],
      "\n",
    )

  create_response(200, body)
}

pub fn create_response(status: Int, text: String) {
  response.new(status)
  |> response.set_body(body.StringBody(text))
  |> response.set_header("content-type", "text/plain")
}
