{
  pkgs,
  lib,
  emacsPackage,
  ...
}:
final: prev:
builtins.intersectAttrs prev {
  #pdf-tools = prev.pdf-tools.overrideAttrs (old: {
  #  CXXFLAGS = "-std=c++17";

  #  nativeBuildInputs = [
  #    pkgs.autoconf
  #    pkgs.automake
  #    pkgs.pkg-config
  #    pkgs.removeReferencesTo
  #  ];

  #  buildInputs = old.buildInputs ++ [
  #    pkgs.libpng
  #    pkgs.zlib
  #    pkgs.poppler
  #  ];

  #  preBuild = ''
  #    ls -alh
  #    bash ./server/autobuild
  #    cp server/epdfinfo .

  #    rm -r Makefile lisp server'';

  #});
  pdf-tools = prev.pdf-tools.overrideAttrs (old: {
    nativeBuildInputs = with pkgs; [
      autoconf
      automake
      pkg-config
    ];
    buildInputs =
      old.buildInputs
      ++ (with pkgs; [
        libpng
        zlib
        poppler
      ]);
    preBuild = ''
      cd server
      ./autogen.sh
      ./configure -q
      make
      cp epdfinfo ..
      cd ..
      rm -r server
    '';
  });

  reader = prev.reader.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ (with pkgs; [ breakpointHook ]);
    files = ''(:defaults "${lib.getLib pkgs.render-core}/lib/render-core.*"))'';
  });
  # The local keyword-search CLI passed org-wiki's real qmd integration test.
  org-wiki = prev.org-wiki.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace org-wiki-qmd.el \
        --replace-fail '(defconst org-wiki-qmd--version "2.8.3"' \
                       '(defconst org-wiki-qmd--version "2.9.0"'
    '';
  });
  chai = prev.chai.overrideAttrs (old: {
    # `convert-to-org.py` extracted PDF text with the layout's visual wrapping
    # intact, so an imported book kept a newline in the middle of every
    # paragraph.  The patch joins such lines (and leaves list items alone).
    patches = (old.patches or [ ]) ++ [ ./patches/chai-unwrap-pdf-text.patch ];
  });
  # pele.el renders with a native module built from vendored Pele and QuickJS.
  # Its prebuilt download cannot run on NixOS, so build it here and let the
  # dynamic loader find Pango, Cairo and Fontconfig through the RPATH.
  pele = prev.pele.overrideAttrs (old: {
    phases = (old.phases or [ ]) ++ [ "fixupPhase" ];
    nativeBuildInputs =
      (old.nativeBuildInputs or [ ])
      ++ (with pkgs; [
        autoPatchelfHook
        pkg-config
        python3
      ]);
    buildInputs =
      (old.buildInputs or [ ])
      ++ (with pkgs; [
        cairo
        fontconfig
        freetype
        glib
        harfbuzz
        pango
      ]);
    preBuild = (old.preBuild or "") + ''
      make -j$NIX_BUILD_CORES EMACS_INCLUDE=${emacsPackage}/include
    '';
    postBuild = (old.postBuild or "") + ''
      # Keep the renderer and the upstream license notices only.
      rm -rf build src scripts test docs examples
      rm -f vendor/quickjs/*.c vendor/quickjs/*.h vendor/pele/pele.global.js
    '';
  });
  telega = prev.telega.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [
      pkgs.tdlib
      pkgs.zlib
    ];
    nativeBuildInputs = [ pkgs.pkg-config ];

    postPatch = ''
      substituteInPlace telega-customize.el \
        --replace 'defcustom telega-server-command "telega-server"' \
                  "defcustom telega-server-command \"$out/bin/telega-server\""

      substituteInPlace telega-sticker.el --replace '"dwebp' '"${pkgs.libwebp}/bin/dwebp'
      substituteInPlace telega-sticker.el --replace '"ffmpeg' '"${pkgs.ffmpeg}/bin/ffmpeg'

      substituteInPlace telega-vvnote.el --replace '"ffmpeg' '"${pkgs.ffmpeg}/bin/ffmpeg'
    '';

    postBuild = ''
      pushd server
      make
      popd
    '';

    postInstall =
      (old.postInstall or "")
      + "\n"
      + ''
        mkdir -p $out/bin
        install -m755 -Dt $out/bin server/telega-server
      '';
  });

}
