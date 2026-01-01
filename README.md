<div align="center">

![Last commit](https://img.shields.io/github/last-commit/Comamoca/hinoto?style=flat-square)
![Repository Stars](https://img.shields.io/github/stars/Comamoca/hinoto?style=flat-square)
![Issues](https://img.shields.io/github/issues/Comamoca/hinoto?style=flat-square)
![Open Issues](https://img.shields.io/github/issues-raw/Comamoca/hinoto?style=flat-square)
![Bug Issues](https://img.shields.io/github/issues/Comamoca/hinoto/bug?style=flat-square)

<img src="https://emoji2svg.deno.dev/api/🔥" alt="fire" height="100">

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

```gleam
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
```

### Cloudflare Workers Example (v2.0.0+)

```gleam
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
    _ -> create_response(404, "<h1>Not Found</h1>")
  }
  |> promise.resolve
}

pub fn create_response(status: Int, html: String) {
  response.new(status)
  |> response.set_body(html)
  |> response.set_header("content-type", "text/html")
}
```


> **Note**: v2.0.0 introduces Promise-based async handlers for JavaScript targets. See the [Migration Guide](#-migration-from-v1x-to-v20) below for upgrading from v1.x.

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

## Request Body Types by Runtime

Each runtime uses an optimal body type for its environment:

| Runtime | Body Type | Description |
|---------|-----------|-------------|
| **Mist (Erlang)** | `Connection` | Native streaming body support for efficient handling of large uploads |
| **Node.js** | `String` | String-based bodies via Hinoto abstraction |
| **Deno** | `JsRequest` | Runtime-specific type handled via FFI |
| **Bun** | `JsRequest` | Runtime-specific type handled via FFI |
| **Cloudflare Workers** | `String` | String-based bodies via Hinoto abstraction |

**Why different types?**
- **Erlang/Mist**: Uses `Connection` to support streaming request bodies, enabling efficient handling of large file uploads and chunked data
- **JavaScript runtimes**: Use `String` or runtime-specific types for simpler, stateless request handling

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
