{ config, pkgs, ... }:
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
  networking.enableIPv6 = false;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.nameservers = ["8.8.8.8"];
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.autoLogin = { enable = true; user = "v0d1ch"; };
  services.xserver.displayManager.defaultSession = "none+xmonad";
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
    xkbVariant = "";
    exportConfiguration = true; 
    layout = "us,rs";
    xkbOptions = "eurosign:e, compose:menu, grp:alt_space_toggle";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.zsh; 
  users.users.v0d1ch = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "Sasha Bogicevic";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDnCLEXU8AQIhF2EsUK0JCtmzEa/Byd+2vvsHKtr+csB/CSjBMqxCYo8o647XEfLR0WRMCUaB8zJzpCJ5IPy/uyxHvarDfFpYzUwO29Q0wPFJq2P46zjLLcMKg9rUrY8Eii3tKqy9A6PtnaCBNwHhni5aZmHT92Wx4/XgaVGSb4TEXPErCQiT6wyvf21lXeKxjipojYXCL/nrN5jBBiJ53VFSt7myj0TWgkcDDvGJVuE7mgUTEySlmfwQwLd/42PoSuitN4e86SzuCN4AFa4cGQeJRGJ+aDsF3JhNOBuDYjFlMJseooMdvR9DhTq263M+D7w3fpJBmRBXLdXj3GoHpvXh6L4LxP08dd6D4AdcDPZHwEkpd1pDaGQL/PuTDqpug7x5/OWVcLNVlnG0AXGlEFOVBQ4pUNwQ+xHvI1pMKl0I4JYBPEU/Ul2qX37tVhwQol3k9n5U/K8iJGTEyOO/ipr4uz2uQoeyVOXRSObl+pjlzGYfF7IG7/idcNfYUg6Tk= v0d1ch@nixos"
      ];

  };
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-12.2.3"
    "qtwebkit-5.212.0-alpha4"
    "openssl-1.1.1u"
    "vscode-1.73.1"
  ];

  environment.variables = {
    EDITOR = "vim";
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
  };

  
  environment.systemPackages = with pkgs; [
      lazygit
      vim 
      neovim-remote
      wget
      unstable.google-chrome
      unstable.chromium
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
      unstable.gnomecast
      unstable.vlc
      xkblayout-state
      killall
  ];

  fonts.fonts = with pkgs; [
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
  home-manager.useGlobalPkgs = true;

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
         websocat
         curl
         jq
         lsof
         qbittorrent
         nicotine-plus
         termonad
         unstable.keepassxc
         openvpn
         openresolv
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
         haskellPackages.Agda
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
         gnome.gnome-terminal
         gnome.gnome-settings-daemon
         gnome.dconf-editor
         clementine
         flameshot 
         fx
         dstat
         dunst
         thefuck

         # Yubico's official tools
         yubikey-manager
         yubikey-manager-qt
         yubikey-personalization
         yubikey-personalization-gui
         yubico-piv-tool
       ];

       services.lorri = {
         enable = true;
       };

       
       services.gpg-agent = {
       enable = true;
       enableSshSupport = true;
       defaultCacheTtl = 1800;
     };
     services.dunst = {
       enable = true;
       iconTheme = {
         name = "Adwaita";
         package = pkgs.gnome3.adwaita-icon-theme;
         size = "16x16";
       };
       settings = {
         global = {
           monitor = 0;
           # geometry = "600x50-50+65";
           shrink = "yes";
           transparency = 10;
           padding = 16;
           horizontal_padding = 16;
           # font = "JetBrainsMono Nerd Font 10";
           line_height = 4;
           format = ''<b>%s</b>\n%b'';
         };
       };
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

     programs.vscode = {
       enable = true;
       extensions = with pkgs.vscode-extensions; [
         dracula-theme.theme-dracula
         vscodevim.vim
         yzhang.markdown-all-in-one
         haskell.haskell
         justusadam.language-haskell
         eamodio.gitlens
       ];
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

     programs.zsh = {
       enable = true;
       dotDir = ".config/zsh";
       shellAliases = {
         ll = "ls -l --color=tty";
       };

       history = {
             size = 10000000;
             save = 10000000;
             share = true;
             path = "$HOME/.zsh_history";
           };
       enableAutosuggestions = true;
       enableCompletion = true;
       initExtra = ''
            bindkey '^F' autosuggest-accept
            bindkey '^U' backward-kill-line
            bindkey '^A' beginning-of-line
            bindkey '^E' end-of-line
            bindkey -v
            setopt magic_equal_subst
            eval $(thefuck --alias)
            autopair-init
            zstyle -e ':completion:*' special-dirs true


        '';
       plugins = with pkgs; [
          {
            name = "formarks";
            src = fetchFromGitHub {
              owner = "wfxr";
              repo = "formarks";
              rev = "8abce138218a8e6acd3c8ad2dd52550198625944";
              sha256 = "1wr4ypv2b6a2w9qsia29mb36xf98zjzhp3bq4ix6r3cmra3xij90";
            };
            file = "formarks.plugin.zsh";
          }
          {
            name = "zsh-syntax-highlighting";
            src = fetchFromGitHub {
              owner = "zsh-users";
              repo = "zsh-syntax-highlighting";
              rev = "0.6.0";
              sha256 = "0zmq66dzasmr5pwribyh4kbkk23jxbpdw4rjxx0i7dx8jjp2lzl4";
            };
            file = "zsh-syntax-highlighting.zsh";
          }
          {
            name = "zsh-abbrev-alias";
            src = fetchFromGitHub {
              owner = "momo-lab";
              repo = "zsh-abbrev-alias";
              rev = "637f0b2dda6d392bf710190ee472a48a20766c07";
              sha256 = "16saanmwpp634yc8jfdxig0ivm1gvcgpif937gbdxf0csc6vh47k";
            };
            file = "abbrev-alias.plugin.zsh";
          }
          {
            name = "zsh-autopair";
            src = fetchFromGitHub {
              owner = "hlissner";
              repo = "zsh-autopair";
              rev = "34a8bca0c18fcf3ab1561caef9790abffc1d3d49";
              sha256 = "1h0vm2dgrmb8i2pvsgis3lshc5b0ad846836m62y8h3rdb3zmpy1";
            };
            file = "autopair.zsh";
          }
          {
            name = "zsh-autocomplete";
            src = fetchFromGitHub {
              owner = "marlonrichert";
              repo = "zsh-autocomplete";
              rev = "6d059a3634c4880e8c9bb30ae565465601fb5bd2";
              sha256 = "1h0vm2dgrmb8i2pvsgis3lshc5b0ad846836m62y8h3rdb3zmpy1";
            };
          }
          {
           # will source zsh-autosuggestions.plugin.zsh
           name = "zsh-autosuggestions";
           src = pkgs.fetchFromGitHub {
             owner = "zsh-users";
             repo = "zsh-autosuggestions";
             rev = "v0.4.0";
             sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
           };
         }
         {
            name = "powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
         }
         {
            name = "powerlevel10k-config";
            src = lib.cleanSource ./p10k-config;
            file = "p10k.zsh";
         }
       ];
     };

     programs.fzf = {
       enable = true;
     };


     programs.tmux = {
        enable = true;
        shortcut = "Space"; # Use Ctrl-space
        baseIndex = 1; # Widows numbers begin with 1
        keyMode = "vi";
        customPaneNavigationAndResize = true;
        aggressiveResize = true;
        historyLimit = 100000;
        resizeAmount = 5;
        escapeTime = 0;
        plugins = with pkgs.tmuxPlugins; [
          resurrect
          sensible
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
          set -g status-bg black
          set -g status-fg white

          # Extra Vi friendly stuff
          # y and p as in vim
          bind Escape copy-mode
          unbind p
          bind p paste-buffer
          bind-key -T copy-mode-vi 'v' send -X begin-selection
          bind-key -T copy-mode-vi 'C-v' send -X rectangle-toggle
          #bind-key -T copy-mode-vi 'y' send -X copy-pipe
          bind-key -T copy-mode-vi 'y' send -X copy-pipe 'xclip -in -selection clipboard'
          bind-key -T copy-mode-vi 'Space' send -X halfpage-down
          bind-key -T copy-mode-vi 'Bspace' send -X halfpage-up
          bind-key -Tcopy-mode-vi 'Escape' send -X cancel

          # easy-to-remember split pane commands
          bind | split-window -h -c "#{pane_current_path}"
          bind - split-window -v -c "#{pane_current_path}"
          bind c new-window -c "#{pane_current_path}"

          # Because P is used for paste-buffer
          bind N previous-window

          # source-file "/home/v0d1ch/.tmux/tmux-tomorrow/tomorrow.tmux"
          # source-file "/home/v0d1ch/.tmux/tmux-tokyo-night/tokyonight.tmuxtheme"
        '';

     };

     services.stalonetray = {
        enable = true;
        config = {
         geometry = "5x1-900+0";
         decorations = null;
         icon_size = 25;
         slot_size = 35;
         sticky = true;
         background = "#2E3440";
         icon_gravity = "W";
        };
     };
  };
  # END HOME

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
  
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
      sha256 = "08jfk327cwgqc9kalc5kii7dx3alm8w4fq19s0fss7iragb25nvy";
    }
    ))

    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
      sha256 = "01vx0jqkz5wkiilvyd98a6vnihbxlms0grcrqnyq4sqkdagip492";
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

  # virtualisation.virtualbox.host.enable = true;
  # virtualisation.virtualbox.guest.enable = true;
  # virtualisation.virtualbox.guest.x11 = true;
  # users.extraGroups.vboxusers.members = [ "v0d1ch" ];

  system.stateVersion = "22.11";

}
