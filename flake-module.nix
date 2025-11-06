# SPDX-FileCopyrightText: 2025 Carson Henrich <carson03henrich@gmail.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (C) 2024-2025 Akira Komamura
# SPDX-License-Identifier: MIT

{
  lib,
  inputs,
  withSystem,
  ...
}:
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
    self.overlays.default
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
    overlays.default =

      final: prev:
      withSystem prev.stdenv.hostPlatform.system (
        { config, ... }:
        {
          emacsIGC = config.packages.emacsIGC;
          org-reminders = config.packages.org-reminders;
          kl-emacs = config.packages.kl-emacs;
          initEl = config.packages.initEl-all-features;
          earlyInitEl = config.packages.earlyInitEl-all-features;
          emacs-env-all-features = config.packages.emacs-env-all-features;
          emacs-temp-all-features = config.packages.emacs-temp-all-features;
        }
      );
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
        overlays = overlays ++ [
          (final: prev: {
            org-reminders = config.packages.org-reminders;
            kl-emacs = config.packages.kl-emacs;
            initEl = config.packages.initEl-all-features;
            earlyInitEl = config.packages.earlyInitEl-all-features;
            emacs-env-all-features = config.packages.emacs-env-all-features;
            emacs-temp-all-features = config.packages.emacs-temp-all-features;
          })
        ];
        inherit system;
      };
      pkgsDirectory = ./pkgs/by-name;
      packages = rec {
        kl-emacs = getEmacsFromPkgs pkgs;
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
      apps = config.packages.emacs-env-all-features.makeApps { lockDirName = "./nix/twist/lock"; };
    };
}
