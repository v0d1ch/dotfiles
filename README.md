# dotfiles

Nix flake managing three machines: `nixos` (desktop), `nixos-yoga` (laptop)
and `macbook` (macOS via nix-darwin).

## Building

```bash
sudo nixos-rebuild switch --flake .#nixos          # desktop
sudo nixos-rebuild switch --flake .#nixos-yoga     # laptop
sudo darwin-rebuild switch --flake .#macbook       # macbook
```

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
| machine-specific bits | `nixos/configuration.nix`, `nixos-yoga/configuration.nix` or `darwin/configuration.nix` | that machine only |

The symlink wiring lives in `modules/home.nix` under `xdg.configFile` — add new
config files there following the same pattern.

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

## Gotchas

- Flakes only see **git-tracked** files — `git add` any new file before rebuilding.
- Other dotfiles in `home/` (hyprland, waybar, zellij, swappy) are *not* wired up
  yet — they're manual snapshots. Edit those directly in `~/.config` as before.
- herdr's `session.json`, logs, and sockets are runtime state and stay unmanaged;
  only `config.toml` comes from this repo.
