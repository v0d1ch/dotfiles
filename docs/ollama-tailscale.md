# Ollama over Tailscale

Two ollama servers, both reachable from any device on the tailnet via
MagicDNS, or by Tailscale IP. The names (`<host>.<tailnet>.ts.net`, tailnet
name from `tailscale status --json | jq .MagicDNSSuffix`, not written here
since this repo is public) only resolve on devices with "Use Tailscale DNS"
enabled; it was off on the mac and the phone, so the names failed there. The
Tailscale IPs (`tailscale ip -4` on the server, or `tailscale status`) are
fixed per device and work regardless, so they are the safer thing to type
into a client.

| Machine | URL from the tailnet          | How it is exposed                                   |
|---------|-------------------------------|-----------------------------------------------------|
| nixos   | `http://nixos.<tailnet>.ts.net:11434`| `services.ollama.host = "0.0.0.0"`; firewall trusts `tailscale0` only |
| macbook | `http://sashas-macbook-air.<tailnet>.ts.net:11434` | ollama on loopback + `tailscale serve` TCP proxy (below) |

Locally each machine keeps using `http://127.0.0.1:11434`.

## macbook: one-time tailscale serve setup

Tailscale on the mac is the App Store app, not managed by nix, so this is
imperative. The serve config is stored by tailscaled and survives reboots.

```sh
TS=/Applications/Tailscale.app/Contents/MacOS/Tailscale
$TS serve --bg --tcp 11434 tcp://localhost:11434   # enable
$TS serve status                                    # check
$TS serve --tcp=11434 off                           # disable
```

## Clients

- Enchanted (iOS/macOS): Settings, Ollama Server URL. Use the nixos URL for
  the AMD GPU, the macbook URL when the desktop is off.
- Msty Studio: add an Ollama provider with the same URL.
- CLI on another machine: `OLLAMA_HOST=http://nixos.<tailnet>.ts.net:11434 ollama run qwen3:14b`.

Models are stored per server; pull on each one you want to use.
