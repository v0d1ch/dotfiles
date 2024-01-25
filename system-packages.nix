{ config, pkgs, ... }:

let unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  config = {
    environment.systemPackages = with pkgs; [
      neovim
      neovide
      unstable.zellij
      unstable.gnomecast
      unstable.vlc
      google-chrome
      libstdcxx5
      lazygit
      wget
      discord
      signal-desktop
      spotify
      postman
      viber
      pam_u2f
      pinentry-curses
      pinentry-emacs
      gcc9
      xorg.libxcb
      xdotool
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
