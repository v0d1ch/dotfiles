{ config, pkgs, ... }:

let unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  config = {
    environment.systemPackages = with pkgs; [
      lazygit
      unstable.neovim
      unstable.neovide
      wget
      unstable.google-chrome
      unstable.chromium
      discord
      signal-desktop
      spotify
      postman
      viber
      pam_u2f
      pinentry-curses
      pinentry-emacs
      gcc8
      xorg.libxcb
      xdotool
      unstable.zellij
      rclone
      etcher
      bc
      multimarkdown
      trezor-suite
      sad
      exfat
      ntfs3g
      nvd
      whatsapp-for-linux
      texlive.combined.scheme-full
      qt5.full
      qtcreator
      brightnessctl
      acpi
      libnotify
      dbus
      wireshark
      nmap
      ettercap
      steam-run
      protonvpn-gui
      protonvpn-cli
      networkmanagerapplet
      unstable.gnomecast
      unstable.vlc
      xkblayout-state
      killall
      wireplumber
      pciutils
      alsa-tools
      alsa-utils
      sox
    ];

  };
}
