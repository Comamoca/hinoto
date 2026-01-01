/// Body types for HTTP Request/Response
///
/// This module provides types representing various body formats supported by JavaScript runtimes.
/// Body types support lazy evaluation - the actual body content is only read when explicitly requested.

@target(javascript)
import gleam/javascript/promise.{type Promise}

@target(javascript)
import gleam/dynamic.{type Dynamic}

/// Opaque type representing a JavaScript Blob object
pub type JsBlob

/// Opaque type representing a JavaScript ArrayBuffer object
pub type JsArrayBuffer

/// Opaque type representing a JavaScript TypedArray object (Uint8Array, Int8Array, etc.)
pub type JsTypedArray

/// Opaque type representing a JavaScript DataView object
pub type JsDataView

/// Opaque type representing a JavaScript FormData object
pub type JsFormData

/// Opaque type representing a JavaScript ReadableStream object
pub type JsReadableStream

/// Opaque type representing a JavaScript URLSearchParams object
pub type JsURLSearchParams

/// Opaque type representing a JavaScript Request object (used for lazy body reading)
pub type JsRequest

/// Represents different types of HTTP body content
///
/// This type provides a unified way to handle various body formats in HTTP requests and responses.
/// Each variant corresponds to a specific JavaScript body type defined in the MDN specification.
///
/// ## Lazy Evaluation
///
/// Body content is not read immediately when converting a JavaScript Request to a Gleam Request.
/// Instead, the Request object itself is stored and can be read later using specific reading functions.
/// This approach improves performance by avoiding unnecessary body reads (e.g., for GET requests).
///
/// ## Supported Body Types
///
/// - `StringBody`: Text content (already read as String)
/// - `BitArrayBody`: Binary content (already read as BitArray)
/// - `BlobBody`: Binary Large Object (files, images, etc.)
/// - `ArrayBufferBody`: Fixed-length binary data
/// - `TypedArrayBody`: Typed array views (Uint8Array, etc.)
/// - `DataViewBody`: Flexible view over ArrayBuffer
/// - `FormDataBody`: Form submission data
/// - `ReadableStreamBody`: Streaming data
/// - `URLSearchParamsBody`: URL query parameters
/// - `RequestBody`: JavaScript Request object for lazy reading
/// - `EmptyBody`: No body content
pub type Body {
  /// Text content (String)
  ///
  /// Used when body has already been read as text.
  StringBody(String)

  /// Binary content (BitArray)
  ///
  /// Used when body has already been read as binary data in Gleam.
  BitArrayBody(BitArray)

  /// Blob (Binary Large Object)
  ///
  /// Used for files, images, and other binary data.
  BlobBody(JsBlob)

  /// ArrayBuffer (fixed-length binary data)
  ///
  /// Used for raw binary data with fixed length.
  ArrayBufferBody(JsArrayBuffer)

  /// TypedArray (typed array view)
  ///
  /// Used for typed views over binary data (Uint8Array, Int8Array, etc.).
  TypedArrayBody(JsTypedArray)

  /// DataView (flexible ArrayBuffer view)
  ///
  /// Used for flexible reading/writing of binary data.
  DataViewBody(JsDataView)

  /// FormData (form submission data)
  ///
  /// Used for handling HTML form submissions.
  FormDataBody(JsFormData)

  /// ReadableStream (streaming data)
  ///
  /// Used for streaming large amounts of data.
  ReadableStreamBody(JsReadableStream)

  /// URLSearchParams (URL query parameters)
  ///
  /// Used for URL-encoded form data.
  URLSearchParamsBody(JsURLSearchParams)

  /// JavaScript Request object (for lazy body reading)
  ///
  /// The most common variant for incoming requests.
  /// The body is not read until explicitly requested via read_* functions.
  RequestBody(JsRequest)

  /// Empty body (no content)
  ///
  /// Used when there is no body content (e.g., GET requests, 204 responses).
  EmptyBody
}

/// Errors that can occur when reading body content
pub type BodyReadError {
  /// Body has already been read (cannot read twice)
  AlreadyRead

  /// Failed to parse body content (e.g., invalid JSON, invalid form data)
  ParseError(message: String)

  /// Failed to read body content (I/O error, network error, etc.)
  ReadError(message: String)

  /// Unsupported body type for the requested operation
  UnsupportedBodyType(message: String)
}

@target(javascript)
/// Reads the body content as text (String)
///
/// This function reads the entire body content as a UTF-8 text string.
/// It can be used with RequestBody to lazily read the body when needed.
///
/// ## Example
/// ```gleam
/// use body_text <- promise.await(read_text(request.body))
/// case body_text {
///   Ok(text) -> // Process text...
///   Error(AlreadyRead) -> // Body was already read
///   Error(ReadError(msg)) -> // I/O error occurred
/// }
/// ```
@external(javascript, "./body_ffi.mjs", "readText")
pub fn read_text(body: Body) -> Promise(Result(String, BodyReadError))

@target(javascript)
/// Reads the body content as binary data (BitArray)
///
/// This function reads the entire body content as binary data.
/// Useful for handling files, images, and other binary content.
///
/// ## Example
/// ```gleam
/// use body_bits <- promise.await(read_bits(request.body))
/// case body_bits {
///   Ok(bits) -> // Process binary data...
///   Error(AlreadyRead) -> // Body was already read
///   Error(ReadError(msg)) -> // I/O error occurred
/// }
/// ```
@external(javascript, "./body_ffi.mjs", "readBits")
pub fn read_bits(body: Body) -> Promise(Result(BitArray, BodyReadError))

@target(javascript)
/// Reads the body content as JSON
///
/// This function reads and parses the body content as JSON.
/// The result is a dynamic value that can be decoded using gleam/dynamic.
///
/// ## Example
/// ```gleam
/// use body_json <- promise.await(read_json(request.body))
/// case body_json {
///   Ok(json) -> // Decode JSON using gleam/dynamic...
///   Error(ParseError(msg)) -> // Invalid JSON
///   Error(ReadError(msg)) -> // I/O error occurred
/// }
/// ```
@external(javascript, "./body_ffi.mjs", "readJson")
pub fn read_json(body: Body) -> Promise(Result(Dynamic, BodyReadError))
