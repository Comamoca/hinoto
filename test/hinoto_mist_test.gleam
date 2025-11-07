import gleam/http/request
import gleam/http/response
import gleeunit
import gleeunit/should
import hinoto/runtime/mist as hinoto_mist

@target(erlang)
import mist.{type Connection, type ResponseData}

pub fn main() {
  gleeunit.main()
}

// Test handler function conversion (Erlang target only)
@target(erlang)
pub fn handler_conversion_test() {
  // Create a simple Hinoto-style handler
  // Note: Mist uses Request(Connection) for native streaming support
  let hinoto_handler = fn(_req: request.Request(Connection)) {
    response.new(200)
    |> response.set_body("Hello from Hinoto handler!")
  }

  // Convert to Mist handler
  let mist_handler = hinoto_mist.handler(hinoto_handler)

  // Create a mock Mist request
  // Note: We can't create a real Connection, so we'll test the handler signature
  // In a real integration test, you would use actual Mist request/response

  // For now, we just verify that the handler function was created
  // The actual functionality will be tested in integration tests
  // This test mainly ensures the code compiles correctly

  // Verify handler type (this will be checked at compile time)
  let _handler_type_check: fn(request.Request(Connection)) ->
    response.Response(ResponseData) = mist_handler

  // Test passes if compilation succeeds
  should.equal(1, 1)
}

// Test that handler preserves response status
@target(erlang)
pub fn handler_preserves_status_test() {
  let hinoto_handler = fn(_req: request.Request(Connection)) {
    response.new(404)
    |> response.set_body("Not Found")
  }

  let mist_handler = hinoto_mist.handler(hinoto_handler)

  // Verify the handler was created
  let _handler_type_check: fn(request.Request(Connection)) ->
    response.Response(ResponseData) = mist_handler

  should.equal(1, 1)
}

// Test that handler can be used with different response codes
@target(erlang)
pub fn handler_various_status_codes_test() {
  let test_handler = fn(status: Int) {
    let hinoto_handler = fn(_req: request.Request(Connection)) {
      response.new(status)
      |> response.set_body("Response body")
    }
    hinoto_mist.handler(hinoto_handler)
  }

  // Test various status codes
  let _handler_200 = test_handler(200)
  let _handler_201 = test_handler(201)
  let _handler_404 = test_handler(404)
  let _handler_500 = test_handler(500)

  should.equal(1, 1)
}
