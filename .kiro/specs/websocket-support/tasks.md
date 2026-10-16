# Tasks

## Spec
- [x] Create websocket-support spec files
- [x] Mark spec approved for implementation

## Core
- [ ] Create `src/hinoto/websocket.gleam` with common types and helpers
- [ ] Create `src/hinoto/websocket_ffi.mjs` with JS-side WebSocket operations

## Runtimes
- [ ] Implement WebSocket support for Cloudflare Workers (`workers.gleam`, `ffi.workers.mjs`)
- [ ] Implement WebSocket support for Mist (`mist.gleam`)
- [ ] Implement WebSocket support for Deno (`deno.gleam`, `ffi.deno.mjs`)
- [ ] Implement WebSocket support for Bun (`bun.gleam`, `ffi.bun.mjs`)
- [ ] Implement WebSocket support for Node.js (`node.gleam`, `ffi.node.mjs`) — deferred to follow-up

## Examples & Docs
- [ ] Add WebSocket example for Cloudflare Workers
- [ ] Add WebSocket example for Mist
- [ ] Add WebSocket example for one JavaScript runtime (Deno or Node)
- [ ] Update README or changelog with WebSocket feature and breaking changes

## Verify
- [ ] Run `gleam build` for JavaScript target
- [ ] Run `gleam build` for Erlang target
- [ ] Run existing test suite
- [ ] Smoke test WebSocket upgrade path manually or with a throwaway script
