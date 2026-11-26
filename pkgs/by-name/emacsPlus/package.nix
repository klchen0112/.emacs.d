{
  stdenv,
  emacs-igc,
  emacs-igc-pgtk,
}:
if stdenv.hostPlatform.isLinux then emacs-igc-pgtk else emacs-igc
