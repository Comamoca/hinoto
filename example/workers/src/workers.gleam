import gleam/http/request
import gleam/http/response
import gleam/javascript/promise.{type Promise}
import gleam/string
import hinoto.{type Hinoto}
import hinoto/runtime/workers.{type WorkersContext}

pub fn main() {
  workers.serve(fn(hinoto: Hinoto(WorkersContext, String)) -> Promise(
    Hinoto(WorkersContext, String),
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
    _ -> create_response(404, "<h1>Not Found</h1>")
  }
  |> promise.resolve
}

pub fn create_response(status: Int, html: String) {
  response.new(status)
  |> response.set_body(html)
  |> response.set_header("content-type", "text/html")
}
