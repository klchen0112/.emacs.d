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
  emacs-pgtk
#  emacs-git-pgtk.override {
#   withNativeCompilation = true;
#  withMailutils = false;
#  }
else
  emacs-macport
