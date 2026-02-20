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
}
