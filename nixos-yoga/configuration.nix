# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, nixvim, inputs, ... }:

{
  imports = [
    inputs.self.modules.nixos.v0d1ch 
    inputs.home-manager.nixosModules.default
  ];
  
  home-manager.users.v0d1ch = {...}:{
    imports = [inputs.self.modules.homeManager.v0d1ch];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = "nix-command flakes";

  networking.hostName = "nixos-yoga"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Belgrade";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.v0d1ch = {
    isNormalUser = true;
    description = "Sasha Bogicevic";
    extraGroups = [ "networkmanager" "wheel" "docker" "audio" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  services.trezord.enable = true;
  services.udev.packages = 
    [ pkgs.yubikey-personalization 
      pkgs.trezor-udev-rules
    ];  
  services.pcscd.enable = true;

  services.avahi.enable = true;

  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

  # programs.fish.enable = true;
  # programs.zsh.enable = true;
  programs.dconf.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-gtk2;
  };

  services.dbus.packages = [ pkgs.gcr ];

  services.openssh.enable = true;

  services.keybase.enable = true; 
  services.kbfs.enable = true; 
  services.tailscale.enable = true;
  hardware.keyboard.zsa.enable = true;

  virtualisation.docker.enable = true;

  nix.settings.trusted-public-keys = [
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI=" 
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "cardano-scaling.cachix.org-1:RKvHKhGs/b6CBDqzKbDk0Rv6sod2kPSXLwPzcUQg9lY="
  ];

  nix.settings.substituters = [
    "https://cache.iog.io"
    "https://cache.nixos.org" 
    "https://nixcache.reflex-frp.org"
    "https://nix-community.cachix.org"
    "https://cardano-scaling.cachix.org"
  ];

  system.stateVersion = "25.05"; # Did you read the comment?

}
