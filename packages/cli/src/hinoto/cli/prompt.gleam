@external(javascript, "./prompt.ffi.mjs", "prompt")
pub fn prompt(message: String) -> String

@external(javascript, "./prompt.ffi.mjs", "confirm")
pub fn confirm(message: String) -> Bool
