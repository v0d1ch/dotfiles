# Orca over Tailscale

Orca (onorca.dev) runs coding agents in parallel git worktrees and shows
their state in one dashboard. The agents, shells and worktrees live on one
machine (the "host"); the phone app, the browser and Orca on another machine
are thin clients that pair with that host. Pairing needs a network path from
client to host, and on this setup that path is the tailnet: no port
forwarding, no Orca Relay account, and Tailscale encrypts the link on top of
Orca's own pairing keys.

Where Orca comes from:

| Machine | Install                                   | Command    |
|---------|-------------------------------------------|------------|
| macbook | homebrew cask `stablyai/orca/orca` (`darwin/configuration.nix`) | `orca` (`/opt/homebrew/bin/orca`) |
| nixos, nixos-yoga | `packages/orca.nix` (wrapped AppImage) via `modules/home.nix` | `orca-ide` |

The macbook is the host day to day, since it is the machine that is on. The
nixos desktop is the better host when it is running (never suspends, GPU,
trusted `tailscale0`); see the last section.

As with ollama, prefer the Tailscale IP over the MagicDNS name unless "Use
Tailscale DNS" is on for the client device. On the mac Tailscale is the App
Store app, so the CLI is inside the bundle:

```sh
TS=/Applications/Tailscale.app/Contents/MacOS/Tailscale
$TS ip -4        # this machine's tailnet address
$TS status       # every device, and whether it is online
```

## Host: macbook, GUI running (default)

1. Open Orca. Settings, Remote Orca Servers, "Advertise this app as a
   server", New Link. Pick the **Tailscale address** from the list of
   addresses it offers, then generate an access link.
2. On the client (phone app, browser, Orca on another machine): Add Server,
   paste the link. The phone can scan it as a QR code instead.
3. The client lists this mac's worktrees and can start, watch and answer
   agents on it.

The session lives as long as the Orca window is open. Quit Orca and clients
drop until it is reopened. If macOS asks whether Orca may accept incoming
connections, allow it; that is the only firewall step on the mac.

## Host: macbook, headless `serve` (no window)

Same binary, different subcommand. Useful when the lid stays closed and
nothing else needs the window:

```sh
TS=/Applications/Tailscale.app/Contents/MacOS/Tailscale
orca serve --port 6768 --pairing-address "$($TS ip -4)"
```

It runs in the foreground and prints the bound endpoint, the advertised
endpoint and a pairing link of the form `orca://pair?code=...` (plus a
browser URL when the web client bundle is present). For a phone-only
pairing add `--mobile-pairing`, which prints a mobile-scoped QR/link.

Notes:

- `--pairing-address` only changes what clients are told to dial. The
  listener binds locally on the given port regardless, so wildcard
  addresses cannot be advertised.
- Exit status 3 means another Orca process already owns the profile, in
  practice the GUI. Close it first, or use the GUI flow above.
- `serve` is not a launchd agent yet. If it becomes the everyday mode, add
  one in `darwin/configuration.nix` next to syncthing, with the fixed
  Tailscale IP in `--pairing-address`.

## Keeping the mac reachable

A sleeping mac is off the tailnet. Options, least invasive first:

- Lid open and on power: set "Prevent automatic sleeping on power adapter
  when the display is off" in System Settings, Battery/Energy.
- `caffeinate -s` in a terminal while agents run (only while on AC power).
- Vorssaint's keep-awake also works, but it kills the headless Phone.app and
  breaks iPhone call relay; see the note in `darwin/configuration.nix`.

`pmset -g | grep sleep` shows what is currently preventing sleep.

## Phone

Install "Orca IDE" from the App Store and the Tailscale app, and turn
Tailscale **on** on the phone (it showed as offline in `tailscale status`
for days, which makes every pairing link fail). Then pair with the link or
QR from either host mode. Everything stays on the host: the phone shows
worktree state (working, done, waiting), pushes a notification when an
agent finishes or asks something, and lets you answer with `yes`,
`continue` or free text. It can create workspaces but is not meant for
writing long prompts.

If Tailscale on the phone is not an option, the fallback is Orca Relay: sign
both the host app and the phone into the same (free) Orca account and pair
through it. Relay is only needed in that case.

## Host: nixos desktop (when it is on)

Same two flows with `orca-ide` instead of `orca` and `tailscale ip -4`
directly on PATH. It already trusts `tailscale0` in the firewall, and the
sleep targets are disabled, so it stays reachable without any of the
keep-awake steps above. The mac then acts as a client: Add Server with the
desktop's link, and the sidebar shows both hosts side by side.

For the yoga, Tailscale is enabled but `tailscale0` is not trusted and the
default NixOS firewall drops inbound traffic; to host from it add either the
same `trustedInterfaces` line or
`networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 6768 ];`.

## Handy CLI bits

- `orca status`: is the local runtime up and reachable.
- `orca agent-context`: the machine-readable command schema agents can use
  to drive Orca themselves.
