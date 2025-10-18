{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.devshell.flakeModule
    inputs.git-hooks.flakeModule

  ];
  perSystem =
    { pkgs, lib, ... }:
    {
      pre-commit.settings.hooks = {
        # lint shell scripts
        nil.enable = true;
        conform.enable = true;
      };

      treefmt = {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = pkgs.lib.meta.availableOn pkgs.stdenv.buildPlatform pkgs.nixfmt-rfc-style.compiler;
        programs.nixfmt.package = pkgs.nixfmt-rfc-style;
        programs.shellcheck.enable = true;
        programs.deno.enable = true;
        programs.ruff.check = true;
        programs.ruff.format = true;
        settings.formatter.shellcheck.options = [
          "-s"
          "bash"
        ];

      };
      # Run `nix fmt [FILE_OR_DIR]...` to execute formatters configured in treefmt.nix.
      devshells.default = {
        commands = [
          {
            package = pkgs.treefmt;
            name = "treefmt";
          }
        ];

      };
    };
}
