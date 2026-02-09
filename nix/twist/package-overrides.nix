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
  reader = prev.reader.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ (with pkgs; [ breakpointHook ]);
    files = ''(:defaults "${lib.getLib pkgs.render-core}/lib/render-core.*"))'';
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
