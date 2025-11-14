{ pkgs, ... }:
final: prev: {
  inherit (pkgs.emacs.pkgs)
    pdf-tools
    emms
    rime
    ;
 forge = prev.forge.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ (with pkgs; [ git ]);
  });

}
