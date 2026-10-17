{
  stdenv,
  fetchpatch,
  lib,
  emacs-pgtk,
  emacs-git-pgtk,
  emacs-igc-pgtk,
  emacs-macport,
}:
if stdenv.hostPlatform.isLinux then
  emacs-igc-pgtk
else
  emacs-macport
