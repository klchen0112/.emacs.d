{ pkgs, ... }:
{
  org-noter = _: prev: {
    packageRequires = prev.packageRequires // {
      pdf-tools = "0";
    };
  };
  pdf-tools = _: prev: {
    files = prev.files // {
      "server" = "server";
    };
  };
  # The build needs the repository as-is (Makefile, src, vendor), not the
  # flattened lisp-only tree that `doTangle' produces.
  pele = _: prev: {
    doTangle = false;
  };
}
