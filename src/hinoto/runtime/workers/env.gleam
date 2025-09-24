import gleam/javascript/promise.{type Promise}
import hinoto.{type Environment}

@external(javascript, "../ffi.workers.mjs", "env_get")
pub fn get(env: Environment, key: String) -> Promise(Result(String, Nil))

@external(javascript, "../ffi.workers.mjs", "env_set")
pub fn set(
  env: Environment,
  key: String,
  value: String,
) -> Promise(Result(Nil, Nil))
