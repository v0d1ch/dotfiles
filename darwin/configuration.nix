{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    # Makes nix-installed GUI apps (environment.systemPackages) visible to
    # Spotlight/Launchpad via trampolines instead of symlinks
    inputs.mac-app-util.darwinModules.default
  ];

  # Apple Silicon; use "x86_64-darwin" on an Intel Mac.
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # If Nix was installed with the Determinate installer, it manages the nix
  # daemon itself — uncomment this so nix-darwin doesn't fight over it:
  # nix.enable = false;

  # Adjust these two if the macOS account name is not v0d1ch.
  system.primaryUser = "v0d1ch";
  users.users.v0d1ch = {
    name = "v0d1ch";
    home = "/Users/v0d1ch";
  };

  # /run lives on /private/var/run, which macOS empties on every boot; the
  # org.nixos.activate-system launchd daemon is what recreates
  # /run/current-system at startup. The macOS 27 upgrade silently dropped
  # that daemon from launchd, and nix-darwin's activation only re-registers
  # it when the plist *content* changes, so every rebuild kept skipping it
  # and darwin-rebuild vanished from PATH after each reboot. Re-bootstrap it
  # on every activation (a no-op when it's already loaded) so this self-heals.
  system.activationScripts.postActivation.text = ''
    launchctl bootstrap system /Library/LaunchDaemons/org.nixos.activate-system.plist 2>/dev/null \
      || launchctl kickstart system/org.nixos.activate-system 2>/dev/null \
      || true
  '';
  # Belt and braces: the system profile is a stable path that survives a
  # missing /run/current-system, so darwin-rebuild stays reachable regardless.
  environment.systemPath = lib.mkAfter [ "/nix/var/nix/profiles/system/sw/bin" ];

  home-manager.backupFileExtension = "hm-backup";
  home-manager.useGlobalPkgs = true;
  home-manager.extraSpecialArgs = { inherit inputs; };
  # Same trampoline treatment for apps installed via home.packages
  # (keepassxc, ghostty, obsidian, ...), which is where most GUI apps live
  home-manager.sharedModules = [
    inputs.mac-app-util.homeManagerModules.default
  ];
  home-manager.users.v0d1ch = { lib, config, pkgs, ... }: {
    imports = [
      inputs.self.modules.homeManager.v0d1ch
      inputs.self.modules.homeManager.hermes   # Hermes Agent, macbook only
    ];

    # macOS-only: sign with a local software key instead of the YubiKey-backed
    # key from modules/home.nix, since that key's private material lives only
    # on the physical token and isn't present on this machine. nixos and
    # nixos-yoga are untouched — they still use the shared module's key.
    programs.git.signing.key = lib.mkForce "C574785FF89B8E25";

    # File sync with the desktop, which runs syncthing as a NixOS system
    # service. Runs here as a launchd agent (starts at login). Pair the
    # devices once in the GUI at http://127.0.0.1:8384; see docs/sync-setup.md.
    services.syncthing.enable = true;

    # Local LLM server (launchd agent, listens on 127.0.0.1:11434) for the
    # Msty Studio and Enchanted GUIs below. The home-manager module also puts
    # this package's `ollama` CLI on PATH (modules/home.nix ships stock ollama
    # on Linux only). Metal acceleration works out of the box.
    # Usage: `ollama pull llama3.2` then point the GUI at the default URL.
    #
    # Stays on loopback (the macOS firewall is off, so 0.0.0.0 would expose it
    # to any Wi-Fi). It is published to the tailnet instead with the App Store
    # Tailscale client, whose serve config persists across reboots; run once:
    #   /Applications/Tailscale.app/Contents/MacOS/Tailscale serve --bg --tcp 11434 tcp://localhost:11434
    # Then the phone reaches it as http://sashas-macbook-air.<tailnet>.ts.net:11434.
    # See docs/ollama-tailscale.md.
    services.ollama.enable = true;
    # Ollama built on the PrismML llama.cpp fork so the Ternary Bonsai models
    # (PQ2_0 / PTQ1_0 GGUFs, e.g. Ternary-Bonsai-2-27B at 5.9 GB) load; stock
    # ollama rejects them. Everything else behaves like upstream 0.34.2.
    # Import and usage notes in docs/ollama-bonsai.md.
    services.ollama.package = pkgs.callPackage ../packages/ollama-prism.nix { };

    # reMarkable 2 -> Obsidian. The tablet pushes its raw document store over
    # Syncthing (send-only there, receive-only here) into ~/reMarkable/raw;
    # this agent turns it into real folders/PDFs/notes under
    # ~/Sync/obsidian/reMarkable every 5 min and transcribes handwriting
    # with the local ollama vision model. Python deps live in an unmanaged
    # venv (rmc is not in nixpkgs); bootstrap once with
    #   python3 -m venv ~/reMarkable/venv && ~/reMarkable/venv/bin/pip install rmc svglib reportlab pypdf pypdfium2
    # Full setup in docs/remarkable-sync.md.
    home.file.".local/bin/remarkable-to-obsidian" = {
      source = ../home/remarkable/remarkable-to-obsidian.py;
      executable = true;
    };
    launchd.agents.remarkable-to-obsidian = {
      enable = true;
      config = {
        ProgramArguments = [
          "${config.home.homeDirectory}/reMarkable/venv/bin/python"
          "${config.home.homeDirectory}/.local/bin/remarkable-to-obsidian"
        ];
        StartInterval = 300;
        RunAtLoad = true;
        StandardOutPath = "${config.home.homeDirectory}/reMarkable/convert.log";
        StandardErrorPath = "${config.home.homeDirectory}/reMarkable/convert.log";
        EnvironmentVariables = {
          PATH = "/usr/bin:/bin";
          # Handwriting OCR only for notebooks in these tablet folders; the
          # others (Sketch, Draw, ...) hold drawings and are just rendered.
          REMARKABLE_OCR_FOLDERS = "Notes";
        };
      };
    };
  };

  # Garmin watch app development (see ~/code/skate-iq): CLI that downloads the
  # Connect IQ SDK (monkeyc compiler + simulator) and device definitions into
  # ~/.Garmin/ConnectIQ. Not in nixpkgs; packaged from the upstream release.
  # One-time setup: `connect-iq-sdk-manager login`, then
  # `connect-iq-sdk-manager sdk set '>=8.0.0'` and
  # `connect-iq-sdk-manager device download -d fr965`.
  environment.systemPackages = [
    (pkgs.callPackage ../packages/connect-iq-sdk-manager.nix { })
    pkgs.jdk # the SDK's monkeyc compiler and simulator tools are Java-based
  ];

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    open-sans
    hasklig
    iosevka
    font-awesome
  ];

  # GUI apps whose nixpkgs build is Linux-only get installed through Homebrew
  # casks instead (each is marked with its cask name in modules/home.nix).
  # A few fast-moving macOS CLIs also live here when Homebrew tracks upstream
  # releases more closely than nixpkgs.
  # Requires Homebrew to be installed first (https://brew.sh); set
  # homebrew.enable = false if you'd rather skip it.
  homebrew = {
    enable = true;
    # Every `darwin-rebuild switch` refreshes Homebrew and upgrades outdated brews and casks.
    # Casks that update themselves (auto_updates) or are versioned `latest` are skipped by
    # `brew upgrade` unless marked `greedy = true` in their entry below. Cleanup stays off on
    # purpose: "zap"/"uninstall" would remove any app not declared here, data included.
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
    taps = [
      "stablyai/orca" # Orca ADE; the core `orca` cask is plotly's unrelated chart exporter, so the cask below is fully qualified
    ];
    brews = [
      "mas" # Mac App Store CLI, needed for masApps below; declared so cleanup doesn't remove it after each rebuild
    ];
    casks = [
      "keepassxc"   # official build; the nixpkgs darwin build lacks YubiKey support
      "firefox"
      "google-chrome"
      "brave-browser"
      "vlc"
      "libreoffice"
      "signal"
      "slack"       # desktop app instead of a Brave tab; nixpkgs builds it for darwin too, but the cask self-updates
      "viber"
      "protonvpn"
      "trezor-suite"
      "orcaslicer"
      "yubico-authenticator"
      "keepingyouawake" # menu bar toggle to prevent display sleep (caffeinate wrapper)
      "vorssaint"   # menu bar toolkit: keep-awake, system monitor, volume mixer (arm64, macOS >= 14)
      "mstystudio"  # Msty Studio: chat GUI for local (ollama) and online models; the older "msty" cask is discontinued
      "docker-desktop" # Docker engine + CLI for macOS (the docker-compose CLI comes from modules/home.nix); the old "docker" cask name is an alias
      "raspberry-pi-imager" # SD card flasher for Raspberry Pi OS; the nixpkgs darwin build isn't cached (Qt from source)
      "handy"       # open-source offline speech-to-text (push-to-talk dictation, local Whisper/Parakeet models); not in nixpkgs
      "cursor"      # AI code editor; nixpkgs code-cursor builds for darwin but lags many releases behind and can't self-update
      "codex"       # OpenAI Codex CLI; Homebrew cask tracks upstream releases faster than nixpkgs on macOS
      "dbx"         # DBX database client (MySQL/Postgres/SQLite/Redis/Mongo/...); the upstream flake's dbx-desktop is Linux-only, and the nixpkgs `dbx` is an unrelated Databricks CLI
      "stablyai/orca/orca" # Orca ADE: run/watch many coding agents in parallel worktrees, phone companion app; Linux uses packages/orca.nix. See docs/orca-tailscale.md
    ];
    # Mac App Store apps (installed via `mas`, which nix-darwin adds when this
    # is non-empty). Requires being signed in to the App Store beforehand.
    masApps = {
      "Enchanted" = 6474268307; # native macOS/iOS chat client for ollama
    };
  };

  # Auto-hidden Dock: appear immediately on edge hit, quick slide-in
  # (macOS defaults are 0.5s for both, which feels sluggish)
  system.defaults.dock = {
    autohide = true;
    autohide-delay = 0.0;
    autohide-time-modifier = 0.3;
  };

  environment.variables.EDITOR = "nvim";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "v0d1ch" ];

  nix.settings.trusted-public-keys = [
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "cardano-scaling.cachix.org-1:RKvHKhGs/b6CBDqzKbDk0Rv6sod2kPSXLwPzcUQg9lY="
  ];

  nix.settings.substituters = [
    "https://cache.iog.io"
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
    "https://cardano-scaling.cachix.org"
  ];

  # Used for backwards compatibility; read the nix-darwin changelog
  # before changing.
  system.stateVersion = 6;
}
