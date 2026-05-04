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
    // Issue #22 verification: GET /method-check で req.method の型を確認する
    ["method-check"] -> verify_method(req)
    _ -> create_response(404, "<h1>Not Found</h1>")
  }
  |> promise.resolve
}

/// Issue #22: リクエストメソッドが http.Method 型に変換されているかを検証する
///
/// 期待する動作: GET /method-check のとき req.method == http.Get が True になること
/// バグの症状: req.method が "GET" という文字列のため == http.Get が False になる
pub fn verify_method(req: request.Request(Body)) {
  let method_value = string.inspect(req.method)

  // http.Method 型の各バリアントとの比較
  let is_get = req.method == http.Get
  let is_post = req.method == http.Post
  let is_put = req.method == http.Put
  let is_delete = req.method == http.Delete

  // case で実際にパターンマッチできるかを確認
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
