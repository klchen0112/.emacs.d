# SPDX-FileCopyrightText: 2025 Carson Henrich <carson03henrich@gmail.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (C) 2024-2025 Akira Komamura
# SPDX-License-Identifier: MIT

{ lib, inputs, ... }:
let
  lib-makeConfig = import ./nix/lib/makeConfig.nix {
    inherit inputs lib getEmacsFromPkgs;
    Readme = ./README.org;
  };
  inherit (lib-makeConfig)
    makeConfig
    filterReadme
    archiveFilter
    earlyFilter
    earlySelector
    featureFilter
    ;
  getEmacsFromPkgs = pkgs: (if pkgs.stdenv.isLinux then pkgs.emacs-igc-pgtk else pkgs.emacsIGC);
  overlays = with inputs; [
    emacs-overlay.overlays.default
    org-babel.overlays.default
  ];
in
{
  flake = {
    homeModules = {
      twist = {
        imports = [
          inputs.twist.homeModules.emacs-twist
          (import ./modules/home-module.nix {
            inherit lib-makeConfig;
            inherit overlays;
          })
        ];
      };
    };
  };

  perSystem =
    {
      lib,
      system,
      pkgs,
      config,
      ...
    }:
    {
      _module.args = {
        inherit makeConfig;
      };
      _module.args.pkgs = import inputs.nixpkgs {
        overlays = overlays;
        inherit system;
      };
      pkgsDirectory = ./pkgs;
      packages = rec {
        emacs = getEmacsFromPkgs pkgs;

        initEl-base = pkgs.writeText "init.el" (filterReadme [
          archiveFilter
          earlyFilter
          (featureFilter [ ])
        ]);
        initEl-all-features = pkgs.writeText "init.el" (filterReadme [
          archiveFilter
          earlyFilter
        ]);

        earlyInitEl-base = pkgs.writeText "early-init.el" (filterReadme [
          archiveFilter
          earlySelector
          (featureFilter [ ])
        ]);
        earlyInitEl-all-features = pkgs.writeText "early-init.el" (filterReadme [
          earlySelector
          archiveFilter
        ]);

        emacs-env-base = makeConfig {
          inherit pkgs;
        };
        emacs-env-all-features = makeConfig {
          inherit pkgs;
          initFile = pkgs.writeText "init.el" (filterReadme [
            archiveFilter
            earlyFilter
          ]);
        };

        emacs-temp-base = pkgs.callPackage ./nix/lib/tmpInitDirWrapper.nix { } {
          emacs-env = emacs-env-base;
          earlyInitEl = earlyInitEl-base;
        };
        emacs-temp-all-features = pkgs.callPackage ./nix/lib/tmpInitDirWrapper.nix { } {
          emacs-env = emacs-env-all-features;
          earlyInitEl = earlyInitEl-all-features;
        };

      };
      apps = config.packages.emacs-env-all-features.makeApps { lockDirName = "./nix/twist/.lock"; };
    };
}
