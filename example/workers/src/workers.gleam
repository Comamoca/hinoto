import conversation.{Text}
import gleam/http/response
import gleam/javascript/promise
import gleam/string
import hinoto.{type Hinoto}
import hinoto/runtime/workers.{type WorkersContext, WorkersContext}
import hinoto/runtime/workers/env

pub fn main(hinoto: Hinoto(WorkersContext(env, ctx))) {
  use _req <- hinoto.handle(hinoto)

  let WorkersContext(context_env, _ctx) = hinoto.context
  use test_env <- promise.await(env.get(context_env, "TEST_ENV"))

  case test_env {
    Ok(test_env) -> text_h1(200, ["<h1>", test_env, "</h1>"] |> string.concat)
    Error(_) -> text_h1(404, "<h1>Hello!</h1>")
  }
}

fn text_h1(status: Int, text: String) {
  response.new(status)
  |> response.set_body(Text(text))
  |> response.set_header("content-type", "text/html")
  |> promise.resolve
}
