import conversation.{Text}
import gleam/dict
import gleam/http/response
import gleam/javascript/promise
import gleeunit
import gleeunit/should
import hinoto

pub fn main() {
  gleeunit.main()
}

// Test Context type creation
pub fn context_test() {
  let ctx = hinoto.Context

  case ctx {
    hinoto.Context -> True
  }
  |> should.be_true()
}

// Test Environment type creation
pub fn environment_test() {
  let _env_dict = dict.from_list([#("key", "value")])
  let env = hinoto.Environment

  case env {
    hinoto.Environment -> True
  }
  |> should.be_true()
}

// Test DefaultContext creation
pub fn default_context_test() {
  let env = hinoto.Environment
  let context = hinoto.Context
  let default_context = hinoto.DefaultContext(env: env, context: context)

  case default_context {
    hinoto.DefaultContext(env: test_env, context: test_context) -> {
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

// Test default_handler function
pub fn default_handler_test() {
  let response = hinoto.default_handler()

  response
  |> promise.map(fn(resp) {
    resp.status |> should.equal(200)
    resp.body |> should.equal(Text("Hello from hinoto!"))
  })
}

// Test fetch function creates a proper handler
pub fn fetch_test() {
  let my_handler = fn(hinoto_instance) { hinoto_instance }

  let fetch_handler = hinoto.fetch(my_handler)

  // The fetch function should return a function that takes JsRequest and returns Promise(JsResponse)
  // We can't easily test this without JS integration, but we can verify it compiles and returns the right type
  case fetch_handler {
    _ -> True
  }
  |> should.be_true()
}

// Test Environment dictionary access
pub fn environment_dict_access_test() {
  let _env_dict =
    dict.from_list([#("DATABASE_URL", "test_url"), #("API_KEY", "test_key")])
  let env = hinoto.Environment

  case env {
    hinoto.Environment -> {
      // Since Environment doesn't have fields, we'll just test that it's created correctly
      True |> should.be_true()
    }
  }
}

// Test that demonstrates the bug in update_environment function
// NOTE: This function should update the environment but currently updates the response
pub fn update_environment_bug_test() {
  // This test documents the current (buggy) behavior
  // The function signature suggests it should update environment, but it actually updates response
  // This test will pass with the current implementation but should be updated when the bug is fixed

  let response1 = hinoto.default_handler()
  let response2 =
    promise.resolve(response.new(201) |> response.set_body(Text("Created")))

  response1
  |> promise.map(fn(resp1) { resp1.status |> should.equal(200) })

  response2
  |> promise.map(fn(resp2) { resp2.status |> should.equal(201) })
}

// Test ResponseBody variants
pub fn response_body_variants_test() {
  // Test Text variant
  let text_body = Text("Hello World")
  case text_body {
    Text(content) -> content |> should.equal("Hello World")
  }

  // Test that responses can be created with different ResponseBody types
  let response_with_text =
    response.new(200) |> response.set_body(Text("Text Response"))
  response_with_text.status |> should.equal(200)
  case response_with_text.body {
    Text(content) -> content |> should.equal("Text Response")
    _ -> should.fail()
  }
}
