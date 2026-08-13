{ lib
, fetchFromGitHub
, bun
, nodejs
, node-gyp
, python3
, pkg-config
, makeWrapper
, sqlite
, stdenv
}:

let
  version = "unstable-2025-06-26";

  src = fetchFromGitHub {
    owner = "tobi";
    repo = "qmd";
    rev = "40610c3aa65d9d399ebb188a7e4930f6628ae51c";
    hash = "sha256-IR5lIQU+hFKyZdF5BvZHAQbkVV+Yrde6bQ/2nyJARRk=";
  };

  # Fixed-output derivation: only fetches dependencies (no compilation).
  # FODs have network access but shebangs like #!/usr/bin/env node don't
  # work in the sandbox, so we skip lifecycle scripts here.
  qmd-deps = stdenv.mkDerivation {
    pname = "qmd-deps";
    inherit version src;

    nativeBuildInputs = [ bun ];

    # Prevent fixup phase from patching shebangs in $out,
    # which would embed Nix store paths (forbidden in FODs).
    dontFixup = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$TMPDIR
      bun install --frozen-lockfile --ignore-scripts
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r node_modules $out/node_modules
      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-1V/AU2Zy3FtsVXOZS+Csju0XJoyvT8U+LqHZN1BCM3g=";
  };

in stdenv.mkDerivation {
  pname = "qmd";
  inherit version src;

  nativeBuildInputs = [ makeWrapper nodejs node-gyp python3 pkg-config ];
  buildInputs = [ sqlite ];

  buildPhase = ''
    runHook preBuild

    # Copy fetched deps and make writable for compilation
    cp -r ${qmd-deps}/node_modules node_modules
    chmod -R u+w node_modules
    patchShebangs node_modules

    # Compile better-sqlite3 native addon
    cd node_modules/better-sqlite3
    node-gyp rebuild
    cd ../..

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/qmd $out/bin
    cp -r src package.json node_modules $out/lib/qmd/

    makeWrapper ${bun}/bin/bun $out/bin/qmd \
      --add-flags "$out/lib/qmd/src/qmd.ts" \
      --set LD_LIBRARY_PATH "${sqlite.out}/lib"

    runHook postInstall
  '';

  meta = {
    description = "Quick Markdown - render markdown files with live reload";
    homepage = "https://github.com/tobi/qmd";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
