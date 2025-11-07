# Hinoto Mist Server Example

This is a sample HTTP server using Hinoto with the Mist runtime on Erlang.

## Features

- **Erlang/OTP**: Runs on the Erlang VM for high concurrency and reliability
- **Mist HTTP Server**: Fast and efficient HTTP server for Erlang
- **Routing**: Demonstrates simple routing with multiple endpoints
- **Synchronous Handlers**: Uses Erlang's synchronous model (no Promises needed)
- **Streaming Body Support**: Uses `Request(Connection)` for efficient handling of large uploads

## Endpoints

- `GET /` - Home page with navigation
- `GET /about` - About page
- `GET /api/hello` - JSON API endpoint
- Any other path - 404 Not Found

## Running the Server

```sh
# Install dependencies
gleam deps download

# Build and run
gleam run --target erlang

# Or build and run separately
gleam build --target erlang
gleam run --target erlang
```

The server will start on `http://localhost:3000` (default port).

## Testing

```sh
# Run tests
gleam test --target erlang

# Make requests
curl http://localhost:3000
curl http://localhost:3000/about
curl http://localhost:3000/api/hello
```

## Code Structure

The server uses Hinoto's Mist runtime module (`hinoto/runtime/mist`) which provides:

- `mist.start_server()` - Starts the HTTP server
- `mist.handler()` - Converts Hinoto handlers to Mist handlers
- Automatic request/response conversion

## Request Body Types

Mist uses `Request(Connection)` instead of `Request(String)` to support streaming request bodies:

```gleam
import mist.{type Connection}

// Mist handler (Erlang)
fn handler(req: Request(Connection)) -> Response(String) {
  response.new(200)
  |> response.set_body("Hello!")
}
```

**Why `Connection`?**
- Supports streaming large file uploads efficiently
- Enables chunked request processing
- Native to Mist's HTTP server implementation

## Comparison with JavaScript

Unlike JavaScript runtimes (Node.js, Deno, Bun) which use Promise-based async handlers, the Erlang target uses synchronous handlers:

```gleam
// Erlang with Mist (synchronous, streaming body)
fn handler(req: Request(Connection)) -> Response(String) {
  response.new(200)
  |> response.set_body("Hello!")
}

// JavaScript (Promise-based, string body)
fn handler(req: Request(String)) -> Promise(Response(String)) {
  promise.resolve(
    response.new(200)
    |> response.set_body("Hello!")
  )
}
```

This is because Erlang's concurrency model uses lightweight processes instead of async/await.
