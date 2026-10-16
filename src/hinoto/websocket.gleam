////
//// WebSocket support for Hinoto.
////
//// This module provides runtime-agnostic WebSocket types and helpers.
//// Runtime-specific upgrade functions live in each runtime module.
////

import gleam/dynamic.{type Dynamic}
import gleam/javascript/promise.{type Promise}

/// Opaque type representing a WebSocket connection.
///
/// The internal representation differs by runtime, but the public API is the same
/// across all supported targets.
pub opaque type WebSocket {
  WebSocket(inner: Dynamic)
}

/// Represents an incoming WebSocket message.
pub type WebSocketMessage {
  /// Text message payload.
  Text(String)

  /// Binary message payload.
  Binary(BitArray)

  /// Close event with status code and reason.
  Close(code: Int, reason: String)

  /// Ping frame.
  Ping

  /// Pong frame.
  Pong
}

/// Promise-based WebSocket handler for JavaScript runtimes.
pub type WebSocketHandler(state, ctx) {
  WebSocketHandler(
    on_open: fn(WebSocket, state, ctx) -> Promise(state),
    on_message: fn(WebSocket, state, ctx, WebSocketMessage) -> Promise(state),
    on_close: fn(WebSocket, state, ctx) -> Promise(Nil),
  )
}

/// Synchronous WebSocket handler for Erlang/Mist runtime.
pub type SyncWebSocketHandler(state, ctx) {
  SyncWebSocketHandler(
    on_open: fn(WebSocket, state, ctx) -> state,
    on_message: fn(WebSocket, state, ctx, WebSocketMessage) -> state,
    on_close: fn(WebSocket, state, ctx) -> Nil,
  )
}

/// Creates a promise-based WebSocket handler for JavaScript runtimes.
pub fn handler(
  on_open on_open: fn(WebSocket, state, ctx) -> Promise(state),
  on_message on_message: fn(WebSocket, state, ctx, WebSocketMessage) -> Promise(
    state,
  ),
  on_close on_close: fn(WebSocket, state, ctx) -> Promise(Nil),
) -> WebSocketHandler(state, ctx) {
  WebSocketHandler(on_open:, on_message:, on_close:)
}

/// Creates a synchronous WebSocket handler for Erlang/Mist runtime.
pub fn sync_handler(
  on_open on_open: fn(WebSocket, state, ctx) -> state,
  on_message on_message: fn(WebSocket, state, ctx, WebSocketMessage) -> state,
  on_close on_close: fn(WebSocket, state, ctx) -> Nil,
) -> SyncWebSocketHandler(state, ctx) {
  SyncWebSocketHandler(on_open:, on_message:, on_close:)
}

/// Wraps a runtime-specific socket into the common WebSocket type.
pub fn wrap(inner: Dynamic) -> WebSocket {
  WebSocket(inner)
}

/// Sends a text frame over the WebSocket.
@target(javascript)
@external(javascript, "./websocket_ffi.mjs", "sendText")
pub fn send_text(socket: WebSocket, text: String) -> Nil

@target(erlang)
pub fn send_text(socket: WebSocket, text: String) -> Nil {
  let inner = case socket {
    WebSocket(inner) -> inner
  }
  send_text_erlang(inner, text)
}

@target(erlang)
@external(erlang, "websocket_ffi", "send_text")
fn send_text_erlang(inner: Dynamic, text: String) -> Nil

/// Sends a binary frame over the WebSocket.
@target(javascript)
@external(javascript, "./websocket_ffi.mjs", "sendBinary")
pub fn send_binary(socket: WebSocket, data: BitArray) -> Nil

@target(erlang)
pub fn send_binary(socket: WebSocket, data: BitArray) -> Nil {
  let inner = case socket {
    WebSocket(inner) -> inner
  }
  send_binary_erlang(inner, data)
}

@target(erlang)
@external(erlang, "websocket_ffi", "send_binary")
fn send_binary_erlang(inner: Dynamic, data: BitArray) -> Nil

/// Closes the WebSocket connection.
@target(javascript)
@external(javascript, "./websocket_ffi.mjs", "close")
pub fn close(socket: WebSocket) -> Nil

@target(erlang)
pub fn close(socket: WebSocket) -> Nil {
  let inner = case socket {
    WebSocket(inner) -> inner
  }
  close_erlang(inner)
}

@target(erlang)
@external(erlang, "websocket_ffi", "close")
fn close_erlang(inner: Dynamic) -> Nil

@target(erlang)
/// Casts an Erlang term to `Dynamic`.
///
/// Erlang is dynamically typed, so this is a no-op at runtime. It exists so
/// runtime modules can pass opaque values (such as Mist's
/// `WebsocketConnection`) through the common `WebSocket` wrapper.
@external(erlang, "websocket_ffi", "unsafe_coerce")
pub fn unsafe_coerce(value: a) -> Dynamic
