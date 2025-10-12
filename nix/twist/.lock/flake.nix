{
  description = "THIS IS AN AUTO-GENERATED FILE. PLEASE DON'T EDIT IT MANUALLY.";
  inputs = {
    benchmark-init = {
      flake = false;
      owner = "dholm";
      repo = "benchmark-init-el";
      type = "github";
    };
    compat = {
      flake = false;
      owner = "emacs-compat";
      repo = "compat";
      type = "github";
    };
    ef-themes = {
      flake = false;
      owner = "protesilaos";
      repo = "ef-themes";
      type = "github";
    };
    modus-themes = {
      flake = false;
      owner = "protesilaos";
      repo = "modus-themes";
      type = "github";
    };
    org = {
      flake = false;
      ref = "bugfix";
      type = "git";
      url = "https://git.savannah.gnu.org/git/emacs/org-mode.git";
    };
    org-modern = {
      flake = false;
      owner = "minad";
      repo = "org-modern";
      type = "github";
    };
    setup = {
      flake = false;
      type = "git";
      url = "https://codeberg.org/pkal/setup.el";
    };
  };
  outputs = { ... }: { };
}
