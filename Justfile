lock:
    nix run .\#lock --impure -L

# Refresh archives, bump every git package, then re-generate the lock files.
update:
    nix run .#update --impure -L
    nix flake update --flake ./nix/twist/lock
    nix run .#lock --impure -L

run:
    nix run .#emacs-temp-all-features 
