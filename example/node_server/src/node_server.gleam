import gleam/http/request
import gleam/http/response
import gleam/javascript/promise
import gleam/option.{None}
import gleam/string
import hinoto
import hinoto/runtime/node

pub fn main() -> Nil {
  let fetch_handler =
    node.handler(fn(hinoto_instance) {
      use updated_hinoto <- promise.await(
        hinoto_instance
        |> hinoto.handle(handler),
      )
      promise.resolve(updated_hinoto)
    })

  node.start_server(fetch_handler, None, None)
}

pub fn handler(req) {
  case request.path_segments(req) {
    [] -> create_response(404, "<h1>Hello, Hinoto with Node.js!</h1>")
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
