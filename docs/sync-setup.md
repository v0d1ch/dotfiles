# File sync + iPhone vault access (Syncthing + Tailscale HTTPS)

What the nix config provides (added 27.8.2026):

- `nixos/configuration.nix`: Syncthing as a system service on the desktop
  (always-on hub, starts at boot, shares root `~/Sync`), plus a WebDAV
  server (hacdias/webdav) over `~/Sync` on `127.0.0.1:6065`.
- `darwin/configuration.nix`: Syncthing as a launchd agent on the macbook.

The WebDAV server exists only for Strongbox on the iPhone. It is never
exposed publicly: `tailscale serve` fronts it with a real Let's Encrypt
certificate, reachable from the tailnet only.

## One-time manual steps

### 1. Rebuild

```sh
sudo nixos-rebuild switch --flake .#nixos      # desktop
sudo darwin-rebuild switch --flake .#macbook   # macbook
```

### 2. WebDAV credentials (desktop, Sasha only)

```sh
sudo mkdir -p /etc/webdav
sudo touch /etc/webdav/env
sudo chmod 600 /etc/webdav/env   # lock down BEFORE writing the secret
sudo -e /etc/webdav/env
# contents:
#   WEBDAV_USERNAME=<pick one>
#   WEBDAV_PASSWORD=<long random>
sudo systemctl restart webdav
```

### 3. Tailscale HTTPS (once per tailnet)

In the admin console (https://login.tailscale.com/admin/dns): enable
MagicDNS and HTTPS Certificates. Then on the desktop:

```sh
sudo tailscale serve --bg 6065
tailscale serve status        # shows the https URL, port 443
tailscale status --json | jq -r '.Self.DNSName'   # the exact hostname
```

The serve config persists across reboots. Undo with
`sudo tailscale serve reset`.

### 4. Pair Syncthing devices

On each machine open http://127.0.0.1:8384. Actions -> Show ID on one,
Add Remote Device on the other (over the tailnet both directions work),
confirm on both sides. Share the desktop's `Default Folder` (`~/Sync`)
with the macbook and accept it there as `/Users/v0d1ch/Sync`.

Recommended on both: folder -> Edit -> File Versioning -> Staggered,
so a bad save of the vault never destroys history.

### 5. Move the password database in

On ONE machine only (let Syncthing propagate it):

```sh
mkdir -p ~/Sync/vault
mv <current location>/Passwords.kdbx ~/Sync/vault/
```

Re-point KeePassXC on both machines to the new path. Once confident,
retire the daily rsync and delete the Google Drive copy of the vault.

### 6. Strongbox on the iPhone

Tailscale VPN on. Strongbox -> add database -> WebDAV:

- URL: `https://<desktop-dns-name>/` (from step 3; `~/Sync` is the root,
  so the database is under `/vault/`)
- Username/password: the values from `/etc/webdav/env`

Strongbox keeps a local cache, so the vault stays readable offline; it
syncs writes back over WebDAV when the desktop is reachable.

## Notes

- The yoga laptop can join the mesh by copying the `services.syncthing`
  block from `nixos/configuration.nix` (drop the webdav part).
- iPhone as a full Syncthing peer instead of WebDAV: install Mobius Sync
  or Synctrain and share the folder with it; the WebDAV route was chosen
  because Strongbox syncs itself and needs no extra app.
