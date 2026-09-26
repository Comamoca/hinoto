import gleam/http/request
import gleam/http/response
import gleam/javascript/promise
import gleam/option.{None}
import gleam/string
import hinoto
import hinoto/body.{type Body, StringBody}
import hinoto/runtime/deno
import hinoto/websocket.{type WebSocketHandler, Text}

pub fn main() -> Nil {
  let fetch_handler =
    deno.handler(fn(req, hinoto_instance) {
      case request.path_segments(hinoto_instance.request) {
        ["ws"] -> deno.upgrade_websocket(req, hinoto_instance, ws_handler(), Nil)
        _ -> {
          use updated_hinoto <- promise.await(
            hinoto_instance
            |> hinoto.handle(handler),
          )
          promise.resolve(updated_hinoto)
        }
      }
    })

  deno.start_server(fetch_handler, None, None)
}

fn ws_handler() -> WebSocketHandler(Nil, Nil) {
  websocket.handler(
    on_open: fn(_ws, state, _ctx) { promise.resolve(state) },
    on_message: fn(ws, state, _ctx, message) {
      case message {
        Text(text) -> websocket.send_text(ws, "echo: " <> text)
        _ -> Nil
      }
      promise.resolve(state)
    },
    on_close: fn(_ws, _state, _ctx) { promise.resolve(Nil) },
  )
}

pub fn handler(req: request.Request(Body)) {
  case request.path_segments(req) {
    [] -> create_response(200, "<h1>Hello, Hinoto with Deno!</h1>")
    ["greet", name] ->
      create_response(200, string.concat(["Hello! ", name, "!"]))
    _ -> {
      create_response(404, "<h1>Not Found</h1>")
    }
  }
  |> promise.resolve
}

pub fn create_response(status: Int, html: String) {
  response.new(status)
  |> response.set_body(StringBody(html))
  |> response.set_header("content-type", "text/html")
}
