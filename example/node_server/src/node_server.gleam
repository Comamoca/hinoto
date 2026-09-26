import gleam/http/request
import gleam/http/response
import gleam/javascript/promise
import gleam/option.{None}
import gleam/string
import hinoto
import hinoto/body.{StringBody}
import hinoto/runtime/node
import hinoto/websocket.{Text}

pub fn main() -> Nil {
  let fetch_handler =
    node.handler(fn(req, hinoto_instance) {
      case request.path_segments(hinoto_instance.request) {
        ["ws"] -> node.upgrade_websocket(req, hinoto_instance, ws_handler(), Nil)
        _ -> {
          use updated_hinoto <- promise.await(
            hinoto_instance
            |> hinoto.handle(handler),
          )
          promise.resolve(updated_hinoto)
        }
      }
    })

  node.start_server(fetch_handler, None, None)
}

pub fn handler(req) {
  case request.path_segments(req) {
    [] -> create_response(200, index_html())
    ["greet", name] ->
      create_response(200, string.concat(["Hello! ", name, "!"]))
    _ -> create_response(404, "<h1>Not Found</h1>")
  }
  |> promise.resolve
}

fn ws_handler() -> websocket.WebSocketHandler(Nil, node.NodeEnv) {
  websocket.handler(
    on_open: fn(_ws, state, _ctx) { promise.resolve(state) },
    on_message: fn(ws, state, _ctx, message) {
      case message {
        Text(text) -> websocket.send_text(ws, "Echo: " <> text)
        _ -> Nil
      }
      promise.resolve(state)
    },
    on_close: fn(_ws, _state, _ctx) { promise.resolve(Nil) },
  )
}

fn index_html() {
  "<!DOCTYPE html>
<html>
<head>
  <meta charset=\"UTF-8\">
  <title>Hinoto with Node.js</title>
  <style>
    body { font-family: sans-serif; max-width: 600px; margin: 2rem auto; }
    input { width: 70%; padding: 0.5rem; }
    button { padding: 0.5rem 1rem; }
    #log { border: 1px solid #ccc; height: 200px; overflow-y: auto; padding: 0.5rem; margin-top: 1rem; }
  </style>
</head>
<body>
  <h1>Hello, Hinoto with Node.js!</h1>
  <p>Open the browser console to see WebSocket messages.</p>
  <div>
    <input id=\"message\" type=\"text\" placeholder=\"Type a message...\" />
    <button id=\"send\">Send</button>
  </div>
  <div id=\"log\"></div>
  <script>
    const log = (msg) => {
      const el = document.getElementById('log');
      el.innerHTML += msg + '<br>';
      el.scrollTop = el.scrollHeight;
    };
    const ws = new WebSocket('ws://localhost:3000/ws');
    ws.onopen = () => log('Connected');
    ws.onmessage = (event) => log('Received: ' + event.data);
    ws.onclose = () => log('Disconnected');
    ws.onerror = (err) => log('Error: ' + err);
    document.getElementById('send').onclick = () => {
      const input = document.getElementById('message');
      if (input.value) {
        ws.send(input.value);
        log('Sent: ' + input.value);
        input.value = '';
      }
    };
  </script>
</body>
</html>"
}

pub fn create_response(status: Int, html: String) {
  response.new(status)
  |> response.set_body(StringBody(html))
  |> response.set_header("content-type", "text/html")
}
