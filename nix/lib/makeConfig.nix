# SPDX-FileCopyrightText: 2025 Carson Henrich <carson03henrich@gmail.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

{
  inputs,
  Readme,
  lib,
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
      emacsPackage ? pkgs.emacsIGC,
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
      extraSiteStartElisp =
        let
          treesitterPackage = emacsPackage.pkgs.treesit-grammars.with-grammars (ps: [
            ps.tree-sitter-dockerfile
            ps.tree-sitter-elixir
            ps.tree-sitter-go
            ps.tree-sitter-gomod
            ps.tree-sitter-heex
            ps.tree-sitter-java
            ps.tree-sitter-javascript
            ps.tree-sitter-jsdoc
            ps.tree-sitter-json
            ps.tree-sitter-json5
            ps.tree-sitter-lua
            ps.tree-sitter-nix
            ps.tree-sitter-nu
            ps.tree-sitter-python
            ps.tree-sitter-ruby
            ps.tree-sitter-rust
            ps.tree-sitter-typescript
            ps.tree-sitter-yaml
            ps.tree-sitter-toml
          ]);
        in
        ''
          (add-to-list 'treesit-extra-load-path "${treesitterPackage}/lib")
        '';
    }).overrideScope
        (
        lib.composeExtensions inputs.twist-overrides.overlays.twistScope (
          _tself: tsuper: {
            elispPackages = tsuper.elispPackages.overrideScope (
              import ../twist/package-overrides.nix {
                inherit pkgs lib emacsPackage;
              }
            );
          }
        )
      );
}
