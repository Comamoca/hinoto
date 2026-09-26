/**
 * FFI helpers for the common `hinoto/websocket` module.
 *
 * These functions operate on the runtime-agnostic WebSocket wrapper
 * `{ inner: <runtime-specific socket> }` and assume the inner value
 * implements the standard WebSocket API.
 */

/**
 * Sends a text frame over the WebSocket.
 * @param {{ inner: WebSocket }} ws - Wrapped WebSocket
 * @param {string} text - Text payload
 */
export function sendText(ws, text) {
  ws.inner.send(text);
}

/**
 * Sends a binary frame over the WebSocket.
 * @param {{ inner: WebSocket }} ws - Wrapped WebSocket
 * @param {Uint8Array} data - Binary payload (Gleam BitArray)
 */
export function sendBinary(ws, data) {
  // Gleam BitArray is represented as a Uint8Array in JavaScript.
  ws.inner.send(data);
}

/**
 * Closes the WebSocket connection.
 * @param {{ inner: WebSocket }} ws - Wrapped WebSocket
 */
export function close(ws) {
  ws.inner.close();
}
