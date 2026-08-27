# File sync + vault access on all devices (Syncthing mesh)

Final state (working since 27.8.2026): one Syncthing folder (`tatty-ysvfv`)
synced peer-to-peer between three devices over Tailscale/LAN. No always-on
server required: any two awake devices sync directly.

- Desktop `nixos`: Syncthing as a NixOS system service (starts at boot),
  folder at `/home/v0d1ch/Sync`. Config in `nixos/configuration.nix`.
- MacBook: Syncthing as a home-manager launchd agent (starts at login),
  folder at `/Users/v0d1ch/Sync`. Config in `darwin/configuration.nix`.
- iPhone: third-party Syncthing client (Mobius Sync / Synctrain) holds a
  full local copy; Strongbox opens the database from it via the Files app.

The password database is `keesharexc-sync.kdbx` at the folder root. Both
KeePassXC instances open it from `~/Sync`; Strongbox references it in
place from the sync app's Files location.

## Hard-won gotchas (do not rediscover)

- NixOS module hardening sets `PrivateUsers=true`, which breaks folders
  under `/home` ("mkdir ...: operation not supported"). Overridden with
  `lib.mkForce false` in `nixos/configuration.nix`.
- On macOS the folder path must be `/Users/...`; `/home` is a reserved
  autofs mount ("operation not supported"). A folder's path cannot be
  edited after creation: remove the folder entry and re-add it (same
  folder ID) with the right path. Removing never deletes files.
- Strongbox on iOS: use "Add Existing" -> Files -> the sync app's folder,
  so the file is opened IN PLACE. If the database is imported/copied,
  storage shows "Local Device" and edits silently go to a private copy
  that never syncs. Properties must name the sync app as storage.
- iOS never syncs in the background reliably: open the sync app after
  saving on the phone and before expecting fresh data on it.
- Syncthing conflicts are file-level: a `*.sync-conflict*` kdbx is not an
  error to delete but a copy to merge (KeePassXC: Database -> Merge From
  Database). Staggered file versioning is enabled on the folder.

## WebDAV (retired 27.8.2026)

An interim `services.webdav` + `tailscale serve` setup gave Strongbox
WebDAV access before the phone became a Syncthing peer. The nix config
is removed; finish on the desktop with:

```sh
sudo tailscale serve reset
sudo nixos-rebuild switch --flake .#nixos
sudo rm -r /etc/webdav
```

## Remaining cleanup

- Move plaintext secrets OUT of `~/Sync` and into the database as notes/
  attachments: `Backup-codes-*.txt`, `discord_backup_codes.txt`,
  `proton_recovery_codes.txt`, `proton_recovery_phrase.txt`. They
  currently sync in plaintext to every device.
- Delete stale artifacts in `~/Sync`: `Passwords.kdbx` (old 2022 vault,
  verify first), zero-byte `keesharexc-sync.kdbx.??????` temp files.
- Retire the daily rsync and delete the vault from Google Drive.
- Optional: split the vault into its own small Syncthing folder so the
  phone does not carry the entire ~100 MB of misc files.
- Optional: add the yoga laptop as a fourth peer (copy the syncthing
  block, including the PrivateUsers override).
