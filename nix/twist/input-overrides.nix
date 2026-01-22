{ pkgs, ... }:
{
   org-noter = _: prev: {
    packageRequires = prev.packageRequires // {
      pdf-tools = "0";
    };
  };
}
