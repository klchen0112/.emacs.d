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

  mkScriptDesktopItem =
    script:
    pkgs.makeDesktopItem {
      inherit (script) name;
      desktopName = script.name;
      exec = "${script}/bin/${script.name}";
    };

  java-debug-plugin =
    pkgs.runCommand "java-debug-plugin.jar"
      {
        propagatedBuildInputs = [
          pkgs.vscode-extensions.vscjava.vscode-java-debug
        ];
      }
      ''
        jar=$(find ${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server -name "*.jar")

        ln -s "$jar" $out
      '';

  scripts = lib.map pkgs.writeShellApplication [
    {
      name = "org-agenda";
      text = ''
        emacsclient -e '(yequake-toggle "yequake-org-agenda")'
      '';
      runtimeInputs = [
        config.programs.emacs-twist.wrapper
      ];
    }
    {
      name = "emacs-launcher";
      text = ''
        emacsclient -e '(yequake-toggle "yequake-omni-launcher")'
      '';
      runtimeInputs = [
        config.programs.emacs-twist.wrapper
      ];
    }
    {
      name = "emacs-omni";
      text = ''
        emacsclient -e '(yequake-toggle "yequake-omni-preview")'
      '';
      runtimeInputs = [
        config.programs.emacs-twist.wrapper
      ];
    }
    {
      name = "org-capture";
      text = ''
        emacsclient -e '(yequake-toggle "yequake-org-capture")'
      '';
      runtimeInputs = [
        config.programs.emacs-twist.wrapper
      ];
    }
  ];

  desktopItems = lib.map mkScriptDesktopItem scripts;
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
      enableYequakeScripts = lib.mkEnableOption "Enable generation of scripts for Yequake";
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

    xdg.desktopEntries."org-protocol" = lib.mkIf cfg.settings.enableOrgProtocol {
      name = "org-protocol";
      comment = "Intercept calls from emacsclient to trigger custom actions";
      type = "Application";
      exec = "emacsclient -- %u";
      terminal = false;
      icon = "emacs";
      mimeType = [ "x-scheme-handler/org-protocol" ];
    };

    home.file.${cfg.directory + "/java-debug-plugin.jar"} = lib.mkIf cfg.settings.enableJava {
      source = java-debug-plugin;
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
      ]
      ++ (lib.optionals pkgs.stdenv.isDarwin) [
        # pngpaste for org mode download clip
        pngpaste
        # org-reminders
      ]

      ++ (lib.optionals cfg.settings.enableYequakeScripts (desktopItems ++ scripts));

    home.sessionVariables.LAUNCHER = lib.mkIf cfg.settings.enableYequakeScripts (
      lib.mkDefault "emacs-launcher"
    );

    home.sessionVariables.EDITOR = lib.mkIf cfg.settings.enableDefaultEditor (
      lib.mkDefault "emacsclient -t -a emacs"
    );
    home.sessionVariables.VISUAL = lib.mkIf cfg.settings.enableDefaultEditor (
      lib.mkDefault "emacsclient -c -a emacs"
    );

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
