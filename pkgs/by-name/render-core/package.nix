{
  stdenv,
  fetchFromGitea,
  mupdf-headless,
  pkg-config,
}:

let
  version = "0-unstable-2026-02-16";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "divyaranjan";
    repo = "emacs-reader";
    rev = "a76b1a0e13774be57bed186edf1e5bee8eeb0a56";
    hash = "sha256-pC51uw6xSB6ZuGyxAJAYUT3SInC4T3SDcb+haPy/b6o=";
  };
in
stdenv.mkDerivation {
  inherit version src;
  pname = "render-core";

  strictDeps = true;

  buildFlags = [
    "CC=cc"
    "USE_PKGCONFIG=yes"
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ mupdf-headless ];

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/lib/ render-core${stdenv.targetPlatform.extensions.sharedLibrary}

    runHook postInstall
  '';
}
