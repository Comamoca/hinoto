import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

// Basic test to ensure the module compiles
pub fn mist_server_test() {
  1 + 1
  |> should.equal(2)
}
