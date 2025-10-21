{ pkgs, ... }:
final: prev: {
  inherit (pkgs.emacsPackages)
    pdf-tools
    emms
    rime
    magit
    forge
    ;

}
