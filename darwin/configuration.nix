{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    # Makes nix-installed GUI apps (environment.systemPackages) visible to
    # Spotlight/Launchpad via trampolines instead of symlinks
    inputs.mac-app-util.darwinModules.default
  ];

  # Apple Silicon; use "x86_64-darwin" on an Intel Mac.
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # If Nix was installed with the Determinate installer, it manages the nix
  # daemon itself — uncomment this so nix-darwin doesn't fight over it:
  # nix.enable = false;

  # Adjust these two if the macOS account name is not v0d1ch.
  system.primaryUser = "v0d1ch";
  users.users.v0d1ch = {
    name = "v0d1ch";
    home = "/Users/v0d1ch";
  };

  home-manager.backupFileExtension = "hm-backup";
  home-manager.useGlobalPkgs = true;
  home-manager.extraSpecialArgs = { inherit inputs; };
  # Same trampoline treatment for apps installed via home.packages
  # (keepassxc, ghostty, obsidian, ...), which is where most GUI apps live
  home-manager.sharedModules = [
    inputs.mac-app-util.homeManagerModules.default
  ];
  home-manager.users.v0d1ch = { lib, ... }: {
    imports = [ inputs.self.modules.homeManager.v0d1ch ];

    # macOS-only: sign with a local software key instead of the YubiKey-backed
    # key from modules/home.nix, since that key's private material lives only
    # on the physical token and isn't present on this machine. nixos and
    # nixos-yoga are untouched — they still use the shared module's key.
    programs.git.signing.key = lib.mkForce "C574785FF89B8E25";

    # File sync with the desktop, which runs syncthing as a NixOS system
    # service. Runs here as a launchd agent (starts at login). Pair the
    # devices once in the GUI at http://127.0.0.1:8384; see docs/sync-setup.md.
    services.syncthing.enable = true;
  };

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    open-sans
    hasklig
    iosevka
    font-awesome
  ];

  # GUI apps whose nixpkgs build is Linux-only get installed through Homebrew
  # casks instead (each is marked with its cask name in modules/home.nix).
  # Requires Homebrew to be installed first (https://brew.sh); set
  # homebrew.enable = false if you'd rather skip it.
  homebrew = {
    enable = true;
    casks = [
      "keepassxc"   # official build; the nixpkgs darwin build lacks YubiKey support
      "firefox"
      "google-chrome"
      "brave-browser"
      "vlc"
      "libreoffice"
      "signal"
      "viber"
      "protonvpn"
      "trezor-suite"
      "orcaslicer"
      "yubico-authenticator"
    ];
  };

  # Tiling window manager. Alt is the main modifier since Cmd is reserved by
  # macOS and most apps. See https://nikitabobko.github.io/AeroSpace/guide
  services.aerospace = {
    enable = false;
    settings = {
      gaps = {
        outer.left = 8;
        outer.bottom = 8;
        outer.top = 8;
        outer.right = 8;
        inner.horizontal = 8;
        inner.vertical = 8;
      };

      mode.main.binding = {
        alt-enter = "exec-and-forget open -a Ghostty";
        alt-q = "close";
        alt-slash = "layout tiles horizontal vertical";
        alt-comma = "layout accordion";
        alt-shift-space = "layout floating tiling";

        # Focus/move, vim-style and arrow keys
        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";
        alt-left = "focus left";
        alt-down = "focus down";
        alt-up = "focus up";
        alt-right = "focus right";

        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";

        alt-minus = "resize smart -50";
        alt-equal = "resize smart +50";

        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";
        alt-6 = "workspace 6";
        alt-7 = "workspace 7";
        alt-8 = "workspace 8";
        alt-9 = "workspace 9";
        alt-0 = "workspace 10";

        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";
        alt-shift-5 = "move-node-to-workspace 5";
        alt-shift-6 = "move-node-to-workspace 6";
        alt-shift-7 = "move-node-to-workspace 7";
        alt-shift-8 = "move-node-to-workspace 8";
        alt-shift-9 = "move-node-to-workspace 9";
        alt-shift-0 = "move-node-to-workspace 10";

        alt-tab = "workspace-back-and-forth";
        alt-shift-semicolon = "mode service";
      };

      # Secondary mode for less-frequent commands: alt-shift-; then a key,
      # esc/mode main to leave it.
      mode.service.binding = {
        esc = [ "reload-config" "mode main" ];
        r = [ "flatten-workspace-tree" "mode main" ];
        f = [ "layout floating tiling" "mode main" ];
        backspace = [ "close-all-windows-but-current" "mode main" ];
      };
    };
  };

  environment.variables.EDITOR = "nvim";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "v0d1ch" ];

  nix.settings.trusted-public-keys = [
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "cardano-scaling.cachix.org-1:RKvHKhGs/b6CBDqzKbDk0Rv6sod2kPSXLwPzcUQg9lY="
  ];

  nix.settings.substituters = [
    "https://cache.iog.io"
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
    "https://cardano-scaling.cachix.org"
  ];

  # Used for backwards compatibility; read the nix-darwin changelog
  # before changing.
  system.stateVersion = 6;
}
