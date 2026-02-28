# Copyright (C) 2023-2025 Akira Komamura
# SPDX-License-Identifier: MIT

# Provide nixpkgs overlay from this config repository
{
  overlays,
  lib-makeConfig,
}:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  inherit (lib-makeConfig)
    makeConfig
    filterReadme
    archiveFilter
    earlyFilter
    earlySelector
    featureFilter
    ;

  cfg = config.programs.emacs-twist;

  pkgs' = pkgs.extend (lib.composeManyExtensions overlays);
  emacsEdit = if cfg.serviceIntegration.enable then "emacsclient" else "emacs";
in
{
  options = {
    programs.emacs-twist.settings = {
      features = lib.mkOption {
        type = types.listOf types.str;
        description = "list of features";
        default = [ ];
      };
      defaultEditor = {
        enable = lib.mkOption {
          description = "Enable setting of emacs(client) as default editor";
          type = types.bool;
          default = true;
        };
      };
    };
  };
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf cfg.settings.defaultEditor.enable {
        home.sessionVariables.EDITOR = emacsEdit;
      })
      {
        programs.emacs-twist = {
          directory = ".local/share/emacs";
          earlyInitFile = pkgs.writeText "early-init.el" (filterReadme [
            archiveFilter
            earlySelector
            (featureFilter cfg.settings.extraFeatures)
          ]);
          createManifestFile = true;
          createInitFile = true;

          config = makeConfig {
            inherit (cfg.settings) features;
            pkgs = pkgs';
          };
        };
        services.emacs.client.enable = cfg.serviceIntegration.enable;
        home.packages =
          with pkgs;
          [
            fd
            ripgrep
            # org mode dot
            graphviz
            imagemagick
            # mpvi required
            # tesseract5
            # ffmpeg
            # poppler
            # ffmpegthumbnailer
            # mediainfo
            # sqlite
            # email
            # mu4e
            # spell check
            # hunspell
            # languagetool
            # for emacs lsp booster
            emacs-lsp-booster
            pkg-config
            hugo
            # Font families used in my Emacs config

            nerd-fonts."m+"
            # emoji
            twemoji-color-font
            noto-fonts-color-emoji # 彩色的表情符号字体

          ]
          ++ (lib.optionals pkgs.stdenv.isDarwin) [
            # pngpaste for org mode download clip
            pngpaste
            # org-reminders
          ];

      }
    ]
  );
}
