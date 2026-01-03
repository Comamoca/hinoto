{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    devenv.url = "github:cachix/devenv";
    nix-gleam.url = "github:arnarg/nix-gleam";
    gleam-overlay.url = "github:Comamoca/gleam-overlay";
    version-lsp.url = "github:skanehira/version-lsp";
  };

  outputs =
    inputs@{
      self,
      systems,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.git-hooks-nix.flakeModule
        inputs.devenv.flakeModule
      ];
      systems = import inputs.systems;

      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        let
          git-secrets' = pkgs.writeShellApplication {
            name = "git-secrets";
            runtimeInputs = [ pkgs.git-secrets ];
            text = ''
              git secrets --scan
            '';
          };
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.nix-gleam.overlays.default
              inputs.gleam-overlay.overlays.default
            ];
            config = { };
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              gleam = {
                enable = true;
                package = pkgs.gleam.bin.latest;
              };
            };

            settings.formatter = { };
          };

          pre-commit = {
            check.enable = true;
            settings = {
              hooks = {
                treefmt.enable = true;
                ripsecrets.enable = true;
                git-secrets = {
                  enable = true;
                  name = "git-secrets";
                  entry = "${git-secrets'}/bin/git-secrets";
                  language = "system";
                  types = [ "text" ];
                };
              };
            };
          };

          devenv.shells =

            let
              packages = with pkgs; [
                nil
                inputs.version-lsp.packages.${system}.default
                beam28Packages.rebar3
                wrangler
                mise
              ];

              languages = {
                gleam = {
                  enable = true;
                  package = pkgs.gleam.bin.latest;
                };
                erlang = {
                  enable = true;
                };
                javascript = {
                  enable = true;
                  bun.enable = true;
                };
                deno = {
                  enable = true;
                };
              };

              enterShell = '''';
            in
            {
              default = {
                inherit packages languages enterShell;
              };
            };
        };
    };
}
