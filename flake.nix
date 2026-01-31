{
  nixConfig = {
    allow-import-from-derivation = true;
    substituters = [
      "https://mirrors.cernet.edu.cn/nix-channels/store?priority=0"
      "https://nix-community.cachix.org?priority=1"
      "https://niri.cachix.org?priority=1"
      "https://cache.nixos.org?priority=1"
      "https://klchen0112.cachix.org?priority=2"
    ];
    trusted-public-keys = [
      "klchen0112.cachix.org-1:cO5Ek4gcvoWtHslHjWn9U5ymU8ZiN7+tJo0jifbtRz4="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];
    trusted-substituters = [
      "https://mirrors.cernet.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://niri.cachix.org"
      "https://klchen0112.cachix.org"
    ];
  };

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
    twist.url = "github:klchen0112/twist.nix/darwin";
    twist-overrides.url = "github:emacs-twist/overrides";

    # Package registries for Twist
    melpa = {
      url = "github:melpa/melpa";
      flake = false;
    };
    gnu-elpa = {
      # Use a GitHub mirror for a higher availability
      url = "github:emacsmirror/gnu_elpa";
      # url = "git+https://git.savannah.gnu.org/git/emacs/elpa.git?ref=main";
      flake = false;
    };
    nongnu-elpa = {
      # Use a GitHub mirror for a higher availability
      url = "github:emacsmirror/nongnu_elpa";
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
