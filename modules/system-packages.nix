{ flake.modules.nixos.v0d1ch = { config, pkgs, lib, inputs, ... }:

{
  config = {
    # NixOS-/Linux-only system packages. Anything that can also run on macOS
    # lives in modules/home.nix (home-manager) so the MacBook picks it up too.
    environment.systemPackages = with pkgs; [
      # --- Dev libraries & build tools (Wayland/compositor development) ---
      meson             # build system
      wayland-protocols # Wayland protocol specs
      wlroots           # compositor library
      libxcb            # XCB client library

      # --- CLI utilities ---
      killall       # kill processes by name (macOS ships its own)

      # --- Security & hardware keys ---
      pam_u2f         # U2F PAM module (login/sudo with YubiKey)
      pinentry-emacs  # pinentry inside emacs

      # --- Filesystems ---
      exfat         # exFAT tools
      ntfs3g        # NTFS driver/tools

      # --- Audio ---
      alsa-tools    # ALSA hardware tools
      alsa-utils    # alsamixer, aplay, ...

      # --- Voice dictation ---
      wtype          # type transcribed text into Wayland windows

      # --- Network tools ---
      networkmanagerapplet # nm-applet tray icon

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
    ];

  };
};
}
