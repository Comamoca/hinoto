import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/option.{None}
import gleam/string
import hinoto/runtime/mist as hinoto_mist
import mist.{type Connection}

pub fn main() {
  hinoto_mist.start_server(handler, None, None)
}

pub fn handler(req: Request(Connection)) -> Response(String) {
  case request.path_segments(req) {
    [] -> create_response(200, "<h1>Hello, Hinoto with Mist!</h1>")
    ["greet", name] ->
      create_response(200, string.concat(["Hello! ", name, "!"]))
    _ -> create_response(404, "<h1>Not Found</h1>")
  }
}

pub fn create_response(status: Int, html: String) {
  response.new(status)
  |> response.set_body(html)
  |> response.set_header("content-type", "text/html")
}
