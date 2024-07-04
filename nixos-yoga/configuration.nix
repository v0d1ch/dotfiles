{ config, pkgs, ... }:
{
  imports =
    [ 
      ./hardware-configuration.nix
      ../system-packages.nix
      ../nvim
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "nixos-yoga"; # Define your hostname.
  networking.enableIPv6 = false;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Belgrade";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.videoDrivers = ["kvm-amd"];

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.autoLogin = { enable = true; user = "v0d1ch"; };
  services.displayManager.defaultSession = "none+xmonad";
  services.xserver.dpi = 180;
  services.xserver.displayManager.session = [
      {
        manage = "desktop";
        name = "xsession";
        start = ''exec $HOME/.xsession'';
      }
  ];

  services.xserver = {
    enable = true;
    xkb.variant = "";
    exportConfiguration = true; 
    xkb.layout = "us,rs";
    xkb.options = "eurosign:e, compose:menu, grp:alt_space_toggle";
  };

  services.printing.enable = true;

  sound.enable = true;

  security.rtkit.enable = true;

  hardware.pulseaudio.enable = false;

  boot.extraModprobeConfig = ''
    options snd slots=snd-hda-intel enable=0,1
  '';

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = false;
  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.zsh; 
  users.users.v0d1ch = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "Sasha Bogicevic";
    extraGroups = [ "networkmanager" "wheel" "docker" "audio" ];
    openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDnCLEXU8AQIhF2EsUK0JCtmzEa/Byd+2vvsHKtr+csB/CSjBMqxCYo8o647XEfLR0WRMCUaB8zJzpCJ5IPy/uyxHvarDfFpYzUwO29Q0wPFJq2P46zjLLcMKg9rUrY8Eii3tKqy9A6PtnaCBNwHhni5aZmHT92Wx4/XgaVGSb4TEXPErCQiT6wyvf21lXeKxjipojYXCL/nrN5jBBiJ53VFSt7myj0TWgkcDDvGJVuE7mgUTEySlmfwQwLd/42PoSuitN4e86SzuCN4AFa4cGQeJRGJ+aDsF3JhNOBuDYjFlMJseooMdvR9DhTq263M+D7w3fpJBmRBXLdXj3GoHpvXh6L4LxP08dd6D4AdcDPZHwEkpd1pDaGQL/PuTDqpug7x5/OWVcLNVlnG0AXGlEFOVBQ4pUNwQ+xHvI1pMKl0I4JYBPEU/Ul2qX37tVhwQol3k9n5U/K8iJGTEyOO/ipr4uz2uQoeyVOXRSObl+pjlzGYfF7IG7/idcNfYUg6Tk= v0d1ch@nixos"
      ];

  };
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-12.2.3"
    "electron-19.1.9"
    "qtwebkit-5.212.0-alpha4"
    "openssl-1.1.1w"
    "vscode-1.73.1"
  ];

  environment.variables = {
    EDITOR = "nvim";
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
  };

  

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    dina-font
    open-sans
    ubuntu_font_family
    hasklig
    iosevka
    font-awesome
    nerdfonts
  ];


  # HOME
  home-manager.users.v0d1ch = { ... }: {
    imports = [ /home/v0d1ch/code/dotfiles/home.nix ];
  };
  home-manager.users.root = { ... }: {
    imports = [ /home/v0d1ch/code/dotfiles/home.nix ];
  };

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
  programs.zsh.enable = true;
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

  nix.settings.trusted-public-keys = [
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI=" 
  ];

  nix.settings.substituters = [
    "https://cache.iog.io"
    "https://cache.nixos.org" 
    "https://nixcache.reflex-frp.org"
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = ["root" "v0d1ch"];
  
  nixpkgs.overlays = [ ];

  services.xserver.windowManager = {
    xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages: [
        haskellPackages.dbus
        haskellPackages.List
        haskellPackages.monad-logger
        haskellPackages.xmonad
      ];
     };
  };


  virtualisation.docker.enable = true;

  system.stateVersion = "22.11";

}
