import gleam/bytes_tree
import gleam/http/request
import gleam/http/response
import gleam/option.{None}
import gleam/string
import hinoto/runtime/mist as hinoto_mist
import hinoto/websocket
import mist

pub fn main() {
  hinoto_mist.start_server(handler, None, None)
}

pub fn handler(
  req: request.Request(mist.Connection),
) -> response.Response(mist.ResponseData) {
  case request.path_segments(req) {
    [] -> create_response(200, "<h1>Hello, Hinoto with Mist!</h1>")
    ["ws"] ->
      hinoto_mist.upgrade_websocket(req, ws_handler(), Nil)
    ["greet", name] ->
      create_response(200, string.concat(["Hello! ", name, "!"]))
    _ -> create_response(404, "<h1>Not Found</h1>")
  }
}

fn ws_handler() -> websocket.SyncWebSocketHandler(Nil, Nil) {
  websocket.sync_handler(
    on_open: fn(_ws, state, _ctx) { state },
    on_message: fn(ws, state, _ctx, message) {
      case message {
        websocket.Text(text) -> websocket.send_text(ws, "echo: " <> text)
        _ -> Nil
      }
      state
    },
    on_close: fn(_ws, _state, _ctx) { Nil },
  )
}

pub fn create_response(
  status: Int,
  html: String,
) -> response.Response(mist.ResponseData) {
  response.new(status)
  |> response.set_body(mist.Bytes(bytes_tree.from_string(html)))
  |> response.set_header("content-type", "text/html")
}
