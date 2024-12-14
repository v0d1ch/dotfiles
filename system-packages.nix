{ config, pkgs, inputs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      vim
      lazygit
      inputs.nixvim.packages.${system}.default
      neovide
      wget
      google-chrome
      chromium
      discord
      signal-desktop
      spotify
      postman
      viber
      pam_u2f
      pinentry-curses
      pinentry-emacs
      xorg.libxcb
      xdotool
      rclone
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
      gnomecast
      vlc
      xkblayout-state
      killall
      wireplumber
      pciutils
      alsa-tools
      alsa-utils
      sox
      obsidian        
      baobab
      dbeaver-bin
    ];

  };
}
