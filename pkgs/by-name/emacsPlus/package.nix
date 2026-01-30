{
  stdenv,
  fetchpatch,
  lib,
  emacs-pgtk,
  emacs-macport,
}:
if stdenv.isLinux then
  emacs-pgtk.override {
    withNativeCompilation = true;
    withMailutils = false;
  }
else
  emacs-macport
