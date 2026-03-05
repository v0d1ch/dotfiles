{ flake.modules.nixos.v0d1ch = { config, pkgs, lib, inputs, ... }: 

{
  config = {
    environment.systemPackages = with pkgs; [
      vim
      lazygit
      vscode
      inputs.nixvim.packages.${system}.default
      neovide
      wget
      google-chrome
      brave
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
      openai-whisper      # Voice dictation (Python version)
      wtype               # For typing transcribed text (Wayland)
      obsidian        
      baobab
      dbeaver-bin
      ollama
      (pkgs.callPackage ../packages/qmd.nix {})
      zellij
      magic-wormhole

      kitty
      hyprland
      swww # for wallpapers
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
      xwayland
      meson
      wayland-protocols
      wayland-utils
      wl-clipboard
      wlroots
      rofi-wayland
      wofi
      grim
      swappy
      slurp
      lnav
      dconf-editor
      jujutsu
      blueman
    ];

  };
};
}
