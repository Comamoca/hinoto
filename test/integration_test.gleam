import gleam/http/request
import gleam/http/response
import gleeunit
import gleeunit/should
import hinoto

@target(javascript)
import gleam/javascript/promise

pub fn main() -> Nil {
  gleeunit.main()
}

// Test handler chaining (JavaScript target with Promise)
@target(javascript)
pub fn handler_chaining_js_test() {
  let req = request.new() |> request.set_body("test")
  let resp = hinoto.default_response()
  let hinoto_instance =
    hinoto.Hinoto(request: req, response: resp, context: Nil)

  let result_promise =
    hinoto_instance
    |> hinoto.handle(fn(_req) {
      promise.resolve(response.new(200) |> response.set_body("Step 1"))
    })

  use result <- promise.await(result_promise)
  let final_result = hinoto.set_response(result, response.new(201) |> response.set_body("Step 2"))

  final_result.response.status |> should.equal(201)
  final_result.response.body |> should.equal("Step 2")
  promise.resolve(Nil)
}

// Test context preservation through operations (JavaScript target)
@target(javascript)
pub fn context_preservation_js_test() {
  let req = request.new() |> request.set_body("test")
  let resp = response.new(200) |> response.set_body("test")
  let hinoto_instance =
    hinoto.Hinoto(request: req, response: resp, context: "my_context")

  let result_promise =
    hinoto_instance
    |> hinoto.handle(fn(_req) {
      promise.resolve(response.new(200) |> response.set_body("updated"))
    })

  use result <- promise.await(result_promise)
  result.context |> should.equal("my_context")
  promise.resolve(Nil)
}

// Test handler chaining (Erlang target - synchronous)
@target(erlang)
pub fn handler_chaining_erlang_test() {
  let req = request.new() |> request.set_body("test")
  let resp = hinoto.default_response()
  let hinoto_instance =
    hinoto.Hinoto(request: req, response: resp, context: Nil)

  let result =
    hinoto_instance
    |> hinoto.handle(fn(_req) {
      response.new(200) |> response.set_body("Step 1")
    })
    |> hinoto.set_response(response.new(201) |> response.set_body("Step 2"))

  result.response.status |> should.equal(201)
  result.response.body |> should.equal("Step 2")
}

// Test context preservation (Erlang target - synchronous)
@target(erlang)
pub fn context_preservation_erlang_test() {
  let req = request.new() |> request.set_body("test")
  let resp = response.new(200) |> response.set_body("test")
  let hinoto_instance =
    hinoto.Hinoto(request: req, response: resp, context: "my_context")

  let result =
    hinoto_instance
    |> hinoto.handle(fn(_req) {
      response.new(200) |> response.set_body("updated")
    })

  result.context |> should.equal("my_context")
}

// Test response creation and modification
pub fn response_creation_test() {
  let original_response = hinoto.default_response()

  // Verify response structure
  original_response.status |> should.equal(200)
  original_response.body |> should.equal("Hello from hinoto!")
}
