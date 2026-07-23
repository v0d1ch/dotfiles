# dotfiles

NixOS flake managing two machines: `nixos` (desktop) and `nixos-yoga` (laptop).

## Building

```bash
sudo nixos-rebuild switch --flake .#nixos          # desktop
sudo nixos-rebuild switch --flake .#nixos-yoga     # laptop
```

## Where to change things

App configs managed by home-manager are **read-only symlinks** in `~/.config` —
don't edit them there. Edit the source file in this repo, rebuild, then
commit/push so the other machine can pick it up with `git pull` + rebuild.

| What                  | Edit here                        | Ends up at                            |
|-----------------------|----------------------------------|---------------------------------------|
| kitty config          | `home/kitty/kitty.conf`          | `~/.config/kitty/kitty.conf`          |
| kitty theme           | `home/kitty/current-theme.conf`  | `~/.config/kitty/current-theme.conf`  |
| herdr config          | `home/herdr/config.toml`         | `~/.config/herdr/config.toml`         |
| system packages       | `modules/system-packages.nix`    | both machines                         |
| home-manager programs/services (git, tmux, bash, gpg…) | `modules/home.nix` | both machines |
| machine-specific bits | `nixos/configuration.nix` or `nixos-yoga/configuration.nix` | that machine only |

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
