{ flake.modules.homeManager.v0d1ch = { config, pkgs, lib, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  inherit (pkgs.stdenv) isLinux isDarwin;
in
{
   home.stateVersion = "24.11";
     # Everything in the first list works on both Linux and macOS. Apps whose
     # nixpkgs build is Linux-only sit behind the isLinux guard below — on the
     # MacBook the GUI ones come from Homebrew casks instead
     # (see darwin/configuration.nix).
     home.packages = with pkgs; [
         # --- Editors & IDEs ---
         neovide       # GUI frontend for Neovim
         vim           # classic vi, always-available fallback
         vscode        # Visual Studio Code

         # --- Version control & dev tools ---
         lazygit       # git TUI
         jujutsu       # jj, git-compatible VCS
         dbeaver-bin   # database GUI client
         ollama        # run LLMs locally
         nvd           # diff nix closures/generations

         # --- Desktop applications ---
         qbittorrent    # torrent client
         obsidian       # note-taking
         discord

         # --- CLI utilities ---
         bc      # arbitrary-precision calculator
         sad     # interactive search & replace (sed alternative)
         lnav    # log file navigator
         wget    # HTTP downloader
         zip     # create zip archives
         unzip   # extract zip archives
         jq      # JSON processor
         fx      # interactive JSON viewer
         lsof    # list open files/ports
         ripgrep # fast grep (rg)
         fd      # fast find
         htop    # process monitor
         btop    # fancier process monitor
         eva     # calculator REPL
         lsix    # image thumbnails in the terminal (sixel)

         # --- Communication ---
         irssi   # IRC client

         # --- Network ---
         rclone         # sync files with cloud storage
         magic-wormhole # send files machine-to-machine with codes
         nmap           # port scanner
         wireshark      # packet capture & analysis
         openvpn        # OpenVPN client

         # --- Security & hardware keys ---
         pinentry-curses # terminal pinentry, used by gpg-agent
         yubikey-manager
         yubikey-personalization
         yubico-piv-tool

         # --- Audio / media ---
         sox            # audio recording/processing CLI
         openai-whisper # speech-to-text (Python version)

         # --- Documents & writing ---
         multimarkdown                # markdown converter
         texlive.combined.scheme-full # complete TeX Live

         # --- Development ---
         docker-compose       # engine: virtualisation.docker on NixOS, Docker Desktop/colima on macOS
         cachix               # Nix binary cache client
         rustup               # Rust toolchain manager
         nodejs_22            # Node.js
         haskellPackages.Agda # Agda proof assistant
         blesh                # ble.sh — bash autosuggestions/highlighting

         # Claude Code with the personal account profile (default ~/.claude);
         # a real command (not just the bash alias below) so IDEs, launchers
         # and scripts see it too
         (writeShellScriptBin "claude-personal" ''
           export CLAUDE_CONFIG_DIR="$HOME/.claude"
           exec claude "$@"
         '')

         # Same idea for the work account profile: a real command, not just
         # the bash alias below, so IDEs, launchers and scripts that invoke
         # it directly still get the right account. Must be a DIFFERENT
         # directory than the personal profile, otherwise /logout in one
         # profile wipes the shared credentials of both.
         (writeShellScriptBin "claude-work" ''
           export CLAUDE_CONFIG_DIR="$HOME/.claude-work"
           exec claude "$@"
         '')

         # Sync the KeePassXC databases (*.kdbx) with Google Drive.
         # Needs the rclone remote "google_drive" configured once per machine
         # (rclone config, or copy ~/.config/rclone/rclone.conf over wormhole).
         # --update in both directions: an older copy never overwrites a newer
         # one. See README "KeePass database sync".
         (writeShellScriptBin "keepass-sync" ''
           REMOTE="''${KEEPASS_REMOTE:-google_drive:}"
           LOCAL="''${KEEPASS_DIR:-$HOME/Documents/google-drive-local}"
           case "$1" in
             pull)   exec ${rclone}/bin/rclone copy --update -v --include "*.kdbx" "$REMOTE" "$LOCAL" ;;
             push)   exec ${rclone}/bin/rclone copy --update -v --include "*.kdbx" "$LOCAL" "$REMOTE" ;;
             status) exec ${rclone}/bin/rclone check --include "*.kdbx" "$LOCAL" "$REMOTE" ;;
             *) echo "usage: keepass-sync pull|push|status" >&2; exit 1 ;;
           esac
         '')
     ]
     # ghostty 1.1.3 in 26.05 is broken with GTK 4.18 on Linux, pull 1.2.x from
     # real unstable; on macOS nixpkgs only ships the upstream binary (ghostty-bin)
     ++ [ (if isDarwin
           then pkgs.ghostty-bin
           else inputs.nixpkgs-unstable.legacyPackages.${system}.ghostty) ]
     # Flake-input packages: only include them on platforms the flake actually
     # builds for, so a macOS eval doesn't die if an input has no darwin output
     ++ lib.optionals (inputs.nixvim ? packages && inputs.nixvim.packages ? ${system})
        [ inputs.nixvim.packages.${system}.default ] # my Neovim distribution (github:v0d1ch/nixvim)
     # github:v0d1ch/nixvim doesn't build for darwin (yet) — fall back to plain
     # neovim there so `nvim` / EDITOR still work; drop this once the nixvim
     # flake adds darwin to its systems
     ++ lib.optionals (!(inputs.nixvim ? packages && inputs.nixvim.packages ? ${system}))
        [ pkgs.neovim ]
     ++ lib.optionals (inputs.herdr ? packages && inputs.herdr.packages ? ${system})
        [ inputs.herdr.packages.${system}.default ]  # tabbed terminal session manager
     ++ lib.optionals isLinux [
         # hunk is not in 26.05 yet; pull the terminal diff viewer from real unstable
         # (darwin build unverified, keep it Linux-only for now)
         inputs.nixpkgs-unstable.legacyPackages.${system}.hunk
         # local search over markdown notes — the FOD dependency hash is
         # platform-specific (bun fetches native packages), so Linux-only
         (pkgs.callPackage ../packages/qmd.nix {})

         # --- Browsers (macOS: homebrew casks firefox / google-chrome / brave-browser) ---
         firefox
         google-chrome
         brave

         # --- Desktop applications ---
         # nixpkgs builds keepassxc without YubiKey support on darwin
         # (withKeePassYubiKey defaults to isLinux), so macOS uses the
         # official build via cask keepassxc instead
         keepassxc      # password manager
         libreoffice    # office suite (macOS: cask libreoffice)
         signal-desktop # (macOS: cask signal)
         viber          # (macOS: cask viber)
         karere         # WhatsApp client (GTK)
         vlc            # media player (macOS: cask vlc)
         gnomecast      # cast video to Chromecast
         nicotine-plus  # Soulseek client
         clementine     # music player
         gnome-terminal # fallback terminal
         virtualbox     # VMs (kernel modules would need virtualisation.virtualbox.host.enable)
         caffeine-ng    # keep the screen awake (macOS: built-in `caffeinate`)
         trezor-suite   # Trezor hardware wallet app (macOS: cask trezor-suite)
         orca-slicer    # 3D printer slicer (macOS: cask orcaslicer)
         meld           # visual diff/merge

         # --- Network / VPN ---
         proton-vpn     # ProtonVPN GUI (macOS: cask protonvpn)
         proton-vpn-cli # ProtonVPN CLI
         ettercap       # network sniffing/MITM toolkit

         # --- Security & hardware keys ---
         yubioath-flutter # (macOS: cask yubico-authenticator)

         # --- Screen capture (macOS: built-in Cmd-Shift-5) ---
         simplescreenrecorder
         kazam
         vokoscreen-ng
         flameshot # screenshots + annotation (X11)

         # --- Images ---
         feh  # image viewer / wallpaper setter
         eog  # GNOME image viewer

         # --- X11 desktop utilities ---
         xscreensaver             # screen saver/locker
         trayer                   # X11 system tray (stalonetray service below is the other one)
         arandr                   # GUI for xrandr display layout
         xclip                    # X11 clipboard CLI (tmux copy-mode pipes into it)
         xsel                     # X11 clipboard CLI
         dmenu                    # X11 launcher
         haskellPackages.yeganesh # dmenu wrapper that sorts by usage
         copyq                    # clipboard history manager

         # --- Misc ---
         speechd # speech-dispatcher text-to-speech daemon
     ];


     services.lorri = lib.mkIf isLinux {
      enable = true;
     };

     xdg.configFile = {
       "ghostty/config".source = ../home/ghostty/config;
       "ghostty/themes/Paper".source = ../home/ghostty/themes/Paper;
       "herdr/config.toml".source = ../home/herdr/config.toml;
     } // lib.optionalAttrs isLinux {
       "hypr/hyprland.conf".source = ../home/hyprland.conf;
       "waybar/config.jsonc".source = ../home/waybar/config.jsonc;
       "waybar/style.css".source = ../home/waybar/style.css;
       "waybar/power_menu.xml".source = ../home/waybar/power_menu.xml;
       "waybar/mediaplayer.py" = {
         source = ../home/waybar/mediaplayer.py;
         executable = true;
       };
     };

     programs.gpg = {
       enable = true;
       settings = {
         # Ask gpg to use loopback pinentry so that subprocesses (e.g. NeoGit
         # inside Neovim) can sign commits without needing direct TTY access.
         # The gpg-agent side enables this via allow-loopback-pinentry below.
         pinentry-mode = "loopback";
       };
     };

     # The home-manager gpg-agent service is systemd-only. On macOS gpg-agent
     # is auto-started on demand by gpg, so a plain config file with the same
     # settings is all that's needed.
     services.gpg-agent = lib.mkIf isLinux {
       enable = true;
       # SSH keys are served by plain ssh-agent (below), not gpg-agent: the
       # SSH agent protocol cannot tell gpg-agent which TTY to prompt on, so
       # pinentry lands in the wrong zellij pane / SSH session.
       enableSshSupport = false;
       defaultCacheTtl = 1800;
       pinentry.package = pkgs.pinentry-curses;
       extraConfig = ''
         allow-loopback-pinentry
       '';
     };

     home.file.".gnupg/gpg-agent.conf" = lib.mkIf isDarwin {
       text = ''
         allow-loopback-pinentry
         default-cache-ttl 1800
         pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses
       '';
     };

     # macOS runs its own ssh-agent via launchd
     services.ssh-agent = lib.mkIf isLinux {
       enable = true;
     };

     services.dunst = lib.mkIf isLinux {
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
         ignores = [ "TAGS" ];
         signing = {
           signByDefault = true;
           # key = "8FE67EA9460B6F07";
           key = "BEBC851F2E49B6B6";
         };
         settings = {
           user = {
             # email = "sasa.bogicevic@pm.me";
             email = "sasha.bogicevic@iohk.io";
             name = "Sasha Bogicevic";
           };
           alias = {
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

     programs.fzf = {
       enable = true;
       enableBashIntegration = true;
     };

     programs.atuin = {
       enable = true;
       enableBashIntegration = true;
       flags = [ "--disable-up-arrow" ];
       settings = {
         auto_sync = false;
         update_check = false;
         style = "compact";
         inline_height = 20;
         search_mode = "fuzzy";
       };
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
          bind-key -T copy-mode-vi 'y' send -X copy-pipe '${if isDarwin then "pbcopy" else "xclip -in -selection clipboard"}'
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


     services.stalonetray = lib.mkIf isLinux {
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

     programs.waybar = {
        enable = isLinux;
     };

     programs.bash = {
        enable = true;
        shellAliases = {
          claude = "CLAUDE_CONFIG_DIR=~/.claude claude";
          claude-personal = "CLAUDE_CONFIG_DIR=~/.claude claude";
          claude-work = "CLAUDE_CONFIG_DIR=~/.claude-work claude";
        };
        historyFile = "${config.home.homeDirectory}/.bash_history";
        historySize = 10000;
        historyFileSize = 100000;
        historyIgnore = [ "ls" "cd" "exit" ];  # optional: ignore simple commands
        shellOptions = [
           "histappend"          # append to history file instead of overwriting
           "cmdhist"             # save multi-line commands as one entry
           "lithist"             # preserve newlines in multi-line commands
        ];
        initExtra = ''
           # Prevent consecutive duplicates but keep history intact
           export HISTCONTROL=ignoredups:ignorespace
           export GPG_TTY=$(tty)

           # Attach to a zellij session and refresh GPG_TTY so gpg signing
           # works in the (possibly pre-existing) session's panes
           zja() {
             zellij attach "$@"
             export GPG_TTY=$(tty)
           }
        '';

     };

  };
}
