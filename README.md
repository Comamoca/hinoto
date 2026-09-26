<div align="center">

![Last commit](https://img.shields.io/github/last-commit/Comamoca/hinoto?style=flat-square)
![Repository Stars](https://img.shields.io/github/stars/Comamoca/hinoto?style=flat-square)
![Issues](https://img.shields.io/github/issues/Comamoca/hinoto?style=flat-square)
![Open Issues](https://img.shields.io/github/issues-raw/Comamoca/hinoto?style=flat-square)
![Bug Issues](https://img.shields.io/github/issues/Comamoca/hinoto/bug?style=flat-square)

<img src="https://emoji2svg.comamoca.dev/api/🔥" alt="fire" height="100">

# Hinoto

A web framework written in Gleam, designed for multiple JavaScript runtimes!

</div>

<div align="center">

</div>

## ✨ Features

- 🌐 Support multi runtimes\
  Supports JavaScript runtimes (Node.js, Deno, Bun), CloudFlare Workers, and Erlang with Mist.
- 🧩 Module first\
  Features are divided into modules, generating JavaScript that is advantageous for Tree-shaking. Additionally, no extra FFI code is mixed in during bundling.
- 🔧 Custom context\
  The `Hinoto` type can contain arbitrary context, allowing runtime-specific information to be handled in the same way.
- ⚡ Promise-based async (v2.0.0+)\
  JavaScript targets use Promise-based handlers for async operations, while Erlang remains synchronous.

## 🚀 How to use

### Node.js Example (v2.0.0+)

Node.js requires `ws` as a runtime dependency in addition to `@hono/node-server`.

```gleam
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
    [] -> create_response(200, "<h1>Hello, Hinoto with Node.js!</h1>")
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

pub fn create_response(status: Int, html: String) {
  response.new(status)
  |> response.set_body(StringBody(html))
  |> response.set_header("content-type", "text/html")
}
```

### Cloudflare Workers Example (v2.0.0+)

```gleam
import gleam/http/request
import gleam/http/response
import gleam/javascript/promise.{type Promise}
import gleam/string
import hinoto.{type Hinoto}
import hinoto/body.{type Body, StringBody}
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
    _ -> create_response(404, "<h1>Not Found</h1>")
  }
  |> promise.resolve
}

pub fn create_response(status: Int, html: String) -> Response(Body) {
  response.new(status)
  |> response.set_body(StringBody(html))
  |> response.set_header("content-type", "text/html")
}
```


> **Note**: v2.0.0 introduces Promise-based async handlers for JavaScript targets.

## ⬇️ Install

Add dependencies for hinoto and hinoto_cli to the `dependencies` section of `gleam.toml`.

```toml
hinoto = { git = "https://github.com/Comamoca/hinoto", ref = "main" }
hinoto_cli = { git = "https://github.com/Comamoca/hinoto_cli", ref = "main" }
```

```sh
gleam run -m hinoto/cli -- workers init
wrangler dev
```

## ⛏️ Development

For developing with various target JavaScript runtimes and CloudFlare Workers, `wrangler` is required.

```sh
cd example/

# For CF Workers
cd workers
wrangler dev

# For node.js
cd node_server

# For deno
cd deno_server

# For bun
cd bun_server

```

## 📝 Todo

See [todo.md](./docs/todo.md)

## 🕸️ WebSocket Support

Hinoto now supports server-side WebSockets on Cloudflare Workers, Deno, Bun, Node.js, and Mist (Erlang). The `hinoto/websocket` module provides a common abstraction, while each runtime exposes its own upgrade function.

### Cloudflare Workers

```gleam
import gleam/http/request
import gleam/javascript/promise.{type Promise}
import hinoto.{type Hinoto}
import hinoto/body.{type Body}
import hinoto/runtime/workers.{type WorkersContext}
import hinoto/websocket.{type WebSocketHandler, Text}

pub fn main() {
  workers.serve(fn(hinoto: Hinoto(WorkersContext, Body)) -> Promise(
    Hinoto(WorkersContext, Body),
  ) {
    case request.path_segments(hinoto.request) {
      ["ws"] -> workers.upgrade_websocket(hinoto, ws_handler(), Nil)
      _ -> hinoto |> hinoto.handle(http_handler)
    }
  })
}

fn ws_handler() -> WebSocketHandler(Nil, WorkersContext) {
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
```

### Mist (Erlang)

Mist uses synchronous handlers:

```gleam
import gleam/http/request.{type Request}
import hinoto/runtime/mist.{type HinotoMist}
import hinoto/websocket.{type SyncWebSocketHandler, Text}
import mist.{type Connection, type ResponseData}

pub fn main() {
  mist.start_server(handler, None, None)
}

fn handler(req: Request(Connection)) -> Response(ResponseData) {
  case request.path_segments(req) {
    ["ws"] -> mist.upgrade_websocket(hinoto, ws_handler(), Nil)
    _ -> http_handler(req)
  }
}

fn ws_handler() -> SyncWebSocketHandler(Nil, Nil) {
  websocket.sync_handler(
    on_open: fn(_ws, state, _ctx) { state },
    on_message: fn(ws, state, _ctx, message) {
      case message {
        Text(text) -> websocket.send_text(ws, "echo: " <> text)
        _ -> Nil
      }
      state
    },
    on_close: fn(_ws, _state, _ctx) { Nil },
  )
}
```

### Deno / Bun

Deno and Bun handlers now receive the raw `JsRequest` as the first argument:

```gleam
import hinoto/runtime/deno

pub fn main() {
  let app_handler = fn(req, hinoto) {
    case request.path_segments(hinoto.request) {
      ["ws"] -> deno.upgrade_websocket(req, hinoto, ws_handler(), Nil)
      _ -> hinoto |> hinoto.handle(http_handler)
    }
  }

  deno.start_server(deno.handler(app_handler), None, None)
}
```

Bun additionally requires a `websocket` option when starting the server. See `example/bun_server` for a complete example.

### Node.js

Node.js uses `@hono/node-server` for the HTTP server and `ws` for WebSocket handling. The handler receives the raw `JsRequest` as its first argument, which is required for upgrades.

```gleam
import hinoto/runtime/node
import hinoto/websocket.{Text}

fn ws_handler() -> websocket.WebSocketHandler(Nil, node.NodeEnv) {
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

pub fn main() {
  node.start_server(
    node.handler(fn(req, hinoto) {
      case request.path_segments(hinoto.request) {
        ["ws"] -> node.upgrade_websocket(req, hinoto, ws_handler(), Nil)
        _ -> hinoto |> hinoto.handle(http_handler)
      }
    }),
    None,
    None,
  )
}
```

## ⚠️ Breaking Changes

- `deno.handler` and `bun.handler` signatures changed to `fn(JsRequest, Hinoto(Nil, body.Body), ...)` so the raw request is available for WebSocket upgrades.
- `bun.start_server` and `bun.serve` now require a `JsWebSocketHandler` as the second argument.
- `node.handler` signature changed to `fn(JsRequest, Hinoto(node.NodeEnv, body.Body), ...)` so the raw request and Node runtime bindings are available for WebSocket upgrades.
- `node.start_server` uses `body.Body` for request/response bodies.

## Request Body Types by Runtime

Each runtime uses an optimal body type for its environment:

| Runtime | Body Type | Description |
|---------|-----------|-------------|
| **Mist (Erlang)** | `Connection` | Native streaming body support for efficient handling of large uploads |
| **Node.js** | `Body` | MDN-compliant flexible body type |
| **Deno** | `Body` | MDN-compliant flexible body type |
| **Bun** | `Body` | MDN-compliant flexible body type |
| **Cloudflare Workers** | `Body` | Flexible MDN-compliant body type for lazy reading |

**Why different types?**
- **Erlang/Mist**: Uses `Connection` to support streaming request bodies, enabling efficient handling of large file uploads and chunked data
- **Node.js / Deno / Bun / Cloudflare Workers**: Use `Body` (flexible MDN-compliant body type) for lazy reading of request bodies via `body.read_text()`, `body.read_json()`, etc.

## 📜 License

MIT

### 🧩 Modules

- [gleam_stdlib](https://hexdocs.pm/gleam_stdlib)
- [gleam_javascript](https://hexdocs.pm/gleam_javascript)
- [gleam_http](https://hexdocs.pm/gleam_http)

## 👏 Affected projects

- [glen](https://hexdocs.pm/glen/index.html)

## 💕 Special Thanks

- [Hono](https://hono.dev/)
