# CLI manager for the Garmin Connect IQ SDK (https://github.com/lindell/connect-iq-sdk-manager-cli).
# Downloads SDKs and device definitions used to build/simulate watch apps (see ~/code/skate-iq).
# Static Go binary from the upstream release; the homebrew tap only ships an older
# version (0.7.1) that predates macOS .dmg support, so we package it here instead.
{ stdenvNoCC, fetchurl, lib }:

stdenvNoCC.mkDerivation rec {
  pname = "connect-iq-sdk-manager";
  version = "0.8.4";

  src = fetchurl {
    url = "https://github.com/lindell/connect-iq-sdk-manager-cli/releases/download/v${version}/connect-iq-sdk-manager-cli_${version}_Darwin_ARM64.tar.gz";
    hash = "sha256-r8OQMDTsCBlC80gOwUCFnQu3MVjBprrdZLV/iPa/k2s=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 connect-iq-sdk-manager $out/bin/connect-iq-sdk-manager
    install -Dm644 completions/connect-iq-sdk-manager.zsh \
      $out/share/zsh/site-functions/_connect-iq-sdk-manager
    runHook postInstall
  '';

  meta = with lib; {
    description = "CLI to download and manage Garmin Connect IQ SDKs and devices";
    homepage = "https://github.com/lindell/connect-iq-sdk-manager-cli";
    license = licenses.mit;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "connect-iq-sdk-manager";
  };
}
