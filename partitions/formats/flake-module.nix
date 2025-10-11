{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule

  ];
  perSystem =
    { pkgs, lib, ... }:
    {
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

    };
}
