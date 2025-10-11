{

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";

    # Configuration Framework
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-parts,
      ...
    }@inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = with inputs; [
        flake-parts.flakeModules.partitions
      ];

      systems = import inputs.systems;
      partitions = {
        checks = {
          extraInputsFlake = ./partitions/checks;
          module = {
            imports = [ ./partitions/checks/flake-module.nix ];
          };
        };
        formatters = {

          extraInputsFlake = ./partitions/formats;
          module = {
            imports = [ ./partitions/formats/flake-module.nix ];
          };
        };

      };

      partitionedAttrs = {
        devShells = "checks";
        formatter = "formatters";
      };
    };

}
