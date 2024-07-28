{ config, pkgs, nixvim,  ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      git
      neovide
      zellij
      gnomecast
      vlc
      google-chrome
      libstdcxx5
      lazygit
      wget
      signal-desktop
      spotify
      viber
      pam_u2f
      pinentry-curses
      pinentry-emacs
      gcc9
      xorg.libxcb
      xdotool
      rclone
      bc
      multimarkdown
      trezor-suite
      trezorctl
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
      lua
      screen
      slack
      discord
      anytype
      git-absorb
      obsidian
      ollama
      nixvim.packages.${system}.default
    ];

  };
}
