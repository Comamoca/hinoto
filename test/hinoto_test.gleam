import gleam/http/request
import gleam/http/response
import gleeunit
import gleeunit/should
import hinoto

@target(javascript)
import gleam/javascript/promise

pub fn main() {
  gleeunit.main()
}

// Test Hinoto type creation
pub fn hinoto_type_test() {
  let req = request.new() |> request.set_body("test request")
  let resp = response.new(200) |> response.set_body("test response")
  let ctx = Nil

  let hinoto_instance =
    hinoto.Hinoto(request: req, response: resp, context: ctx)

  hinoto_instance.request.body |> should.equal("test request")
  hinoto_instance.response.body |> should.equal("test response")
  hinoto_instance.response.status |> should.equal(200)
}

// Test default_response function
pub fn default_response_test() {
  let response = hinoto.default_response()

  response.status |> should.equal(200)
  response.body |> should.equal("Hello from hinoto!")
}

// Test set_response function
pub fn set_response_test() {
  let req = request.new() |> request.set_body("test")
  let resp1 = response.new(200) |> response.set_body("original")
  let hinoto_instance =
    hinoto.Hinoto(request: req, response: resp1, context: Nil)

  let resp2 = response.new(201) |> response.set_body("updated")
  let updated = hinoto.set_response(hinoto_instance, resp2)

  updated.response.status |> should.equal(201)
  updated.response.body |> should.equal("updated")
}

// Test set_request function
pub fn set_request_test() {
  let req1 = request.new() |> request.set_body("original")
  let resp = response.new(200) |> response.set_body("test")
  let hinoto_instance =
    hinoto.Hinoto(request: req1, response: resp, context: Nil)

  let req2 = request.new() |> request.set_body("updated")
  let updated = hinoto.set_request(hinoto_instance, req2)

  updated.request.body |> should.equal("updated")
}

// Test set_context function
pub fn set_context_test() {
  let req = request.new() |> request.set_body("test")
  let resp = response.new(200) |> response.set_body("test")
  let hinoto_instance =
    hinoto.Hinoto(request: req, response: resp, context: "old")

  let updated = hinoto.set_context(hinoto_instance, "new")

  updated.context |> should.equal("new")
}

// Test handle function with Promise (JavaScript target)
@target(javascript)
pub fn handle_promise_test() {
  let req = request.new() |> request.set_body("test request")
  let resp = response.new(200) |> response.set_body("original")
  let hinoto_instance =
    hinoto.Hinoto(request: req, response: resp, context: Nil)

  let result_promise =
    hinoto_instance
    |> hinoto.handle(fn(_req) {
      promise.resolve(response.new(201) |> response.set_body("handled"))
    })

  // Use promise.await to get the result
  use result <- promise.await(result_promise)
  result.response.status |> should.equal(201)
  result.response.body |> should.equal("handled")
  promise.resolve(Nil)
}

// Test handle function with async Promise chain (JavaScript target)
@target(javascript)
pub fn handle_async_chain_test() {
  let req = request.new() |> request.set_body("test")
  let resp = response.new(200) |> response.set_body("original")
  let hinoto_instance =
    hinoto.Hinoto(request: req, response: resp, context: Nil)

  let result_promise =
    hinoto_instance
    |> hinoto.handle(fn(req) {
      use _body <- promise.await(promise.resolve(req.body))
      promise.resolve(response.new(200) |> response.set_body("async handled"))
    })

  use result <- promise.await(result_promise)
  result.response.status |> should.equal(200)
  result.response.body |> should.equal("async handled")
  promise.resolve(Nil)
}

// Test handle function (Erlang target - synchronous)
@target(erlang)
pub fn handle_erlang_test() {
  let req = request.new() |> request.set_body("test request")
  let resp = response.new(200) |> response.set_body("original")
  let hinoto_instance =
    hinoto.Hinoto(request: req, response: resp, context: Nil)

  let result =
    hinoto_instance
    |> hinoto.handle(fn(_req) {
      response.new(201) |> response.set_body("handled")
    })

  result.response.status |> should.equal(201)
  result.response.body |> should.equal("handled")
}

// Test context preservation through handle (JavaScript target)
@target(javascript)
pub fn handle_preserves_context_js_test() {
  let req = request.new() |> request.set_body("test")
  let resp = response.new(200) |> response.set_body("original")
  let hinoto_instance =
    hinoto.Hinoto(request: req, response: resp, context: "my_context")

  let result_promise =
    hinoto_instance
    |> hinoto.handle(fn(_req) {
      promise.resolve(response.new(200) |> response.set_body("updated"))
    })

  use result <- promise.await(result_promise)
  result.context |> should.equal("my_context")
  result.request.body |> should.equal("test")
  promise.resolve(Nil)
}

// Test context preservation through handle (Erlang target)
@target(erlang)
pub fn handle_preserves_context_erlang_test() {
  let req = request.new() |> request.set_body("test")
  let resp = response.new(200) |> response.set_body("original")
  let hinoto_instance =
    hinoto.Hinoto(request: req, response: resp, context: "my_context")

  let result =
    hinoto_instance
    |> hinoto.handle(fn(_req) {
      response.new(200) |> response.set_body("updated")
    })

  result.context |> should.equal("my_context")
  result.request.body |> should.equal("test")
}

// Test error response handling (JavaScript target)
@target(javascript)
pub fn handle_error_response_js_test() {
  let req = request.new() |> request.set_body("test")
  let resp = response.new(200) |> response.set_body("original")
  let hinoto_instance =
    hinoto.Hinoto(request: req, response: resp, context: Nil)

  let result_promise =
    hinoto_instance
    |> hinoto.handle(fn(_req) {
      promise.resolve(response.new(404) |> response.set_body("Not Found"))
    })

  use result <- promise.await(result_promise)
  result.response.status |> should.equal(404)
  result.response.body |> should.equal("Not Found")
  promise.resolve(Nil)
}

// Test error response handling (Erlang target)
@target(erlang)
pub fn handle_error_response_erlang_test() {
  let req = request.new() |> request.set_body("test")
  let resp = response.new(200) |> response.set_body("original")
  let hinoto_instance =
    hinoto.Hinoto(request: req, response: resp, context: Nil)

  let result =
    hinoto_instance
    |> hinoto.handle(fn(_req) {
      response.new(500) |> response.set_body("Internal Server Error")
    })

  result.response.status |> should.equal(500)
  result.response.body |> should.equal("Internal Server Error")
}
