{ pkgs, ... }:
{
  citar = _: _: {
    origin = {
      type = "github";
      owner = "emacs-citar";
      repo = "citar";
      ref = "main";
    };
  };

  citar-org-roam = _: _: {
    origin = {
      type = "github";
      owner = "emacs-citar";
      repo = "citar-org-roam";
      ref = "main";
    };
  };

}
