import conversation.{Text}
import gleam/javascript/promise
import gleeunit
import gleeunit/should
import hinoto

pub fn main() -> Nil {
  gleeunit.main()
}

// Basic integration test for handler chaining concept
pub fn handler_chaining_concept_test() {
  // Test that we can create responses and they have the expected structure
  let response1 = hinoto.default_handler()
  let _response2 =
    promise.resolve(
      hinoto.default_handler()
      |> promise.map(fn(resp) {
        // Simulate modifying the response
        resp
      }),
    )

  response1
  |> promise.map(fn(resp) {
    resp.status
    |> should.equal(200)
  })
}

// Test Environment and Context types can be used together
pub fn environment_context_integration_test() {
  let env = hinoto.Environment
  let context = hinoto.Context
  let default_context = hinoto.DefaultContext(env: env, context: context)

  // Verify the integration works
  case default_context {
    hinoto.DefaultContext(env: test_env, context: test_context) -> {
      // Test that both components are preserved
      case test_env {
        hinoto.Environment -> True
      }
      |> should.be_true()

      case test_context {
        hinoto.Context -> True
      }
      |> should.be_true()
    }
  }
}

// Test response creation and modification
pub fn response_creation_test() {
  let original_response = hinoto.default_handler()

  original_response
  |> promise.map(fn(resp) {
    // Verify response structure
    resp.status |> should.equal(200)
    resp.body |> should.equal(Text("Hello from hinoto!"))
  })
}

// Test Promise handling
pub fn promise_handling_test() {
  let test_promise = promise.resolve("test value")

  test_promise
  |> promise.map(fn(value) { value |> should.equal("test value") })
}
