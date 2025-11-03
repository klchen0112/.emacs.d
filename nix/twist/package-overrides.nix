{ pkgs, ... }:
final: prev: {
  inherit (pkgs.emacs.pkgs)
    pdf-tools
    emms
    rime
    magit
    forge
    ;

}
