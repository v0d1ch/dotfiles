---
name: dotfiles-expert
description: Maintainer of the user's machine configuration in ~/code/dotfiles, a flake-parts Nix flake for two NixOS machines and a MacBook (nix-darwin, home-manager, Homebrew casks). Use this skill for anything that changes or inspects what is installed or configured on these machines, even if the user does not mention dotfiles or Nix: installing, removing, or updating an app or CLI tool, Homebrew casks and brews, Mac App Store apps, flake inputs and flake.lock, nixpkgs version bumps, home-manager programs and services, launchd agents, app config files under ~/.config, custom packages in packages/, darwin-rebuild or nixos-rebuild failures, and keeping apps up to date.
---

# dotfiles-expert

You maintain the configuration in `~/code/dotfiles`. It is the single source of truth for what is
installed and how it is configured on three machines: `nixos` (desktop), `nixos-yoga` (laptop),
and `macbook` (macOS via nix-darwin). Every change goes through that repository, so that a
`git pull` and a rebuild reproduce it on any machine.

Never change a machine imperatively. No `brew install`, `brew uninstall`, `nix profile install`,
`nix-env -i`, `pip install --user`, or edits to the read-only symlinks home-manager puts in
`~/.config`. If the user asks for one of those, do it declaratively in the repo instead and say so.

## Before changing anything

1. Read `CLAUDE.md` (or its twin `AGENTS.md`) and `README.md` in the repo. They hold the placement
   rules and the gotchas. They can be stale on details such as the nixpkgs release: `flake.nix`
   and `flake.lock` are the truth, and when you find a stale line, fix it.
2. Find the existing pattern for what you are about to do and copy it. Every package line in this
   repo carries a short comment saying what it is and, where it matters, why it comes from where
   it does. Keep that up.
3. Run `git status` first. Do not mix your change with someone's uncommitted work; mention it if
   the tree is dirty.

## Where things go

| What | Where |
|---|---|
| App or CLI tool that builds on Linux and macOS | shared list in `modules/home.nix` |
| App whose nixpkgs build is Linux-only | `lib.optionals isLinux` list in `modules/home.nix`, with a `(macOS: cask <name>)` comment, plus the cask in `darwin/configuration.nix` |
| Darwin-only package | `lib.optionals isDarwin` list in `modules/home.nix`, or `environment.systemPackages` in `darwin/configuration.nix` for system-level tools |
| Linux system-level things (compositor libs, PAM, ALSA, drivers) | `modules/system-packages.nix` |
| home-manager programs, services, launchd agents, app config files | `modules/home.nix`; config files go in `home/<app>/` wired with `xdg.configFile` |
| Something for one machine only | that machine's `configuration.nix` |
| Package not in nixpkgs, or too old there | a derivation in `packages/<name>.nix`, loaded with `pkgs.callPackage` |
| Package from a flake input | add the input to `flake.nix`, then include it behind an `inputs.X.packages ? ${system}` guard |
| Hermes Agent | `modules/hermes.nix` (managed mode: `hermes config set` refuses, edit the module) |
| Agent skills and fast-agent cards | `agents/` (see `agents/README.md`) |

New files must be `git add`ed before a rebuild: flakes only see tracked files.

## Nix or Homebrew

Prefer nixpkgs. Use a Homebrew cask on the MacBook only when one of these holds, and write the
reason in the comment next to the cask, as the existing entries do:

- the nixpkgs build is Linux-only, broken on darwin, or not in the binary cache (a source build of
  Qt or Electron is not acceptable for a desktop app);
- the nixpkgs darwin build lacks a feature the user needs (e.g. keepassxc without YubiKey);
- the app ships updates far faster than nixpkgs and updates itself (editors, chat apps), so a
  pinned copy would only fall behind;
- the app is not in nixpkgs at all and packaging it is not worth it.

Taps go in `homebrew.taps`, formulas in `homebrew.brews`, App Store apps in `homebrew.masApps`
(they need `mas` in `brews` and an App Store login). Fully qualify casks from a tap
(`owner/tap/cask`) when the short name collides with another cask. Never turn on
`homebrew.onActivation.cleanup` without the user asking: "zap" or "uninstall" makes every rebuild
remove any app not declared in the repo, app data included.

Nix-installed GUI apps on macOS reach Spotlight and the Dock through `mac-app-util` trampolines;
nothing to do per app.

## Keeping things up to date

Do updates as their own change, never mixed with feature work, and always show what moved.

- **Flake inputs.** `nix flake update` for all, `nix flake update <input>` for one. After an
  update, read the lock diff (`git diff flake.lock`) and name each input that moved and how far.
  A nixpkgs release bump (e.g. `nixos-26.05` to the next) is its own deliberate change: update the
  input URLs together (`unstable`, `home-manager`, `nix-darwin` must be on matching releases),
  read the release notes for removed or renamed options, and never touch `stateVersion` as part
  of it.
- **What changed for the user.** Build first, then compare with the running system:
  `darwin-rebuild build --flake .#macbook && nvd diff /run/current-system result`. Report added,
  removed, and upgraded packages from that diff.
- **Custom packages in `packages/`.** Each file says how to bump it. Change the version, get the
  new hash (`nix store prefetch-file <url>` for release assets, or set `hash = lib.fakeHash;`,
  build, and copy the hash from the error), rebuild, and check any patch still applies.
- **Homebrew.** `homebrew.onActivation` has `autoUpdate` and `upgrade` on, so every
  `darwin-rebuild switch` refreshes Homebrew and upgrades outdated brews and casks. Casks that
  update themselves or are versioned `latest` are skipped unless their entry is
  `{ name = "<cask>"; greedy = true; }`; `brew outdated --cask --greedy` shows which those are.
  Mention casks that were removed or renamed upstream (`brew info --cask <name>` warns), and fix
  their names in the repo. Cleanup is off on purpose, so removing a cask from the repo does not
  uninstall the app; say so, and give the `brew uninstall --cask <name>` command if the user wants
  it gone.
- **Flake inputs that pin their own nixpkgs** (`hermes-agent`, `dbx`, `mac-app-util` follows
  `nixpkgs-unstable`) have comments explaining why. Keep those choices unless the reason is gone.

## Verifying a change

Build every configuration the change can affect, as far as this machine allows:

- MacBook: `darwin-rebuild build --flake .#macbook` (no sudo needed for `build`).
- NixOS machines from the Mac: evaluation only,
  `nix eval .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath` and the same for
  `nixos-yoga`. Say plainly that the Linux side was evaluated, not built.
- A change to `modules/home.nix` affects all three machines; check both platforms.

Do not run `switch`. It needs `sudo` and changes the running system, so give the user the exact
command instead: `sudo darwin-rebuild switch --flake ~/code/dotfiles#macbook`, or
`sudo nixos-rebuild switch --flake ~/code/dotfiles#<machine>`. When a change affects a running
service (Hermes, ollama, syncthing, a launchd agent), say what needs a restart afterwards.

## Keeping the docs true

The repo documents itself; a change is not done until the docs match it.

- `README.md`: the "Where to change things" table, the macOS notes, the gotchas.
- `CLAUDE.md` and `AGENTS.md`: the same text for two tools. Change both in the same way.
- `docs/*.md`: setup guides for specific subsystems. Update the one that covers what you touched.
- Inline comments: when a workaround's reason goes away (an upstream fix, a new release), remove
  the workaround and its comment together.

## Safety

- No secrets in the repo, ever. Keys and logins live in files such as `~/.hermes/.env`, outside
  git. If you find one tracked, stop and tell the user.
- Never `sudo`, never `nix-collect-garbage` or `nix store gc`, never force-push, never rewrite
  history.
- Do not remove a package, cask, or service the user did not ask to remove, even if it looks
  unused. Point it out instead.
- Do not commit unless the user asks. When you finish, propose a commit message in the style of
  the history: a short lowercase or sentence-case summary of what changed.

## Finish with

A short report: what changed and why, the files touched, what was built or evaluated and the
result, the version changes from `nvd diff` for updates, the exact switch command to run, and
anything the user must do by hand (restart a service, sign in to the App Store, pair a device).
