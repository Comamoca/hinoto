# Requirements Document

## Project Description (Input)
hinotoにWebSocketサポートを追加したい。追加する方法を検討して。

## Requirements

### Functional Requirements

1. **Multi-runtime WebSocket support**
   - Hinoto must support server-side WebSockets on the following runtimes:
     - Cloudflare Workers / WinterJS
     - Deno
     - Bun
     - Mist (Erlang)
   - Node.js support is deferred to a follow-up task because `@hono/node-server`'s WebSocket upgrade helper requires a Hono app context, which Hinoto does not currently expose.

2. **Common abstraction**
   - Provide a unified `hinoto/websocket` module with common types:
     - `WebSocket` opaque type
     - `WebSocketMessage` with variants `Text`, `Binary`, `Close`, `Ping`, `Pong`
     - `WebSocketHandler` with lifecycle callbacks (`on_open`, `on_message`, `on_close`)
   - Provide common actions: `send_text`, `send_binary`, `close`.

3. **Runtime-specific upgrade functions**
   - Each runtime module exposes its own WebSocket upgrade function that integrates with the Hinoto request/response flow:
     - `workers.upgrade_websocket`
     - `deno.upgrade_websocket`
     - `bun.upgrade_websocket` (plus `bun.websocket_handler` for Bun's server option)
     - `node.upgrade_websocket` (plus `node.start_server_with_websocket`)
     - `mist.upgrade_websocket`

4. **No core type changes**
   - The `Hinoto` type in `src/hinoto.gleam` must remain unchanged.
   - WebSocket types must live in a new `hinoto/websocket` module, avoiding name collisions with existing types (`Body`, `StringBody`, etc.).

5. **Synchronous vs asynchronous handlers**
   - JavaScript runtimes use Promise-based handlers.
   - Mist (Erlang) uses synchronous handlers because `mist.websocket` callbacks are synchronous.

### Non-functional Requirements

1. **Backward compatibility**
   - Existing HTTP-only usage must continue to work without code changes.
   - If a runtime's `start_server` signature must change to accept WebSocket configuration, the change must be documented as a breaking change in the commit message following Conventional Commits (`BREAKING CHANGE:` or `!`).

2. **Tree-shaking friendly**
   - WebSocket code should be placed in its own module so applications that do not use WebSockets do not pay the bundle cost.

3. **Examples and documentation**
   - Provide usage examples for at least Cloudflare Workers, Mist, and one JavaScript runtime.
   - Update README or changelog to describe the new feature and breaking changes.
