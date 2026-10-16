# Design Document

## Overview

WebSocket support is added as a cross-cutting feature that sits next to Hinoto's existing HTTP request/response model. The design uses a **common abstraction in `hinoto/websocket`** plus **runtime-specific upgrade functions** in each runtime module.

## Core Design Decisions

### 1. No changes to `src/hinoto.gleam`

- `Hinoto(context, body)`, `handle`, `JsRequest`, `JsResponse` remain unchanged.
- WebSocket-specific types are placed in `src/hinoto/websocket.gleam`.

### 2. Common WebSocket module

```gleam
// src/hinoto/websocket.gleam
pub type WebSocket

pub type WebSocketMessage {
  Text(String)
  Binary(BitArray)
  Close(code: Int, reason: String)
  Ping
  Pong
}

pub type WebSocketHandler(state, ctx) {
  WebSocketHandler(
    on_open: fn(WebSocket, state, ctx) -> Promise(state),
    on_message: fn(WebSocket, state, ctx, WebSocketMessage) -> Promise(state),
    on_close: fn(WebSocket, state, ctx) -> Promise(Nil),
  )
}

pub fn send_text(socket: WebSocket, text: String) -> Nil
pub fn send_binary(socket: WebSocket, data: BitArray) -> Nil
pub fn close(socket: WebSocket) -> Nil
```

For Mist, a synchronous variant is provided because Mist's callbacks cannot return Promises:

```gleam
pub type SyncWebSocketHandler(state, ctx) {
  SyncWebSocketHandler(
    on_open: fn(WebSocket, state, ctx) -> state,
    on_message: fn(WebSocket, state, ctx, WebSocketMessage) -> state,
    on_close: fn(WebSocket, state, ctx) -> Nil,
  )
}
```

### 3. Runtime-specific upgrade paths

#### Cloudflare Workers / WinterJS

- Check `request.headers.get("upgrade") == "websocket"`.
- Create `WebSocketPair()`.
- Attach event listeners to the server-side socket.
- Return `new Response(null, { status: 101, webSocket: client })`.

#### Deno

- Call `Deno.upgradeWebSocket(req)` to get `{ socket, response }`.
- Attach listeners to `socket`.
- Return `response`.

#### Bun

- `Bun.serve` requires WebSocket handlers in the `websocket` option at server creation time.
- Provide `bun.websocket_handler(...)` to build that option object.
- In the `fetch` handler, call `server.upgrade(req, options)` and return `undefined` on success.
- Extend `bun.start_server` to accept the `websocket` option. This is a **breaking change**.

#### Node.js (deferred)

- `@hono/node-server`'s `upgradeWebSocket` helper is designed to work inside a Hono app.
- Hinoto currently exposes a low-level `fetch` handler, which does not provide a Hono app context.
- Integrating WebSocket upgrades cleanly would require either building a Hono app internally or exposing a significantly different Node API.
- Therefore, Node.js WebSocket support is deferred to a follow-up task. The `node.gleam` runtime remains unchanged for HTTP usage.

#### Mist (Erlang)

- In the HTTP handler, detect the WebSocket route and call `mist.websocket(...)`.
- Wrap the synchronous Mist handler into `SyncWebSocketHandler`.
- Use `process.Subject` internally if stateful communication is needed.

### 4. FFI design

- `src/hinoto/websocket_ffi.mjs` provides JavaScript-side WebSocket helpers:
  - `sendText(socket, text)`
  - `sendBinary(socket, bits)`
  - `close(socket)`
  - `wrapSocket(jsSocket)` -> returns a stable Gleam `WebSocket` reference
- Each runtime FFI exposes its own `upgradeWebSocket` helper that wires the runtime-specific socket into the common wrapper and attaches the Gleam callbacks.

### 5. File structure

```
src/hinoto/
  websocket.gleam          # common types and helpers
  websocket_ffi.mjs        # JS FFI helpers
  runtime/
    workers.gleam          # add upgrade_websocket
    ffi.workers.mjs        # WebSocketPair wiring
    deno.gleam             # add upgrade_websocket
    ffi.deno.mjs           # Deno.upgradeWebSocket wiring
    bun.gleam              # add upgrade_websocket, websocket_handler, extend start_server
    ffi.bun.mjs            # Bun.serve websocket wiring
    node.gleam             # add upgrade_websocket, start_server_with_websocket
    ffi.node.mjs           # ws + @hono/node-server wiring
    mist.gleam             # add upgrade_websocket
```

## Breaking Changes

- `bun.start_server` and `node.start_server` signatures will change to accept WebSocket configuration. These will be marked as breaking changes in commit messages using Conventional Commits (`BREAKING CHANGE:`).

## Future Considerations

- A fully unified `upgrade_websocket` that hides all runtime differences is not pursued because Bun and Node require server-level WebSocket configuration at startup time, making runtime-agnostic upgrade impossible.
- Pub/sub or room abstractions are out of scope for the initial implementation.
