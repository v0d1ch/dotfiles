# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./cachix.nix 
      ./cache.nix 
      ./printing.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp9s0.useDHCP = true;
  networking.interfaces.wlp8s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  console.keyMap = "us";

  #fonts
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts
    dina-font
    proggyfonts
    opensans-ttf
    ubuntu_font_family
    hasklig
    iosevka
    font-awesome-ttf
  ];

  # Set your time zone.
  time.timeZone = "Europe/Belgrade";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [wget vim];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;


  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.dpi = 96;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";
  # services.xserver.desktopManager.default = "none";      # Unset the default desktop manager.
  services.xserver.windowManager = {                     # Open configuration for the window manager.
    xmonad.enable = true;                                # Enable xmonad.
    xmonad.enableContribAndExtras = true;                # Enable xmonad contrib and extras.
    xmonad.extraPackages = hpkgs: [                      # Open configuration for additional Haskell packages.
      hpkgs.xmonad-contrib                               # Install xmonad-contrib.
      hpkgs.xmonad-extras                                # Install xmonad-extras.
      hpkgs.xmonad                                       # Install xmonad itself.
    ];
  };

  services.xserver.desktopManager.xterm.enable = false;  # Disable NixOS default desktop manager.
  services.xserver.displayManager.defaultSession = "none+xmonad";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.v0d1ch = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "postgres" "docker" "scanner" "lp" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDnCLEXU8AQIhF2EsUK0JCtmzEa/Byd+2vvsHKtr+csB/CSjBMqxCYo8o647XEfLR0WRMCUaB8zJzpCJ5IPy/uyxHvarDfFpYzUwO29Q0wPFJq2P46zjLLcMKg9rUrY8Eii3tKqy9A6PtnaCBNwHhni5aZmHT92Wx4/XgaVGSb4TEXPErCQiT6wyvf21lXeKxjipojYXCL/nrN5jBBiJ53VFSt7myj0TWgkcDDvGJVuE7mgUTEySlmfwQwLd/42PoSuitN4e86SzuCN4AFa4cGQeJRGJ+aDsF3JhNOBuDYjFlMJseooMdvR9DhTq263M+D7w3fpJBmRBXLdXj3GoHpvXh6L4LxP08dd6D4AdcDPZHwEkpd1pDaGQL/PuTDqpug7x5/OWVcLNVlnG0AXGlEFOVBQ4pUNwQ+xHvI1pMKl0I4JYBPEU/Ul2qX37tVhwQol3k9n5U/K8iJGTEyOO/ipr4uz2uQoeyVOXRSObl+pjlzGYfF7IG7/idcNfYUg6Tk= v0d1ch@nixos"
      ];
  };

  users.extraUsers.v0d1ch = {
    shell = pkgs.fish;
  };

  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = ["nvidia" ];
  hardware.opengl.driSupport32Bit = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.optimus_prime = {
    enable = true;
    nvidiaBusId = "PCI:01:00:0";
    intelBusId = "PCI:00:02:0";
  };


  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "root" "v0d1ch" ];

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_11;
    dataDir = "/tmp/postgres";
    enableTCPIP = true;
    settings = { 
      logging_collector = true;
      log_statement = "all";
      log_duration = true;
      log_directory = "/tmp/postgres";
      log_filename = "postgresql.log";
    };

    authentication = pkgs.lib.mkForce ''
      local   all             all                                     trust
      host    all             all             127.0.0.1/32            trust
      host    all             all             ::1/128                 trust
    '';
    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE ROLE banyan_backend WITH LOGIN PASSWORD 'banyan_backend' CREATEDB;
      CREATE DATABASE banyan_backend;
      GRANT ALL PRIVILEGES ON DATABASE banyan_backend TO banyan_backend;
      CREATE ROLE banyan_backend_test WITH LOGIN PASSWORD 'banyan_backend' CREATEDB;
      CREATE DATABASE banyan_backend_test;
      GRANT ALL PRIVILEGES ON DATABASE banyan_backend_test TO banyan_backend;

      CREATE ROLE devnull WITH LOGIN PASSWORD 'devnull' CREATEDB;
      CREATE DATABASE devnull;
      GRANT ALL PRIVILEGES ON DATABASE devnull TO devnull;
    '';
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}

