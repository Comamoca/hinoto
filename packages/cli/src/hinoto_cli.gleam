import gleam/io
import gleam_community/ansi

pub fn main() -> Nil {
  io.println(
    "Hello! Please run " <> ansi.pink("gleam run -m hinoto/cli -- --help"),
  )
}
