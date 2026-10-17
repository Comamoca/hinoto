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

## ✨ Features

- 🌐 Multi runtime support\
  Node.js, Deno, Bun, Cloudflare Workers, and Erlang (Mist).
- 🧩 Module-first\
  Features are divided into modules, generating JavaScript that is advantageous for tree-shaking. No extra FFI code is mixed in during bundling.
- 🔧 Custom context\
  The `Hinoto` type can contain arbitrary context, allowing runtime-specific information to be handled uniformly.
- ⚡ Promise-based async\
  JavaScript targets use Promise-based handlers for async operations. Erlang remains synchronous.
- 🕸️ WebSocket support\
  All runtimes expose the same `websocket.handler` / `websocket.sync_handler` abstraction. See [WebSocket Support](#-websocket-support).

## 🚀 How to use

### Deno

```gleam
import gleam/http/request
import gleam/http/response
import gleam/javascript/promise
import gleam/option.{None}
import hinoto
import hinoto/body.{StringBody}
import hinoto/runtime/deno

pub fn main() -> Nil {
  deno.start_server(
    deno.handler(fn(hinoto) {
      use updated <- promise.await(hinoto |> hinoto.handle(handler))
      promise.resolve(updated)
    }),
    None,
    None,
  )
}

pub fn handler(req) {
  case request.path_segments(req) {
    [] -> response.new(200) |> response.set_body(StringBody("<h1>Hello from Deno!</h1>"))
    _ -> response.new(404) |> response.set_body(StringBody("<h1>Not Found</h1>"))
  }
  |> promise.resolve
}
```

### Bun

Bun is identical to Deno -- change only the module name:

```gleam
import hinoto/runtime/bun

pub fn main() -> Nil {
  bun.start_server(
    bun.handler(fn(hinoto) {
      use updated <- promise.await(hinoto |> hinoto.handle(handler))
      promise.resolve(updated)
    }),
    None,
    None,
  )
}
```

### Node.js

Node.js requires `@hono/node-server` (and `ws` for WebSocket support).

```gleam
import gleam/http/request
import gleam/http/response
import gleam/javascript/promise
import gleam/option.{None}
import gleam/string
import hinoto
import hinoto/body.{StringBody}
import hinoto/runtime/node

pub fn main() -> Nil {
  node.start_server(
    node.handler(fn(hinoto) {
      use updated <- promise.await(hinoto |> hinoto.handle(handler))
      promise.resolve(updated)
    }),
    None,
    None,
  )
}

pub fn handler(req) {
  case request.path_segments(req) {
    [] -> response.new(200) |> response.set_body(StringBody("<h1>Hello from Node.js!</h1>"))
    _ -> response.new(404) |> response.set_body(StringBody("<h1>Not Found</h1>"))
  }
  |> promise.resolve
}
```

### Cloudflare Workers

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
    use updated <- promise.await(hinoto |> hinoto.handle(handler))
    promise.resolve(updated)
  })
}

pub fn handler(req) {
  case request.path_segments(req) {
    [] ->
      response.new(200) |> response.set_body(StringBody("<h1>Hello from Workers!</h1>"))
    _ -> response.new(404) |> response.set_body(StringBody("<h1>Not Found</h1>"))
  }
  |> promise.resolve
}
```

### Mist (Erlang)

Erlang uses synchronous handlers and `Request(Connection)` for streaming body support:

```gleam
import gleam/bytes_tree
import gleam/http/request
import gleam/http/response
import gleam/option.{None}
import gleam/string
import hinoto/runtime/mist as hinoto_mist
import mist

pub fn main() {
  hinoto_mist.start_server(handler, None, None)
}

pub fn handler(
  req: request.Request(mist.Connection),
) -> response.Response(mist.ResponseData) {
  case request.path_segments(req) {
    [] ->
      response.new(200)
      |> response.set_body(mist.Bytes(bytes_tree.from_string("<h1>Hello from Mist!</h1>")))
      |> response.set_header("content-type", "text/html")
    _ ->
      response.new(404)
      |> response.set_body(mist.Bytes(bytes_tree.from_string("<h1>Not Found</h1>")))
      |> response.set_header("content-type", "text/html")
  }
}
```

## ⬇️ Install

This repository is a monorepo. Each package lives under `packages/`.

| Package | Path | Description |
| --- | --- | --- |
| `hinoto` | [`packages/hinoto`](./packages/hinoto) | The framework itself |
| `hinoto_cli` | [`packages/cli`](./packages/cli) | Setup tools (`gleam run -m hinoto/cli`) |

Add the dependency to your `gleam.toml`:

```toml
# Hex (when published)
hinoto = ">= 0.0.1"

# Local path (monorepo development)
hinoto = { path = "../hinoto/packages/hinoto" }
```

For Cloudflare Workers, use the CLI to scaffold a project:

```sh
gleam run -m hinoto/cli -- workers init
wrangler dev
```

## 🕸️ WebSocket Support

All runtimes support server-side WebSockets through `hinoto/websocket`. JavaScript runtimes share the same `upgrade_websocket` signature; Mist uses a synchronous variant.

```gleam
// JavaScript runtimes (Deno, Bun, Node.js, Workers)
pub fn upgrade_websocket(
  hinoto: Hinoto(ctx, Body),
  handler: WebSocketHandler(state, ctx),
  initial_state: state,
) -> Promise(Hinoto(ctx, Body))
```

| Runtime | Context type (`ctx`) | Handler type |
|---------|---------------------|--------------|
| **Cloudflare Workers** | `WorkersContext` | `WebSocketHandler` |
| **Deno** | `Nil` | `WebSocketHandler` |
| **Bun** | `Nil` | `WebSocketHandler` |
| **Node.js** | `NodeEnv` | `WebSocketHandler` |
| **Mist (Erlang)** | `Nil` | `SyncWebSocketHandler` |

See [`example/`](./example) for complete WebSocket examples for each runtime.

## ⚠️ Request body types

Each runtime uses a body type suited to its environment:

| Runtime | Body type | Description |
|---------|-----------|-------------|
| **Mist (Erlang)** | `Connection` | Streaming body for large uploads and chunked data |
| **Node.js / Deno / Bun / Workers** | `Body` | Lazy-reading body (`body.read_text()`, `body.read_json()`, etc.) |

## ⛏️ Development

```sh
cd example/

# Cloudflare Workers (requires wrangler)
cd workers && wrangler dev

# Deno
cd deno_server && gleam run --target javascript

# Bun
cd bun_server && gleam run --target javascript

# Node.js
cd node_server && gleam run --target javascript

# Mist (Erlang)
cd mist_server && gleam run --target erlang
```

## 📝 Todo

See [todo.md](./packages/hinoto/docs/todo.md)

## 📜 License

MIT

## 👏 Affected projects

- [glen](https://hexdocs.pm/glen/index.html)

## 💕 Special Thanks

- [Hono](https://hono.dev/)