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
  home-manager.users.v0d1ch = { ... }: {
    imports = [ inputs.self.modules.homeManager.v0d1ch ];
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
