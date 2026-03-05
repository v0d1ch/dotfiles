# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

NixOS flake-based dotfiles managing system and home configurations for two machines using flake-parts module system.

## Build Commands

```bash
# Build and switch (desktop)
sudo nixos-rebuild switch --flake .#nixos

# Build and switch (yoga laptop)
sudo nixos-rebuild switch --flake .#nixos-yoga

# Build without switching (for testing)
sudo nixos-rebuild build --flake .#nixos

# Update all flake inputs
nix flake update

# Update a single input
nix flake update <input-name>
```

When adding new files referenced by the flake, they must be `git add`ed before Nix can see them (flakes only include git-tracked files).

## Architecture

### Flake-Parts Module System

The flake uses `flake-parts.lib.mkFlake` with two custom modules registered under `flake.modules`:

- `flake.modules.nixos.v0d1ch` — declared in `modules/system-packages.nix`, provides `environment.systemPackages`
- `flake.modules.homeManager.v0d1ch` — declared in `modules/home.nix`, provides home-manager config (programs, services, dotfiles)

Each `configuration.nix` imports these modules:
```nix
imports = [ inputs.self.modules.nixos.v0d1ch ];
home-manager.users.v0d1ch = {...}: {
    imports = [ inputs.self.modules.homeManager.v0d1ch ];
};
```

### Machine Configurations

- **`nixos/`** — Main desktop (AMD GPU, SDDM + GNOME + Hyprland, auto-login)
- **`nixos-yoga/`** — Yoga laptop (Avahi, KBFS, lighter config)

Both share the same flake-parts modules. Machine-specific config lives in their respective `configuration.nix` and `hardware-configuration.nix`.

### Key Directories

- `modules/` — Flake-parts modules (system packages + home-manager)
- `packages/` — Custom Nix derivations (e.g., `qmd.nix` with fixed-output derivation for bun deps)
- `home/` — Dotfiles copied into home by home-manager (`hyprland.conf`, `kitty.conf`, `waybar/`, `zellij/`)

### Flake Inputs

- `unstable` — nixpkgs (NixOS 25.05)
- `home-manager` — release-25.05
- `nixvim` — custom config from github:v0d1ch/nixvim
- `hyprland`, `waybar` — window manager and status bar from upstream

## Packaging Patterns

### Custom packages with network dependencies (FODs)

When packaging apps that need to fetch dependencies (npm/bun), use a fixed-output derivation with `dontFixup = true` to prevent `patchShebangs` from embedding store paths in `$out`. See `packages/qmd.nix` for the pattern:

1. FOD fetches deps with `--ignore-scripts` + `dontFixup = true`
2. Main derivation copies deps, runs `patchShebangs`, compiles native addons

### Adding system packages

Add to the `environment.systemPackages` list in `modules/system-packages.nix`. Custom packages use `(pkgs.callPackage ../packages/foo.nix {})`.

### Adding home-manager programs/services

Configure in `modules/home.nix` under the `flake.modules.homeManager.v0d1ch` attribute set.
