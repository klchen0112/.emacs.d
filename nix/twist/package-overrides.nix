{ pkgs, ... }:
final: prev: {
  inherit (pkgs.kl-emacs.pkgs)
    pdf-tools
    emms
    rime
    telega
    ;
 forge = prev.forge.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ (with pkgs; [ gitFull ]);
  });

}
