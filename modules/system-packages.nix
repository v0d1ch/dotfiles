{ flake.modules.nixos.v0d1ch = { config, pkgs, lib, inputs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      # --- Editors & IDEs ---
      inputs.nixvim.packages.${pkgs.stdenv.hostPlatform.system}.default # my Neovim distribution (github:v0d1ch/nixvim)
      neovide       # GUI frontend for Neovim
      vim           # classic vi, always-available fallback
      vscode        # Visual Studio Code

      # --- Terminals ---
      # ghostty 1.1.3 in 25.05 is broken with GTK 4.18; pull 1.2.x from real unstable
      inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.ghostty
      inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default # tabbed terminal session manager

      # --- Version control & dev tools ---
      lazygit       # git TUI
      jujutsu       # jj, git-compatible VCS
      # hunk is not in 26.05 yet; pull the terminal diff viewer from real unstable
      inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.hunk
      dbeaver-bin   # database GUI client
      ollama        # run LLMs locally
      nvd           # diff nix closures/generations
      (pkgs.callPackage ../packages/qmd.nix {}) # local search over markdown notes

      # --- Dev libraries & build tools ---
      meson             # build system
      wayland-protocols # Wayland protocol specs
      wlroots           # compositor library
      libxcb            # XCB client library

      # --- CLI utilities ---
      bc            # arbitrary-precision calculator
      sad           # interactive search & replace (sed alternative)
      killall       # kill processes by name
      lnav          # log file navigator
      wget          # HTTP downloader

      # --- Browsers ---
      google-chrome
      brave

      # --- Communication ---
      discord
      signal-desktop
      viber
      karere        # WhatsApp client (GTK)
      irssi         # IRC client

      # --- Network tools ---
      rclone               # sync files with cloud storage
      magic-wormhole       # send files machine-to-machine with codes
      nmap                 # port scanner
      wireshark            # packet capture & analysis
      ettercap             # network sniffing/MITM toolkit
      proton-vpn           # ProtonVPN GUI
      proton-vpn-cli       # ProtonVPN CLI
      networkmanagerapplet # nm-applet tray icon

      # --- Security & hardware keys ---
      pam_u2f         # U2F PAM module (login/sudo with YubiKey)
      pinentry-curses # terminal pinentry, used by gpg-agent (home.nix)
      pinentry-emacs  # pinentry inside emacs
      trezor-suite    # Trezor hardware wallet app

      # --- Filesystems ---
      exfat         # exFAT tools
      ntfs3g        # NTFS driver/tools

      # --- Audio ---
      alsa-tools    # ALSA hardware tools
      alsa-utils    # alsamixer, aplay, ...
      sox           # audio recording/processing CLI

      # --- Voice dictation ---
      openai-whisper # speech-to-text (Python version)
      wtype          # type transcribed text into Wayland windows

      # --- Media ---
      vlc           # media player
      gnomecast     # cast video to Chromecast

      # --- Documents & writing ---
      obsidian                     # note-taking
      multimarkdown                # markdown converter
      texlive.combined.scheme-full # complete TeX Live

      # --- Wayland / Hyprland desktop ---
      # hyprland itself + its portal come from programs.hyprland (flake package) in the machine configs
      awww                   # animated wallpaper daemon (renamed from swww)
      rofi                   # app launcher
      wofi                   # app launcher (GTK)
      grim                   # screenshot grabber
      slurp                  # select screen region
      swappy                 # annotate screenshots
      wl-clipboard           # wl-copy / wl-paste
      xdg-desktop-portal-gtk # GTK portal backend (file pickers etc.)
      wayland-utils          # wayland-info diagnostics

      # --- X11 compat ---
      xdotool         # X11 input automation
      xkblayout-state # query/switch keyboard layout

      # --- System utilities ---
      brightnessctl # backlight control
      acpi          # battery/thermal status
      libnotify     # notify-send
      pciutils      # lspci
      baobab        # disk usage analyzer
      dconf-editor  # browse/edit GSettings
      blueman       # Bluetooth manager
      steam-run     # run foreign binaries in an FHS env

      # --- 3D printing ---
      orca-slicer   # 3D printer slicer
    ];

  };
};
}
