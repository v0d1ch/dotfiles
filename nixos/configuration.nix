# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.device = "/dev/nvme0n1p1";
  # boot.plymouth.enable = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; 

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Belgrade";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
# programming
      irssi
      stack2nix
      stack
      jq
      nodejs
      git
      postgresql
      redis
      dbeaver
      pgmanage
      zeal
      oh-my-zsh

#user apps
      thunderbird
      firefox
      chromium
      google-chrome
      libreoffice
      zoom-us
      skypeforlinux
      kdeApplications.spectacle
      google-play-music-desktop-player
      slack-dark
      nixnote2
      alacritty

#system apps
      zip
      unzip
      gmp
      zlib
      vim 
      (import ./vim.nix)
      tmux
      emacs 
      gparted
      dmenu
      taffybar
      scrot
      groff
      pmutils
      gnome3.dconf
      wget
      curl
      ctags
      clipmenu
      xclip 
      xsel
      lxqt.pavucontrol-qt
      virtualbox
      openvpn
      blueman
      networkmanager
      networkmanager_dmenu
      awscli
      couchdb2
      docker
      docker-compose
      openjdk11
      hyperledger-fabric

#haskell
      cabal-install
      cabal2nix
      hlint
      haskellPackages.hindent
      haskellPackages.xmobar
      haskellPackages.hasktags
      haskellPackages.yesod-bin
      haskellPackages.ghcid
      haskellPackages.stylish-haskell
      haskellPackages.hspec-discover

    # haskellPackages.stackage2nix
    # viber
    #  _1password
    # postman
    ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
   services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.autorun = true;
  services.xserver.autoRepeatDelay = 200;
  services.xserver.autoRepeatInterval = 25;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  # services.xserver.desktopManager.xfce.enable = true;
  # Enable xmonad and include extra packages
    services.xserver.windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages: [
        haskellPackages.xmonad-contrib
        haskellPackages.xmonad-extras
        haskellPackages.xmonad
      ];
    };
  # services.xserver.windowManager.i3.enable = true;
  services.xserver.videoDrivers = ["nvidia" ]; # "intel" "modesetting"
  # hardware.nvidia.optimus_prime.enable = true;
  # Bus ID of the NVIDIA GPU. You can find it using lspci
  # hardware.nvidia.optimus_prime.nvidiaBusId = "PCI:1:0:0";
  # Bus ID of the Intel GPU. You can find it using lspci
  # hardware.nvidia.optimus_prime.intelBusId = "PCI:0:2:0";
  # hardware.bumblebee.enable = true;
  services.upower.enable = true;
  services.locate.enable = true;
  systemd.services.upower.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.v0d1ch = {
    home = "/home/v0d1ch";
    isNormalUser = true;
   extraGroups = [ "wheel" "network" "uucp" "dialout" "vboxusers" "networkmanager" "docker" "audio" "video" "input" ];
  };
  
  nixpkgs.config.allowUnfree = true;

  # setup postgres db
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_10;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
      local all all trust
    '';
    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE ROLE v0d1ch WITH LOGIN PASSWORD 'v0d1ch' CREATEDB;
      CREATE DATABASE banyan_backend;
      CREATE DATABASE banyan_backend_test;
      GRANT ALL PRIVILEGES ON DATABASE banyan_backend TO v0d1ch;
      GRANT ALL PRIVILEGES ON DATABASE banyan_backend_test TO v0d1ch;
    '';
  };
   hardware = {
       nvidia = {
         modesetting = {
           enable = true;
         };
   
         optimus_prime = {
           enable = true;
           # values are from lspci
           # try lspci | grep -P 'VGA|3D'
           intelBusId = "PCI:0:2:0";
           nvidiaBusId = "PCI:1:0:0";
         };
       
       };
     };
   hardware.enableAllFirmware = true;
   hardware.pulseaudio = {
    enable = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
   };
   hardware.bluetooth.extraConfig = "
     [General]
     Enable=Source,Sink,Media,Socket
   ";
   hardware.bluetooth.enable = true;
   # hardware.pulseaudio.support32Bit = true;
   # nixpkgs.config.pulseaudio = true;
   hardware.opengl.driSupport32Bit = true;

   hardware.opengl.extraPackages = [
      pkgs.libGL_driver
      pkgs.linuxPackages.nvidia_x11.out
   ];

  hardware.brightnessctl.enable = true;
  fonts.fonts = [pkgs.google-fonts pkgs.font-awesome_4 pkgs.font-awesome_5 pkgs.nerdfonts];
  boot.extraModprobeConfig = ''
    options snd slots=snd-hda-intel
  '';
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "root" "v0d1ch" ];
  virtualisation.virtualbox.host.enableExtensionPack = true;
    fileSystems."/mnt/share" = {
      device = "//sasa-VirtualBox/home/sasa/banyan-backend";
      fsType = "cifs";
      options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

      in ["${automount_opts},credentials=/etc/nixos/smb-secrets"];
    };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
}

