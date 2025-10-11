{ pkgs, ... }:
final: prev: {
  inherit (pkgs.emacsPackages) pdf-tools emms;

  forge = prev.forge.overrideAttrs (o: {
    buildInputs = o.buildInputs ++ (with pkgs; [ git ]);
  });

}
