# dotfiles

Nix flake managing three machines: `nixos` (desktop), `nixos-yoga` (laptop)
and `macbook` (macOS via nix-darwin), using the flake-parts module system.
This README is the shared reference for repository architecture, maintenance
commands and package placement.

## Building

```bash
sudo nixos-rebuild switch --flake .#nixos          # desktop
sudo nixos-rebuild switch --flake .#nixos-yoga     # laptop
sudo darwin-rebuild switch --flake .#macbook       # macbook

# Build without switching (for testing)
sudo nixos-rebuild build --flake .#nixos

# Evaluate the macOS configuration from Linux (evaluation only)
nix eval .#darwinConfigurations.macbook.system.drvPath

# Update all flake inputs, or just one
nix flake update
nix flake update <input-name>
```

New files referenced by the flake must be `git add`ed before rebuilding:
flakes only include git-tracked files.

## Setting up a new MacBook

1. Install Nix: https://nixos.org/download (if you use the Determinate
   installer instead, uncomment `nix.enable = false;` in
   `darwin/configuration.nix`).
2. Install Homebrew (https://brew.sh) — a handful of GUI apps that are
   Linux-only in nixpkgs (browsers, VLC, LibreOffice, Signal, Viber,
   ProtonVPN, Trezor Suite, OrcaSlicer, Yubico Authenticator) come from
   casks. Or set `homebrew.enable = false;` in `darwin/configuration.nix`
   to skip them.
3. Clone this repo and bootstrap nix-darwin:

```bash
git clone <this repo> ~/code/dotfiles && cd ~/code/dotfiles
sudo nix run nix-darwin/nix-darwin-26.05 -- switch --flake .#macbook
# every rebuild after the first one:
sudo darwin-rebuild switch --flake .#macbook
```

Assumptions baked into `darwin/configuration.nix` — adjust there if needed:
- Apple Silicon (`nixpkgs.hostPlatform = "aarch64-darwin"`; use
  `x86_64-darwin` on Intel)
- macOS account named `v0d1ch` with home `/Users/v0d1ch`

macOS notes:
- All cross-platform apps and CLI tools come from `modules/home.nix`, same
  as on the NixOS machines. Linux-only ones are behind an `isLinux` guard
  there, each annotated with its Homebrew cask replacement where one exists.
- `github:v0d1ch/nixvim` doesn't build for darwin yet, so the mac gets plain
  `neovim` as a fallback until that flake adds `aarch64-darwin` to its
  systems.
- The default macOS shell is zsh; the bash config from home-manager applies
  when bash runs (point ghostty at bash or `chsh` if you want it as login
  shell).
- `docker-compose` is installed but needs an engine: Docker Desktop or colima.

## Architecture

### Flake-parts modules

The flake uses `flake-parts.lib.mkFlake` with three custom modules registered
under `flake.modules`:

- `flake.modules.nixos.v0d1ch`, declared in `modules/system-packages.nix`,
  provides `environment.systemPackages` for Linux system tools and libraries
  such as Wayland/X11, ALSA, PAM and drivers.
- `flake.modules.homeManager.v0d1ch`, declared in `modules/home.nix`, provides
  apps, programs, services and dotfiles on all three machines. Linux-only
  packages and services use `pkgs.stdenv.isLinux` guards; Darwin-only settings
  use `isDarwin`.
- `flake.modules.homeManager.hermes`, declared in `modules/hermes.nix`, installs
  and configures Hermes Agent on the MacBook only.

The NixOS machine configurations import the system and shared home-manager
modules with this pattern:

```nix
imports = [ inputs.self.modules.nixos.v0d1ch ];
home-manager.useGlobalPkgs = true;                   # home.nix needs allowUnfree
home-manager.extraSpecialArgs = { inherit inputs; }; # home.nix needs flake inputs
home-manager.users.v0d1ch = { ... }: {
  imports = [ inputs.self.modules.homeManager.v0d1ch ];
};
```

The Darwin configuration uses the same home-manager settings and imports both
home-manager modules, without the Linux system module.

### Machine configurations

- `nixos/`: main desktop with an AMD GPU, SDDM, GNOME, Hyprland and auto-login.
- `nixos-yoga/`: Yoga laptop with Avahi, KBFS and a lighter configuration.
- `darwin/`: Apple Silicon MacBook using nix-darwin and Homebrew casks for GUI
  apps whose nixpkgs builds are Linux-only.

Machine-specific settings live in each directory's `configuration.nix`, with
`hardware-configuration.nix` alongside it on NixOS. All machines share the
applicable flake-parts modules.

### Key directories and services

- `modules/`: flake-parts modules for system packages and home-manager.
- `packages/`: custom Nix derivations. `qmd.nix` uses a fixed-output derivation
  for Bun dependencies. `ollama-prism.nix` overrides nixpkgs Ollama to build on
  the PrismML llama.cpp fork for Ternary Bonsai models; see
  `docs/ollama-bonsai.md`.
- `home/`: dotfile sources such as `hyprland.conf`, `kitty/kitty.conf`,
  `waybar/` and `zellij/`. Home-manager installs the wired-up files; the
  remaining manual snapshots are listed under Gotchas below.

`modules/hermes.nix` uses the upstream `hermes-agent` home-manager module and
is imported only by the MacBook. It declares `~/.hermes/config.yaml` with a
local terminal backend and an API server on port 8642; the gateway does not
start at login. Secrets live in `~/.hermes/.env`, outside the repository.
The A2A agent fleet, `fleet` script and plenum MCP hub that use Hermes live in
`github.com/Devnull-org/plenum`, checked out at `~/code/plenum`.

### Flake inputs

`flake.nix` declares the inputs and `flake.lock` records their exact revisions:

- `unstable`: nixpkgs on the `nixos-26.05` branch, despite the input's name.
- `nixpkgs-unstable`: nixpkgs on `nixos-unstable` for selected newer packages.
- `home-manager`: `release-26.05`.
- `nix-darwin`: `nix-darwin-26.05`, following `unstable` for nixpkgs.
- `flake-parts`: the module system from `hercules-ci/flake-parts`.
- `nixvim`: custom editor configuration from `github:v0d1ch/nixvim`.
- `waybar`: status bar from `github:Alexays/Waybar/master`. Hyprland is enabled
  in the NixOS machine configurations; it is not a separate flake input.
- `herdr`: tabbed terminal session manager from `ogulcancelik/herdr`.
- `dbx`: database client from `t8y2/dbx`, retaining its own nixpkgs pin.
- `hermes-agent`: Hermes Agent from `NousResearch/hermes-agent`, retaining its
  own nixpkgs pin for its uv2nix build.
- `mac-app-util`: macOS app trampolines from `hraban/mac-app-util`, following
  `nixpkgs-unstable`.

## Where to change things

App configs managed by home-manager are **read-only symlinks** in `~/.config` —
don't edit them there. Edit the source file in this repo, rebuild, then
commit/push so the other machine can pick it up with `git pull` + rebuild.

| What                  | Edit here                        | Ends up at                            |
|-----------------------|----------------------------------|---------------------------------------|
| kitty config          | `home/kitty/kitty.conf`          | `~/.config/kitty/kitty.conf`          |
| kitty theme           | `home/kitty/current-theme.conf`  | `~/.config/kitty/current-theme.conf`  |
| herdr config          | `home/herdr/config.toml`         | `~/.config/herdr/config.toml`         |
| Linux-only system packages | `modules/system-packages.nix` | both NixOS machines              |
| apps + home-manager programs/services (git, tmux, bash, gpg…) | `modules/home.nix` | all machines (macOS included) |
| Python tools installed with uv | `uv-tools.sh` | uv tool environments and `~/.local/bin` |
| machine-specific bits | `nixos/configuration.nix`, `nixos-yoga/configuration.nix` or `darwin/configuration.nix` | that machine only |

The symlink wiring lives in `modules/home.nix` under `xdg.configFile` — add new
config files there following the same pattern.

### Package placement and packaging patterns

- Cross-platform apps and CLI tools go in the shared list in `modules/home.nix`.
- Apps whose nixpkgs builds are Linux-only go in its `lib.optionals isLinux`
  list, with a comment naming the Homebrew cask replacement. Add that cask in
  `darwin/configuration.nix`.
- Linux system tools and libraries, including compositor libraries, PAM, ALSA
  and udev-adjacent tools, go in `environment.systemPackages` in
  `modules/system-packages.nix`. Custom packages use
  `(pkgs.callPackage ../packages/foo.nix {})`.
- Flake-input packages such as nixvim and herdr are included only when the
  input provides the current platform, using an
  `inputs.X.packages ? ${system}` guard.
- Home-manager programs and services go under
  `flake.modules.homeManager.v0d1ch` in `modules/home.nix`.
- User-wide Python tools installed with `uv tool install` are recorded in
  `uv-tools.sh`, including the Python version, extras and `--with` dependencies.
  Keep the list updated when adding or removing tools; see the uv section below.

When packaging apps with npm or Bun dependencies, use a fixed-output
derivation (FOD) with `dontFixup = true` so `patchShebangs` does not embed
store paths in `$out`. Follow `packages/qmd.nix`:

1. Fetch dependencies in the FOD with `--ignore-scripts` and `dontFixup = true`.
2. Copy dependencies into the main derivation, run `patchShebangs`, then compile
   native addons.

### Changing the kitty theme

`kitten themes` can't rewrite the read-only kitty.conf anymore. Instead dump the
theme you want into the repo and rebuild:

```bash
kitten themes --dump-theme "Theme Name" > home/kitty/current-theme.conf
sudo nixos-rebuild switch --flake .#nixos   # or .#nixos-yoga
```

### Syncing machines

```bash
# machine A: edit file in repo, then
sudo nixos-rebuild switch --flake .#nixos
git commit -am "..." && git push

# machine B:
git pull && sudo nixos-rebuild switch --flake .#nixos-yoga
```

## Python tools installed with uv

[`uv-tools.sh`](uv-tools.sh) is the list and installer for user-wide Python
tools. Each entry records the package, Python version, extras and additional
dependencies. It currently includes LangGraph with its CLI and local development
server support.

Nix provides `uv` through `modules/home.nix`. Run the installer separately as
your normal user, including after setting up a new machine:

```bash
./uv-tools.sh            # install the listed tools; keep matching installations
./uv-tools.sh --upgrade  # update the listed tools and their dependencies
uv tool list            # inspect what is actually installed on this machine
```

Add a `uv tool install ... "$@"` command with a short description to the script
whenever installing another tool. Preserve any `--python`, extras such as `[inmem]`, and
`--with` options needed to recreate its environment. Package versions currently
float; use `==VERSION` in a requirement if a tool needs a version pin. This is
an installation recipe, not a dependency lockfile.

Nix rebuilds do not run the installer. Removing an entry also requires
`uv tool uninstall PACKAGE` on machines where it is installed. Project-specific
Python dependencies belong in that project's `pyproject.toml` and `uv.lock`.
See the [uv tools documentation](https://docs.astral.sh/uv/concepts/tools/) for
environment and upgrade behavior.

## KeePass database sync

The KeePassXC database `keesharexc-sync.kdbx` lives at the root of the
Syncthing share `~/Sync` and is synced peer-to-peer between the desktop
(Syncthing as a NixOS service, `nixos/configuration.nix`), the MacBook
(Syncthing as a home-manager launchd agent, `darwin/configuration.nix`) and
the iPhone (a third-party Syncthing client; Strongbox opens the database in
place from it). No cloud drive and no always-on server are involved: any two
awake devices sync directly over LAN or Tailscale.

KeePassXC opens `~/Sync/keesharexc-sync.kdbx` on both computers. Don't edit
on two devices at the same time; if Syncthing produces a
`*.sync-conflict*.kdbx`, merge it into the live database (KeePassXC:
Database -> Merge From Database) rather than deleting it. Staggered file
versioning is on for the folder.

Pairing a new device, folder IDs and the hard-won gotchas (NixOS
`PrivateUsers` hardening, macOS folder paths, iOS in-place opening) are in
`docs/sync-setup.md`.

## Gotchas

- Flakes only see **git-tracked** files — `git add` any new file before rebuilding.
- Other dotfiles in `home/` (hyprland, waybar, zellij, swappy) are *not* wired up
  yet — they're manual snapshots. Edit those directly in `~/.config` as before.
- herdr's `session.json`, logs, and sockets are runtime state and stay unmanaged;
  only `config.toml` comes from this repo.
- Orca (`orca-ide` on Linux, cask on macOS) stores its worktrees and settings
  outside the repo. Reaching it from the phone or another machine over the
  tailnet is described in `docs/orca-tailscale.md`.
