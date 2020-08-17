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
  # Packages
  home.packages = with pkgs; [
    #general
    wget
    pciutils
    google-chrome
    zoom-us
    libreoffice
    skypeforlinux
    vlc
    caffeine-ng
    zlib

    # GNU > BSD :)
    coreutils
    autoconf

    # utils
    thunderbird-78
    htop
    jq
    wget
    ripgrep
    ffmpeg

    # dev
    terminator
    alacritty
    tree
    jq
    ag

    dmenu
    direnv
    xorg.xrandr
    vim
    git
    tmux
    niv
    dbeaver
    virtualbox
    openvpn
    networkmanager-openvpn
    jdk11
    openvpn
    aws
    docker
    redis

    # Purescript
    psc-package
    purescript
    spago
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

  home.sessionVariables = {
    EDITOR = "nvim";
    BANYAN_PASSWORD = "P@ssword1";
    BANYAN_CACHE = "false";
    JWT_SECRET = "";
    JWT_PASSWORD = "";
    JWT_KEY = "";
    ICORE_BANK_LIST = "test";

  };

  home.file.".profile".text = ''
    # -*- mode: sh -*-
    . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
    ${sessionVarsStr}
    ${cfg.profileExtra}
  '';

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

}

