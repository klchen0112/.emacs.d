{
  stdenv,
  fetchpatch,
  lib,
  emacs-pgtk,
  emacs-git-pgtk,
  emacs-igc-pgtk,
  emacs-macport,
}:
if stdenv.isLinux then
  emacs-igc-pgtk
else
  emacs-macport
