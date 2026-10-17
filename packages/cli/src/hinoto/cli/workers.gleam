import filepath
import gleam/int
import gleam/io
import gleam/result
import gleam/string
import gleam/string_tree
import handles
import handles/ctx
import handles/error.{type RuntimeError}
import hinoto/cli/prompt
import simplifile
import snag
import tom

const project_config = "gleam.toml"

pub const wrangler_file_name = "wrangler.toml"

pub const workers_entry_file = "index.js"

const compatibility_date = "2023-09-22"

const wrangler_toml_template = "
name = \"{{name}}\"
main = \"{{main}}\"
compatibility_date = \"{{compatibility_date}}\"

[build]
command = \"gleam build --target javascript\"
"

const entry_point = "
import * as hinoto from '../hinoto/hinoto.mjs';
import { main } from './{{name}}.mjs';

export default {
  async fetch(req, env, ctx) {
    return await hinoto.handle_request(req, ctx, main);
  },
};"

const minimul_hander = "
import hinoto.{type DefaultContext, type Hinoto}

pub fn main(hinoto: Hinoto(DefaultContext)) -> Hinoto(DefaultContext) {
  hinoto
}
"

pub fn wrangler_toml_tempalte(name: String, main: String) {
  io.println("❇️ Generate wrangler config...")
  let assert Ok(template) =
    handles.prepare(wrangler_toml_template |> string.trim_start)
  let context =
    ctx.Dict([
      ctx.Prop("name", ctx.Str(name)),
      ctx.Prop("main", ctx.Str(main)),
      ctx.Prop("compatibility_date", ctx.Str(compatibility_date)),
    ])

  use toml_text <- result.try(handles.run(template, context, []))
  Ok(string_tree.to_string(toml_text))
}

pub fn workers_entry_point(name: String) {
  io.println("❇️ Generate entry point script...")
  let assert Ok(template) = handles.prepare(entry_point |> string.trim_start)
  let context = ctx.Dict([ctx.Prop("name", ctx.Str(name))])

  use toml_text <- result.try(handles.run(template, context, []))
  Ok(string_tree.to_string(toml_text))
}

pub fn minimum_handler() {
  io.println("❇️ Generate entry point script...")
  minimul_hander |> string.trim_start
}

pub fn generate_wrangler_config(project_name) {
  let main =
    filepath.join("build/dev/javascript", project_name)
    |> filepath.join(workers_entry_file)

  wrangler_toml_tempalte(project_name, main)
  |> snag.map_error(describe_handles_error)
}

pub fn generate_entry_point(project_name) {
  workers_entry_point(project_name)
  |> snag.map_error(describe_handles_error)
}

pub fn load_project_config() {
  io.println("⏳ Loading gleam.toml..")
  use pwd <- result.try(
    simplifile.current_directory() |> snag.map_error(simplifile.describe_error),
  )
  let toml_path = filepath.join(pwd, project_config)
  use toml_text <- result.try(
    simplifile.read(toml_path) |> snag.map_error(simplifile.describe_error),
  )
  tom.parse(toml_text) |> snag.map_error(describe_tom_parse_error)
}

pub fn get_project_name() {
  use config <- result.try(load_project_config())
  use project_name <- result.try(
    tom.get_string(config, ["name"])
    |> snag.map_error(describe_tom_get_error),
  )

  Ok(project_name)
}

pub fn overwrite_main_program(project_name, main_path) {
  let result =
    prompt.confirm(
      [
        "Do you want to overwrite "
        <> project_name
        <> ".gleam with a minimal server example?",
      ]
      |> string.concat,
    )

  case result {
    True -> {
      let assert Ok(Nil) = simplifile.write(main_path, minimum_handler())
      io.println("📝 Writing entry main program...")
    }
    False -> io.println("❌ Cancel to writing entry program...")
  }
}

pub fn describe_tom_parse_error(err: tom.ParseError) -> String {
  case err {
    tom.Unexpected(_, expected:) -> expected
    tom.KeyAlreadyInUse(_) -> "Key is already in use."
  }
}

pub fn describe_tom_get_error(err) {
  case err {
    tom.NotFound(_) -> "Value is not found."
    tom.WrongType(_, _, _) -> "Value is wrong type."
  }
}

pub fn describe_handles_error(err: RuntimeError) {
  case err {
    error.UnexpectedType(_, _, got:, expected:) ->
      "expect: " <> string.concat(expected) <> "\ngot: " <> got
    error.UnknownPartial(index:, id:) ->
      "Unknown partial" <> int.to_string(index) <> "at: " <> id
    error.UnknownProperty(index:, path:) ->
      "Unknown property"
      <> int.to_string(index)
      <> "at: "
      <> string.concat(path)
  }
}
