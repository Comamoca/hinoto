# QuickStart

## Requirements

- JavaScript Runtime (Node.js, Deno, Bun)
- Gleam compiler (latest version recommended)
- wrangler (optional)

## Setup

### CloudFlare Workers

You can easily create wrangler configuration files using [hinoto/cli](https://github.com/Comamoca/hinoto/tree/main/packages/cli).

```sh
gleam new project_name
gleam add hinoto hinoto_cli
gleam run -m hinoto/cli workers init

wrangler dev
```

### JavaScript Runtime

For JavaScript runtimes other than Workers, corresponding modules are available in `hinoto/runtime`.

### Node.js

The `hinoto/runtime/node` module uses [honojs/node-server](https://github.com/honojs/node-server).
Therefore, you need to install the npm package beforehand.

You can use any package manager of your choice.

```sh
npm install @hono/node-server
```

```gleam
import conversation.{Text}
import gleam/http/response
import gleam/javascript/promise
import gleam/option.{None}
import hinoto
import hinoto/runtime/node

pub fn main() -> Nil {
  node.serve(hinoto.fetch(handler), None, None)
}

fn handler(hinoto) {
  use _req <- hinoto.handle(hinoto)

  response.new(200)
  |> response.set_body(Text("<h1>Hello, Hinoto with Node.js!</h1>"))
  |> response.set_header("content-type", "text/html")
  |> promise.resolve
}
```

### Deno

```gleam
import conversation.{Text}
import gleam/http/response
import gleam/javascript/promise
import gleam/option.{None}
import hinoto
import hinoto/runtime/deno

pub fn main() -> Nil {
  deno.serve(hinoto.fetch(handler), None, None)
}

fn handler(hinoto) {
  use _req <- hinoto.handle(hinoto)

  response.new(200)
  |> response.set_body(Text("<h1>Hello, Hinoto with Deno!</h1>"))
  |> response.set_header("content-type", "text/html")
  |> promise.resolve
}
```

### Bun

```gleam
import conversation.{Text}
import gleam/http/response
import gleam/javascript/promise
import gleam/option.{None}
import hinoto
import hinoto/runtime/bun

pub fn main() -> Nil {
  bun.serve(hinoto.fetch(handler), None, None)
}

fn handler(hinoto) {
  use _req <- hinoto.handle(hinoto)

  response.new(200)
  |> response.set_body(Text("<h1>Hello, Hinoto with Bun!</h1>"))
  |> response.set_header("content-type", "text/html")
  |> promise.resolve
}
```


### Routing

As mentioned in [Concepts](/concepts.html), routing in Gleam is commonly performed using pattern matching.

[`request.path_segments`](https://hexdocs.pm/gleam_http/gleam/http/request.html#path_segments) returns a list of the request path split by `/`.
By applying pattern matching to this list, you can implement routing.

Since routing is simply pattern matching, you can split routing by calling other functions within pattern matches and performing additional pattern matching inside them.

```gleam
fn handler(hinoto) {
  use req <- hinoto.handle(hinoto)

  let hello = response.new(200)
  |> response.set_body(Text("<h1>Hello, Hinoto!</h1>"))
  |> response.set_header("content-type", "text/html")

  let not_found = response.new(404)
  |> response.set_body(Text("<h1>Not Found</h1>"))
  |> response.set_header("content-type", "text/html")

  case request.path_segments(req) {
	["hello"] -> hello // Return hello when /hello is accessed
    ["book", path] -> book
	_ -> not_found     // Return 404 for everything else
  }

  |> promise.resolve
}

// Function to handle routing under `/book`
fn book(req, path: List(String)) {
  let text_h1 = fn(status, text) {
    response.new(status)
    |> response.set_body(Text(text))
    |> response.set_header("content-type", "text/html")
  }

  case path {
    [] -> text_h1(200, "This is /book")
    [path] -> text_h1(200, "This is " <> "book/" <> path)
    _ -> text_h1(404, "Not Found")
  }
}
```
