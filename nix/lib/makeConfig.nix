# SPDX-FileCopyrightText: 2025 Carson Henrich <carson03henrich@gmail.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

{
  inputs,
  Readme,
  lib,
  getEmacsFromPkgs,
}:
let
  ob = inputs.org-babel.lib;
  earlySelector = ob.selectHeadlines (ob.tag "early");
  earlyFilter = ob.excludeHeadlines (ob.tag "early");
  archiveFilter = ob.excludeHeadlines (ob.tag "ARCHIVE");
  featureFilter =
    features: ob.excludeHeadlines (s: (ob.tag "@.*" s && !lib.any (tag: ob.tag "@${tag}" s) features));
  filterReadme =
    filters:
    ob.tangleOrgBabel { processLines = lines: lib.pipe lines filters; } (builtins.readFile Readme);
in
{
  inherit
    earlySelector
    earlyFilter
    archiveFilter
    featureFilter
    filterReadme
    ;
  makeConfig =
    {
      pkgs,
      features ? [ ],
      prependToInitFile ? null,
      nativeCompileAheadDefault ? true,
      emacsPackage ? getEmacsFromPkgs pkgs,
      initFile ? (
        pkgs.writeText "init.el" (filterReadme [
          archiveFilter
          earlyFilter
          (featureFilter features)
        ])
      ),
      initFiles ?
        (lib.optional (prependToInitFile != null) (pkgs.writeText "init.el" prependToInitFile))
        ++ [
          initFile
        ],
    }:
    let
      treeSitterLoadPath = lib.pipe pkgs.tree-sitter-grammars [
        (lib.filterAttrs (name: _: name != "recurseForDerivations"))
        lib.attrValues
        (map (drv: {
          # Some grammars don't contain "tree-sitter-" as the prefix,
          # so add it explicitly.
          name = "libtree-sitter-${
            lib.pipe (lib.getName drv) [
              (lib.removeSuffix "-grammar")
              (lib.removePrefix "tree-sitter-")
            ]
          }${pkgs.stdenv.targetPlatform.extensions.sharedLibrary}";
          path = "${drv}/parser";
        }))
        (pkgs.linkFarm "treesit-grammars")
      ];
    in
    (inputs.twist.lib.makeEnv {
      inherit pkgs;
      inherit emacsPackage;
      inherit initFiles;
      inherit nativeCompileAheadDefault;
      exportManifest = true;
      extraPackages = [ "setup" ];
      initParser = inputs.twist.lib.parseSetup { inherit lib; } { };
      configurationRevision = with builtins; "${substring 0 7 (hashFile "sha256" Readme)}";
      lockDir = ../twist/lock;
      inputOverrides = import ../twist/input-overrides.nix { inherit inputs pkgs; };
      registries = import ../twist/registries.nix { inherit inputs pkgs emacsPackage; };
      extraSiteStartElisp = ''
        (add-to-list 'treesit-extra-load-path "${treeSitterLoadPath}/")
      '';
    }).overrideScope
      (
        _final: prev: {
          elispPackages = prev.elispPackages.overrideScope (
            import ../twist/package-overrides.nix {
              inherit inputs pkgs;
            }
          );
        }
      );
}
