# Concepts

## Overview

Hinoto is a framework for JavaScript targets written in Gleam.
Hinoto is developed based on the following principles:

- Support multi runtimes\
  Supports JavaScript runtimes supported by Gleam (Node.js, Deno, Bun) and CloudFlare Workers.
- Module first\
  Features are divided into modules, generating JavaScript that is advantageous for Tree-shaking. Additionally, no extra FFI code is mixed in during bundling.
- Custom context\
  The `Hinoto` type can contain arbitrary context, allowing runtime-specific information to be handled in the same way.


## Package Structure

Hinoto consists of the following modules:

- hinoto\
The core module `hinoto` defines the type definitions necessary for running Hinoto, functions for converting JavaScript Requests to Gleam Requests, and more.
- hinoto/runtime\
Runtime-specific processes dependent on JavaScript engines are defined here. FFI code is also defined in this module.
- hinoto/middleware\
Code related to middleware is defined in this module.

## About the Hinoto Type

The `Hinoto` type is defined as follows:

```gleam
Hinoto(
  request: Request(RequestBody),
  response: Promise(Response(ResponseBody)),
  context: context,
)
```

## Handlers

In Hinoto, handlers are defined as follows:

`fn (Hinoto(context)) -> Hinoto(context)`

Since both the received Request and the returned Response are handled using the Hinoto type, writing an HTTP server is equivalent to writing transformation functions for the Hinoto type.

In Gleam, handler implementations are functions like `fn (Request(RequestBody)) -> Response(ResponseBody)`, so Hinoto provides a `handle` function to enable implementing such functions.

`handle` takes a Hinoto type and a function `fn(Request(RequestBody)) -> Promise(Response(ResponseBody))`, and returns a Hinoto type.
By using the [use syntax](https://tour.gleam.run/advanced-features/use/), you can focus on processing HTTP requests without being aware of the Hinoto type.

```gleam
fn handler(hinoto) {
  use _req <- hinoto.handle(hinoto)

  response.new(200)
  |> response.set_body(Text("<h1>Hello, Hinoto!</h1>"))
  |> response.set_header("content-type", "text/html")
  |> promise.resolve
}
```

## Routing

When writing web servers in Gleam, it's conventional to perform routing using pattern matching.
Therefore, Hinoto does not currently provide a router.

The following is an example of performing routing in a handler:

```gleam
fn handler(hinoto) {
  use req <- hinoto.handle(hinoto)

  let text_h1 = fn(status, text) {
    response.new(status)
    |> response.set_body(Text(text))
    |> response.set_header("content-type", "text/html")
  }

  case request.path_segments(req) {
    [] -> text_h1(200, "Hello, Hinoto!")
    _ -> text_h1(404, "Not Found")
  }
  |> promise.resolve
}
```
