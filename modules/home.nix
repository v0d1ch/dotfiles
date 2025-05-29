{ flake.modules.homeManager.v0d1ch = { config, pkgs, lib, inputs, ... }: 

{
   home.stateVersion = "24.11";
     home.packages = with pkgs; [
         firefox
         libreoffice
         virtualbox
         caffeine-ng
         kazam
         vokoscreen
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
         haskellPackages.cabal-install
         eog
         gnome-terminal
         clementine
         flameshot
         fx
         dunst
         thefuck

         # Yubico's official tools
         yubikey-manager
         yubikey-personalization
         yubikey-personalization-gui
         yubico-piv-tool
         # yubioath-desktop
         # yubioath-flutter
         #  (haskell-language-server.override { supportedGhcVersions = [ "8107" ]; })
         protonvpn-gui
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
         package = pkgs.adwaita-icon-theme;
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
           bl = "branch -r --sort=-committerdate --format='%(HEAD)%(color:yellow)%(refname:short)|%(color:bold green)%(committerdate:relative)|%(color:blue)%(subject)|%(co
lor:magenta)%(authorname)%(color:reset)' --color=always";
           lol = "log --graph --decorate --oneline --abbrev-commit";
           lola = "log --graph --decorate --oneline --abbrev-commit --all";
           hist = "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";
           lg = "log --color --graph --pretty=format:'%Cred%h$Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --";
           recent = "for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color
:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'";
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
             editor = "nvim";
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
     programs.zsh = {
       enable = true;
       dotDir = ".config/zsh";
       shellAliases = {
         ll = "ls --all --color=tty";
       };

       history = {
             size = 10000000;
             save = 10000000;
             share = true;
             path = "$HOME/.zsh_history";
           };
       autosuggestion.enable = true;
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
            set +o prompt_cr +o prompt_sp


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
          yank
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
          set -g status-bg red
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
        '';

     };


     services.stalonetray = {
        enable = true;
        config = {
         geometry = "5x1-900+0";
         decorations = null;
         icon_size = 12;
         slot_size = 22;
         sticky = true;
         background = "#2E3440";
         icon_gravity = "W";
        };
     };

  };
}
