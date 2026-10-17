import argv
import clip.{type Command}
import clip/help
import gleam/io
import hinoto/cli/command

type Args {
  Init
}

pub fn main() -> Nil {
  let result =
    command()
    |> clip.help(help.simple("subcommand", "Run a subcommand"))
    |> clip.run(argv.load().arguments)

  case result {
    Error(e) -> io.println_error(e)
    Ok(args) -> runner(args)
  }
}

fn workers_command() -> Command(Args) {
  clip.subcommands([
    #("init", workers_init()),
  ])
  |> clip.help(help.simple("subcommand workers", "Run workers"))
}

fn workers_init() {
  clip.return(Init)
  |> clip.help(help.simple("subcommand workers init", "Run init"))
}

fn command() -> Command(Args) {
  clip.subcommands([
    #("workers", workers_command()),
  ])
}

fn runner(args: Args) {
  let assert Ok(Nil) = case args {
    Init -> command.workers_init()
  }

  Nil
}
