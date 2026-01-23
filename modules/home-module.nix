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

in
{
  options = {
    programs.emacs-twist.settings = {
      features = lib.mkOption {
        type = types.listOf types.str;
        description = "List of options";
        default = [ ];
      };
      enableOrgProtocol = lib.mkEnableOption "Enable emacsclient as an org-protocol link-handler";
      enableJava = lib.mkEnableOption "Enable Java debugging support";
      enableDefaultEditor = lib.mkEnableOption "Enable setting of emacs(client) as default editor";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.emacs-twist = {
      emacsclient.enable = true;
      directory = ".local/share/emacs";
      earlyInitFile = pkgs.writeText "early-init.el" (filterReadme [
        archiveFilter
        earlySelector
        (featureFilter cfg.settings.extraFeatures)
      ]);
      createInitFile = true;
      config = makeConfig {
        inherit (cfg.settings) features;
        pkgs = pkgs';
      };
      serviceIntegration.enable = lib.mkDefault true;
      createManifestFile = true;
    };

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

    # Generate a desktop file for emacsclient
    services.emacs = lib.mkIf cfg.serviceIntegration.enable {
      enable = true;
      client = {
        enable = true;
        arguments = [
          "-r"
        ];
      };
      startWithUserSession = lib.mkDefault "graphical";
    };

  };
}
