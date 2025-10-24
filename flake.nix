{

  inputs = {
    # Nixpkgs
    nixpkgs = {
      # url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      follows = "emacs-overlay/nixpkgs";
    };
    systems.url = "github:nix-systems/default";

    # Configuration Framework
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    # Emacs Twist
    org-babel.url = "github:emacs-twist/org-babel";
    twist.url = "github:emacs-twist/twist.nix";
    twist-overrides.url = "github:emacs-twist/overrides";

    # Package registries for Twist
    melpa = {
      url = "github:melpa/melpa";
      flake = false;
    };
    gnu-elpa = {
      # Use a GitHub mirror for a higher availability
      url = "github:elpa-mirrors/elpa";
      # url = "git+https://git.savannah.gnu.org/git/emacs/elpa.git?ref=main";
      flake = false;
    };
    nongnu-elpa = {
      # Use a GitHub mirror for a higher availability
      url = "github:elpa-mirrors/nongnu";
      # url = "git+https://git.savannah.gnu.org/git/emacs/nongnu.git?ref=main";
      flake = false;
    };
    gnu-elpa-archive = {
      url = "file+https://elpa.gnu.org/packages/archive-contents";
      flake = false;
    };
    nongnu-elpa-archive = {
      url = "file+https://elpa.nongnu.org/nongnu/archive-contents";
      flake = false;
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
        pkgs-by-name-for-flake-parts.flakeModule
        ./flake-module.nix
      ];

      systems = import inputs.systems;
      partitions = {
        formatters = {

          extraInputsFlake = ./partitions/formats;
          module = {
            imports = [ ./partitions/formats/flake-module.nix ];
          };
        };

      };

      partitionedAttrs = {
        devShells = "formatters";
        formatter = "formatters";
        checks = "formatters";
      };
    };
}
