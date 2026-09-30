# Orca (onorca.dev) — agent development environment: runs many CLI coding
# agents (Claude Code, Codex, Hermes, ...) in parallel git worktrees with a
# status dashboard, phone companion app and a headless `serve` mode.
# Not in nixpkgs; upstream ships an Electron AppImage, wrapped here. The
# binary is called `orca-ide` upstream too, to avoid the GNOME Orca screen
# reader (nixpkgs `orca`). On macOS this is the homebrew cask
# `stablyai/orca/orca` (darwin/configuration.nix). Remote/Tailscale use is
# described in docs/orca-tailscale.md.
#
# Bump: change `version`, then
#   nix store prefetch-file https://github.com/stablyai/orca/releases/download/v<version>/orca-linux.AppImage
# and paste the printed hash. The AppImage would self-update if it could
# write to itself; in the store it can't, so updates go through this file.
{ lib, appimageTools, fetchurl }:

let
  pname = "orca-ide";
  version = "1.4.217";

  src = fetchurl {
    url = "https://github.com/stablyai/orca/releases/download/v${version}/orca-linux.AppImage";
    hash = "sha256-uClD0U4BX2o8qhWMNRFaAU42ebMiUcNGqnU6CKV7MII=";
  };

  contents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  # Ship the desktop entry and icon from inside the AppImage so it shows up
  # in launchers; point the entry at our wrapper name.
  extraInstallCommands = ''
    install -Dm444 ${contents}/*.desktop -t $out/share/applications/
    substituteInPlace $out/share/applications/*.desktop \
      --replace-quiet 'Exec=AppRun' 'Exec=${pname}' \
      --replace-quiet 'Exec=orca-ide' 'Exec=${pname}'
    if [ -d ${contents}/usr/share/icons ]; then
      cp -r ${contents}/usr/share/icons $out/share/
    fi
  '';

  meta = with lib; {
    description = "Agent development environment for running fleets of parallel coding agents";
    homepage = "https://onorca.dev";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
