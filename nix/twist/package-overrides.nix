{ pkgs, lib, ... }:
final: prev:
builtins.intersectAttrs prev {
  forge = prev.forge.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ (with pkgs; [ gitFull ]);
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
