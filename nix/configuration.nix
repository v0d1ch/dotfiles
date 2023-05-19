{ config, pkgs, lib, ... }:

let unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./vim.nix
      <home-manager/nixos> 
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Belgrade";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.autoLogin = { enable = true; user = "v0d1ch"; };
  services.xserver.displayManager.defaultSession = "none+xmonad";
  services.xserver.displayManager.session = [
      {
        manage = "desktop";
        name = "xsession";
        start = ''exec $HOME/.xsession'';
      }
    ];
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [
    "electron-12.2.3"
    "qtwebkit-5.212.0-alpha4"
  ];

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
      sha256 = "0zdl850f2id6ql022f50yych28lgj3k2vnzr1269xf25ikrmlb2s";
    }
    ))

    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
      sha256 = "0n9a59nb2ki4bap2pvv365804p5crwzm5viwc0dhvsxqvn2qsnyi";
    }))
  ];
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
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.guest.enable = true;
  virtualisation.virtualbox.guest.x11 = true;
  users.extraGroups.vboxusers.members = [ "v0d1ch" ];

  fonts.fonts = with pkgs; [
    fira-code
    fira-code-symbols
    dina-font
    open-sans
    ubuntu_font_family
    hasklig
    iosevka
    font-awesome
  ];

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.emacs = { 
    enable = true;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.

  users.defaultUserShell = pkgs.fish; 

  users.users.v0d1ch = {
    shell = pkgs.fish;
    isNormalUser = true;
    description = "Sasha Bogicevic";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDnCLEXU8AQIhF2EsUK0JCtmzEa/Byd+2vvsHKtr+csB/CSjBMqxCYo8o647XEfLR0WRMCUaB8zJzpCJ5IPy/uyxHvarDfFpYzUwO29Q0wPFJq2P46zjLLcMKg9rUrY8Eii3tKqy9A6PtnaCBNwHhni5aZmHT92Wx4/XgaVGSb4TEXPErCQiT6wyvf21lXeKxjipojYXCL/nrN5jBBiJ53VFSt7myj0TWgkcDDvGJVuE7mgUTEySlmfwQwLd/42PoSuitN4e86SzuCN4AFa4cGQeJRGJ+aDsF3JhNOBuDYjFlMJseooMdvR9DhTq263M+D7w3fpJBmRBXLdXj3GoHpvXh6L4LxP08dd6D4AdcDPZHwEkpd1pDaGQL/PuTDqpug7x5/OWVcLNVlnG0AXGlEFOVBQ4pUNwQ+xHvI1pMKl0I4JYBPEU/Ul2qX37tVhwQol3k9n5U/K8iJGTEyOO/ipr4uz2uQoeyVOXRSObl+pjlzGYfF7IG7/idcNfYUg6Tk= v0d1ch@nixos"
      ];

  };
  
  qt5 = {
    enable = true;
    platformTheme = "gtk2";
    style = "gtk2";
  };
     
  environment.variables.EDITOR = "vim";
  environment.systemPackages = with pkgs; [
      lazygit
      vim 
      wget
      # emacsNativeComp
      emacsGit
      unstable.google-chrome
      discord
      signal-desktop
      spotify
      postman
      viber
      pam_u2f
      pinentry-curses
      pinentry-emacs
      gcc8
      xorg.libxcb
      xdotool
      unstable.zellij
      rclone
      etcher
      vscode
      bc
      multimarkdown
    ];

  home-manager.users.v0d1ch = { pkgs, ... }: {
  home.stateVersion = "22.11";
  home.packages = with pkgs; [
       spacevim
       firefox
       libreoffice
       virtualbox
       caffeine-ng
       dbeaver
       kazam
       vokoscreen
       kdenlive
       xscreensaver
       trayer
       arandr
       xclip
       zip
       unzip
       jq
       lsof
       qbittorrent
       nicotine-plus
       termonad
       keepassxc
       openvpn
       docker
       docker-compose
       xmobar
       ripgrep
       fd
       lorri
       xsel
       htop
       dmenu
       haskellPackages.yeganesh
       eva
       rustup
       alacritty
       speechd
       btop
       lsix
       simplescreenrecorder
       feh
       copyq
       meld
       cachix
       haskell.compiler.ghc8107
       gnome.eog
       clementine
       flameshot 
       fx

       # Yubico's official tools
       yubikey-manager
       yubikey-manager-qt
       yubikey-personalization
       yubikey-personalization-gui
       yubico-piv-tool
       yubioath-desktop

      #  (haskell-language-server.override { supportedGhcVersions = [ "8107" ]; })
     ];
  
     services.lorri = {
      enable = true;
     }; 

     services.gpg-agent = {
       enable = true;
       enableSshSupport = true;
       defaultCacheTtl = 1800;
     };
     programs.git = {
         enable = true;
         aliases = {
           st = "status";
           ca = "commit --amend --no-edit";
           bl = "branch -r --sort=-committerdate --format='%(HEAD)%(color:yellow)%(refname:short)|%(color:bold green)%(committerdate:relative)|%(color:blue)%(subject)|%(color:magenta)%(authorname)%(color:reset)' --color=always";
           lol = "log --graph --decorate --oneline --abbrev-commit";
           lola = "log --graph --decorate --oneline --abbrev-commit --all";
           hist = "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";
           lg = "log --color --graph --pretty=format:'%Cred%h$Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --";
           recent = "for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'";
           work = "log --pretty=format:'%h%x09%an%x09%ad%x09%s'";
         };
         ignores = [ "TAGS" ];
         # userEmail = "sasa.bogicevic@pm.me";
         userEmail = "sasha.bogicevic@iohk.io";
         userName = "Sasha Bogicevic";
         signing = { 
           signByDefault = true;
           key = "8FE67EA9460B6F07";
         };
         extraConfig = {
           core = {
             editor = "vim";
           };
           pull = {
             rebase = true;
           };
         };
     };

     programs.starship = {
       enable = true;
       enableFishIntegration = true;
       settings = {
         add_newline = true;
       };
     };

     programs.direnv = {
       enable = true;
       nix-direnv.enable = true;
     };
     programs.fish = {
       enable = true;
       package = pkgs.fish;
       # nohup rclone mount google_drive: ~/Documents/google-drive-local >/dev/null 2>&1
       shellInit = '' 
         source ~/code/scripts/push.sh
        '';
     };

     programs.fzf = {
       enable = true;
     };


     programs.tmux = {
        enable = true;
        shortcut = "Space"; # Use Ctrl-a
        baseIndex = 1; # Widows numbers begin with 1
        keyMode = "vi";
        customPaneNavigationAndResize = true;
        aggressiveResize = true;
        historyLimit = 100000;
        resizeAmount = 5;
        escapeTime = 0;
        plugins = with pkgs; [
          tmuxPlugins.resurrect
          tmuxPlugins.yank
        ];
        extraConfig = ''
          set -g default-terminal "tmux-256color"
          set -ga terminal-overrides ",*256col*:Tc"
          # Fix environment variables
          set-option -g update-environment "SSH_AUTH_SOCK \
                                            SSH_CONNECTION \
                                            DISPLAY"

          # Mouse works as expected
          set-option -g mouse on

          # Use default shell
          set-option -g default-shell ''${SHELL}

          # Extra Vi friendly stuff
          # y and p as in vim
          bind Escape copy-mode
          unbind p
          bind p paste-buffer
          bind-key -T copy-mode-vi 'v' send -X begin-selection
          bind-key -T copy-mode-vi 'C-v' send -X rectangle-toggle
          #bind-key -T copy-mode-vi 'y' send -X copy-pipe-and-cancel
          bind-key -T copy-mode-vi 'y' send -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
          bind-key -T copy-mode-vi 'Space' send -X halfpage-down
          bind-key -T copy-mode-vi 'Bspace' send -X halfpage-up
          bind-key -Tcopy-mode-vi 'Escape' send -X cancel

          # easy-to-remember split pane commands
          bind | split-window -h -c "#{pane_current_path}"
          bind - split-window -v -c "#{pane_current_path}"
          bind c new-window -c "#{pane_current_path}"

          # Because P is used for paste-buffer
          bind N previous-window
          # source-file "/home/v0d1ch/.tmux-themepack/default.tmuxtheme"
          source-file ~/home/v0d1ch/.tmux/tmux-tokyo-night/tokyonight.tmuxtheme
        '';

     };

     services.stalonetray = {
        enable = true;
        config = {
         geometry = "5x1-500+0";
         decorations = null;
         icon_size = 12;
         sticky = true;
         background = "#2E3440";
        };
     };
  };

  services.udev.packages = [ pkgs.yubikey-personalization ];  
  services.pcscd.enable = true;
  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "gtk2";
  };

  services.dbus.packages = [ pkgs.gcr ];

  services.openssh.enable = true;

  nix.settings.trusted-public-keys = [
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "loony-tools:pr9m4BkM/5/eSTZlkQyRt57Jz7OMBxNSUiMC4FkcNfk="
    "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI=" 
  ];

  nix.settings.substituters = [
    "https://cache.iog.io"
    "https://cache.nixos.org" 
    "https://cache.zw3rk.com"
    "https://nixcache.reflex-frp.org"
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = ["root" "v0d1ch"];

  system.stateVersion = "22.11";

}
