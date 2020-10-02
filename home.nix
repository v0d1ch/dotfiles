{ config, pkgs, lib, ... }:
let
  conf = import ./config.nix;
  vimsettings = import ./programs/vim.nix;
  unstable = pkgs.unstable;
  cfg = config.programs.bash;
  sessionVarsStr = config.lib.shell.exportAll cfg.sessionVariables;
  # put this in .profile in case home-manager refuses to work
  # export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
in
{

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Packages
  home.packages = with pkgs; [
    #general
    google-chrome
    zoom-us
    libreoffice
    skypeforlinux
    vlc
    wayland
    qt4
    # viber
    caffeine-ng
    gnome3.nautilus
    kdeApplications.spectacle
    thunderbird-78
    dbeaver
    virtualbox
    calibre
    kazam
    kdenlive
    gimp
    gscan2pdf
    xsane
    simple-scan
    at-spi2-core
    okular
    gnome3.file-roller
    weechat
    xscreensaver
    trayer
    arandr 
    autorandr
    pavucontrol
    hplip


    # utils
    gcc
    zlib
    xclip
    wget
    pwgen
    zip
    unzip
    gnumake
    pciutils
    coreutils
    autoconf
    gtk3
    python3
    glib
    htop
    jq
    wget
    ripgrep
    ffmpeg
    dmenu
    direnv
    xorg.xrandr
    any-nix-shell
    gzip
    p7zip

    # dev
    dbmate
    postman
    terminator
    alacritty
    tree
    jq
    ag
    vim
    vscode
    git
    tmux
    fzf
    fzf-zsh
    niv
    tinc
    openvpn
    networkmanager-openvpn
    jdk11
    openvpn
    docker
    docker-compose
    redis
    postgresql_11
    qutebrowser
    slack
    travis

    # Purescript
    psc-package
    purescript
    spago

    go
    ];

  # Configuration
  imports = [
    ./programs/doom-emacs.nix
    ./programs/lorri.nix
    ./programs/tmux.nix
    ./programs/haskell.nix
  ];

  #programs
  programs.git = {
    enable = true;
    aliases = {
      lol = "log --graph --decorate --oneline --abbrev-commit";
      lola = "log --graph --decorate --oneline --abbrev-commit --all";
      hist = "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";
      lg = "log --color --graph --pretty=format:'%Cred%h$Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --";
      recent = "for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'";
      work = "log --pretty=format:'%h%x09%an%x09%ad%x09%s'";
    };
    ignores = [ "TAGS" ];
    userEmail = "sasa.bogicevic@pm.me";
    userName = "Sasha Bogicevic";
    extraConfig = {
      pull = {
        rebase = true;
      };
    };

  };

  programs.neovim = vimsettings pkgs;

  programs.alacritty = {
    enable = true;
    settings = lib.attrsets.recursiveUpdate (import ./programs/alacritty.nix) {};
  };

  programs.zsh.enable = true;

  programs.zsh.oh-my-zsh = {
    enable = true;
    theme = "lambda";
    plugins = [ "git" "sudo" "docker" "tmux"];
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    SHELL = "/home/v0d1ch/.nix-profile/bin/fish";
    DOCKER_HOST="unix:///run/docker.sock";
    GOPATH="/home/v0d1ch/go";
  };

  home.file.".profile".text = ''
    # -*- mode: sh -*-
    . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
    ${sessionVarsStr}
    ${cfg.profileExtra}
  '';

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 1800;
  };

  programs.fish = {
    enable = true;
    package = pkgs.fish;
    promptInit = ''
       any-nix-shell fish --info-right | source
     '';
    shellInit = '' 
       xset r rate 250 50
       set PATH ~/.daml/bin $PATH
       set PATH ~/.daml/bin $PATH
       set NO_AT_BRIDGE 1
     '';
     #  set -x JAVA_HOME /home/v0d1ch/.nix-profile/bin/java
  };

  programs.fzf = {
    enable = true;
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = true;

      character = {
        symbol = "λ";
        error_symbol = "✗";
        use_symbol_for_status = true;
      };

      cmd_duration = {
        min_time = 100;
        prefix = "underwent ";
      };

      haskell = {
        symbol = " ";
        disabled = false;
      };
    };
  };

}
