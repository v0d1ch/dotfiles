# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Nix flake-based dotfiles managing system and home configurations for three machines (two NixOS, one macOS via nix-darwin) using flake-parts module system.

## Build Commands

```bash
# Build and switch (desktop)
sudo nixos-rebuild switch --flake .#nixos

# Build and switch (yoga laptop)
sudo nixos-rebuild switch --flake .#nixos-yoga

# Build and switch (macbook, on macOS)
sudo darwin-rebuild switch --flake .#macbook

# Build without switching (for testing)
sudo nixos-rebuild build --flake .#nixos

# Evaluate the macOS config from a Linux machine (eval-only check)
nix eval .#darwinConfigurations.macbook.system.drvPath

# Update all flake inputs
nix flake update

# Update a single input
nix flake update <input-name>
```

When adding new files referenced by the flake, they must be `git add`ed before Nix can see them (flakes only include git-tracked files).

## Architecture

### Flake-Parts Module System

The flake uses `flake-parts.lib.mkFlake` with two custom modules registered under `flake.modules`:

- `flake.modules.nixos.v0d1ch` — declared in `modules/system-packages.nix`, provides `environment.systemPackages` (Linux-only packages: Wayland/X11, ALSA, PAM, drivers)
- `flake.modules.homeManager.v0d1ch` — declared in `modules/home.nix`, provides home-manager config (apps, programs, services, dotfiles). This module is **cross-platform**: it is imported on both NixOS machines and the macbook. Linux-only packages/services are behind `pkgs.stdenv.isLinux` guards; darwin-only bits behind `isDarwin`.

Each `configuration.nix` imports these modules:
```nix
imports = [ inputs.self.modules.nixos.v0d1ch ];
home-manager.useGlobalPkgs = true;                     # home.nix needs allowUnfree
home-manager.extraSpecialArgs = { inherit inputs; };   # home.nix needs flake inputs
home-manager.users.v0d1ch = {...}: {
    imports = [ inputs.self.modules.homeManager.v0d1ch ];
};
```

### Machine Configurations

- **`nixos/`** — Main desktop (AMD GPU, SDDM + GNOME + Hyprland, auto-login)
- **`nixos-yoga/`** — Yoga laptop (Avahi, KBFS, lighter config)
- **`darwin/`** — MacBook (nix-darwin, Apple Silicon, imports only the home-manager module plus Homebrew casks for GUI apps that are Linux-only in nixpkgs)

All share the flake-parts modules. Machine-specific config lives in their respective `configuration.nix` (and `hardware-configuration.nix` for NixOS).

### Package placement rules

- Cross-platform app or CLI tool → shared list in `modules/home.nix`
- App whose nixpkgs build is Linux-only → `lib.optionals isLinux` list in `modules/home.nix`, with a comment naming the Homebrew cask replacement (add the cask in `darwin/configuration.nix`)
- Truly system-level Linux things (compositor libs, PAM, ALSA, udev-adjacent tools) → `modules/system-packages.nix`
- Flake-input packages (nixvim, herdr) are included only when the input provides the current platform (`inputs.X.packages ? ${system}` guard)

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
