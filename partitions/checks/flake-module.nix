{ inputs, ... }:
{
  imports = [
    inputs.git-hooks.flakeModule

  ];
  perSystem =
    { pkgs, lib, ... }:
    {
      pre-commit.settings.hooks = {
        # lint shell scripts
        nil.enable = true;

      };
      devShells.default = pkgs.gdb;

    };
}
