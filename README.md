<div align="center">

![Last commit](https://img.shields.io/github/last-commit/Comamoca/baserepo?style=flat-square)
![Repository Stars](https://img.shields.io/github/stars/Comamoca/baserepo?style=flat-square)
![Issues](https://img.shields.io/github/issues/Comamoca/baserepo?style=flat-square)
![Open Issues](https://img.shields.io/github/issues-raw/Comamoca/baserepo?style=flat-square)
![Bug Issues](https://img.shields.io/github/issues/Comamoca/baserepo/bug?style=flat-square)

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
import gleam/http/response
import gleam/javascript/promise
import gleam/option.{None}
import hinoto
import hinoto/runtime/node

pub fn main() -> Nil {
  let fetch_handler =
    node.handler(fn(hinoto_instance) {
      use updated_hinoto <- promise.await(
        hinoto_instance
        |> hinoto.handle(fn(_req) {
          promise.resolve(
            response.new(200)
            |> response.set_body("<h1>Hello from Hinoto!</h1>")
            |> response.set_header("content-type", "text/html")
          )
        })
      )
      promise.resolve(updated_hinoto)
    })

  node.start_server(fetch_handler, None, None)
}
```

### Cloudflare Workers Example (v2.0.0+)

```gleam
import gleam/http/response
import gleam/javascript/promise
import hinoto
import hinoto/runtime/workers

pub fn main() {
  workers.serve(fn(hinoto_instance) {
    use updated_hinoto <- promise.await(
      hinoto_instance
      |> hinoto.handle(fn(_req) {
        promise.resolve(
          response.new(200)
          |> response.set_body("<h1>Hello from Cloudflare Workers!</h1>")
          |> response.set_header("content-type", "text/html")
        )
      })
    )
    promise.resolve(updated_hinoto)
  })
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

- [ ] Add middleware

## 🔄 Migration from v1.x to v2.0

v2.0.0 introduces Promise-based async handlers for JavaScript targets, which is a **breaking change**.

### Breaking Changes

- **JavaScript targets**: `hinoto.handle` now returns `Promise(Hinoto)` instead of `Hinoto`
- **Handler signature**: Handlers must return `Promise(Response)` instead of `Response`

### Migration Steps

#### Old Code (v1.x)

```gleam
hinoto_instance
|> hinoto.handle(fn(_req) {
  response.new(200)
  |> response.set_body("Hello")
})
```

#### New Code (v2.0.0) - Synchronous Response

Wrap your synchronous response in `promise.resolve()`:

```gleam
import gleam/javascript/promise

hinoto_instance
|> hinoto.handle(fn(_req) {
  promise.resolve(
    response.new(200)
    |> response.set_body("Hello")
  )
})
```

#### New Code (v2.0.0) - Async Operations

Use `use` syntax with `promise.await` for async operations:

```gleam
import gleam/javascript/promise

hinoto_instance
|> hinoto.handle(fn(_req) {
  use data <- promise.await(fetch_data())
  promise.resolve(
    response.new(200)
    |> response.set_body(data)
  )
})
```

#### Handling the Result

Since `handle` now returns a Promise, you must await it:

```gleam
// Old (v1.x)
let result = hinoto_instance |> hinoto.handle(handler)

// New (v2.0.0)
use result <- promise.await(hinoto_instance |> hinoto.handle(handler))
promise.resolve(result)
```

### Erlang Target with Mist

The Erlang target with Mist uses **native streaming support** via `Request(Connection)`:

```gleam
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/option.{None}
import hinoto/runtime/mist as hinoto_mist
import mist.{type Connection}

pub fn main() {
  let handler = fn(req: Request(Connection)) -> Response(String) {
    case request.path_segments(req) {
      [] -> response.new(200)
            |> response.set_body("Home")
      ["about"] -> response.new(200)
                   |> response.set_body("About")
      _ -> response.new(404)
           |> response.set_body("Not Found")
    }
  }

  hinoto_mist.start_server(handler, None, None)
}
```

### Request Body Types by Runtime

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
- [conversation](https://hexdocs.pm/conversation)
- [gleam_javascript](https://hexdocs.pm/gleam_javascript)
- [gleam_http](https://hexdocs.pm/gleam_http)

## 👏 Affected projects

- [glen](https://hexdocs.pm/glen/index.html)

## 💕 Special Thanks

- [Hono](https://hono.dev/)
