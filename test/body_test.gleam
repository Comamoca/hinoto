/// Tests for hinoto/body module
///
/// These tests verify the Body type and its reading functions.
/// Note: Some tests require a JavaScript runtime and cannot be fully tested
/// without actual Request objects from a browser or runtime environment.

import gleeunit
import gleeunit/should

@target(javascript)
import gleam/javascript/promise

@target(javascript)
import hinoto/body as body_js

pub fn main() {
  gleeunit.main()
}

// Test reading text from StringBody (JavaScript target)
@target(javascript)
pub fn read_text_from_string_body_test() {
  let string_body = body_js.StringBody("Hello, World!")

  let result_promise = body_js.read_text(string_body)

  use result <- promise.await(result_promise)

  case result {
    Ok(text) -> text |> should.equal("Hello, World!")
    Error(_) -> panic as "Expected Ok result when reading from StringBody"
  }

  promise.resolve(Nil)
}

// Test reading text from EmptyBody (JavaScript target)
@target(javascript)
pub fn read_text_from_empty_body_test() {
  let empty_body = body_js.EmptyBody

  let result_promise = body_js.read_text(empty_body)

  use result <- promise.await(result_promise)

  case result {
    Ok(text) -> text |> should.equal("")
    Error(_) -> panic as "Expected Ok with empty string when reading from EmptyBody"
  }

  promise.resolve(Nil)
}

// Test reading bits from BitArrayBody (JavaScript target)
@target(javascript)
pub fn read_bits_from_bitarray_body_test() {
  let test_bits = <<72, 101, 108, 108, 111>>
  let bitarray_body = body_js.BitArrayBody(test_bits)

  let result_promise = body_js.read_bits(bitarray_body)

  use result <- promise.await(result_promise)

  case result {
    Ok(bits) -> bits |> should.equal(test_bits)
    Error(_) -> panic as "Expected Ok result when reading from BitArrayBody"
  }

  promise.resolve(Nil)
}

// Test reading bits from EmptyBody (JavaScript target)
@target(javascript)
pub fn read_bits_from_empty_body_test() {
  let empty_body = body_js.EmptyBody

  let result_promise = body_js.read_bits(empty_body)

  use result <- promise.await(result_promise)

  case result {
    Ok(bits) -> bits |> should.equal(<<>>)
    Error(_) -> panic as "Expected Ok with empty BitArray when reading from EmptyBody"
  }

  promise.resolve(Nil)
}

// Test reading JSON from StringBody (JavaScript target)
@target(javascript)
pub fn read_json_from_string_body_test() {
  let json_string = body_js.StringBody("{\"name\":\"test\",\"value\":123}")

  let result_promise = body_js.read_json(json_string)

  use result <- promise.await(result_promise)

  case result {
    Ok(_json) -> {
      // JSON parsing succeeded - we can't easily verify the structure
      // without dynamic decoders, but at least it didn't error
      Nil
    }
    Error(_) -> panic as "Expected Ok result when reading valid JSON from StringBody"
  }

  promise.resolve(Nil)
}

// Test reading invalid JSON from StringBody (JavaScript target)
@target(javascript)
pub fn read_invalid_json_from_string_body_test() {
  let invalid_json = body_js.StringBody("not valid json{")

  let result_promise = body_js.read_json(invalid_json)

  use result <- promise.await(result_promise)

  case result {
    Ok(_) -> panic as "Expected Error when parsing invalid JSON"
    Error(body_js.ParseError(_msg)) -> {
      // Expected ParseError
      Nil
    }
    Error(_) -> panic as "Expected ParseError specifically"
  }

  promise.resolve(Nil)
}

// Test reading JSON from EmptyBody (JavaScript target)
@target(javascript)
pub fn read_json_from_empty_body_test() {
  let empty_body = body_js.EmptyBody

  let result_promise = body_js.read_json(empty_body)

  use result <- promise.await(result_promise)

  case result {
    Ok(_) -> panic as "Expected Error when reading JSON from EmptyBody"
    Error(body_js.ParseError(_msg)) -> {
      // Expected ParseError
      Nil
    }
    Error(_) -> panic as "Expected ParseError specifically"
  }

  promise.resolve(Nil)
}

// Test Body type variants exist (JavaScript target)
@target(javascript)
pub fn body_variants_test() {
  // Just verify we can construct different Body variants
  let _string_body = body_js.StringBody("test")
  let _empty_body = body_js.EmptyBody

  // This test just verifies the types compile correctly
  Nil |> should.equal(Nil)
}

// Note: Tests for RequestBody variant would require actual JavaScript Request objects
// from a runtime environment (browser, Node.js, Deno, etc.), which are not available
// in the test environment. The FFI implementation should be tested through integration
// tests with actual HTTP servers in each runtime environment.
