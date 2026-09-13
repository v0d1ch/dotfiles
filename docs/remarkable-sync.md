# reMarkable 2 -> Obsidian (Syncthing over Tailscale)

Working since 13.9.2026. One-way: the tablet's document store is pushed to
the macbook, where a converter turns it into folders, PDFs and markdown
notes inside the Obsidian vault. Nothing is ever written back to the tablet.

```
tablet /home/root/.local/share/remarkable/xochitl   (Syncthing, send-only)
   -> macbook ~/reMarkable/raw                       (Syncthing, receive-only)
   -> ~/Sync/obsidian/reMarkable/<folders>/<Name>.pdf + <Name>.md
      (launchd agent remarkable-to-obsidian, every 5 min)
   -> other devices via the existing ~/Sync share; history via Obsidian Git
```

## Tablet (reMarkable 2, firmware 3.28, armv7, 1 GB RAM)

- SSH: `ssh root@10.11.99.1` over USB (key installed), or
  `ssh root@remarkable` over Tailscale SSH once the tablet is awake.
  Password: Settings > Help > Copyrights and licenses, bottom of the page.
- Root partition has ~12 MB free and is replaced on firmware updates, so
  everything lives in `/home/root/opt` (6 GB, persists):
  - `tailscale/` static arm build 1.102.4, state in `tailscaled.state`.
    The kernel has no tun module, so tailscaled runs with
    `--tun=userspace-networking`. Inbound connections to the tablet's
    tailnet IP still work (they are forwarded to localhost), which is all
    Syncthing and SSH need. Tailscale SSH is enabled (`tailscale set --ssh`).
  - `syncthing/` v2.1.5 linux-arm, config in `syncthing/config`, GUI on
    127.0.0.1:8384 (reach it with `ssh -L 8385:127.0.0.1:8384 root@...`).
    Relays, global discovery and NAT traversal are off; it only talks over
    LAN, USB or Tailscale. Folder `remarkable` is **sendonly**, ignores
    `*.thumbnails`, `*.cache`, `*.textconversion`, `*.lock`.
  - `rm-install.sh`, `tailscaled.service`, `syncthing.service`: the units are
    symlinked into `/etc/systemd/system`. **After a firmware update** the
    symlinks are gone; re-run the last block of `rm-install.sh` (ln -sf +
    daemon-reload + enable --now).
- Configure Syncthing from the shell with
  `/home/root/opt/syncthing/syncthing cli --home=/home/root/opt/syncthing/config config ...`.
- The tablet drops Wi-Fi and USB networking when it sleeps; it only syncs
  while awake. Set a long auto-sleep while doing maintenance.
- Never `modprobe tun` blindly: it hung the device once.

## Macbook

- Syncthing device `remarkable` (ID `2VPLR4I-...`), addresses
  `tcp://100.112.224.38:22000` + dynamic. Folder `remarkable` is
  **receiveonly** at `~/reMarkable/raw`. Configured through the REST API;
  nothing to declare in nix (the Syncthing config is stateful, like the
  tatty-ysvfv share).
- Converter `home/remarkable/remarkable-to-obsidian.py`, installed by
  home-manager as `~/.local/bin/remarkable-to-obsidian` and run by the
  launchd agent `remarkable-to-obsidian` (darwin/configuration.nix). Log:
  `~/reMarkable/convert.log`. State and OCR cache: `~/reMarkable/cache`.
- Python deps in an unmanaged venv (rmc is not packaged in nixpkgs):
  `python3 -m venv ~/reMarkable/venv && ~/reMarkable/venv/bin/pip install rmc svglib reportlab pypdf pypdfium2`
- Handwriting transcription only for notebooks under the tablet folders in
  `REMARKABLE_OCR_FOLDERS` (default `Notes`; other folders hold drawings and
  are only rendered). Uses ollama model `qwen2.5vl:7b` (~6 GB) on the
  local ollama launchd agent. Cached per page by content hash, so only new
  or edited pages are re-transcribed. Pages are marked
  `_(transcription pending)_` while ollama or the model is unavailable and
  filled in on a later run. Override with `REMARKABLE_OCR_MODEL`.
- Manual run: `~/reMarkable/venv/bin/python ~/.local/bin/remarkable-to-obsidian -v`
  (`--no-ocr`, `--force`, `--only NAME`).

## Vault side

- Output root `~/Sync/obsidian/reMarkable/`, mirroring the tablet's folders.
  Every document gets a `.md` note (frontmatter: remarkable_id, type,
  modified, pages; tags `remarkable`, `remarkable/<type>`) that embeds the
  PDF. Notebooks are rendered to PDF page by page; PDFs and EPUBs are copied
  through. Pen annotations on PDFs are **not** overlaid (noted in the .md).
- Documents moved to the tablet's trash or deleted disappear from the vault
  on the next run. Renames/moves on the tablet are followed.
- `.gitignore` in the vault excludes `reMarkable/**/*.pdf|epub`: Syncthing
  carries the binaries to every device, `~/reMarkable/raw` has the
  originals, and only the notes go to GitHub via Obsidian Git.
- Obsidian Git (free replacement for Obsidian Sync) is enabled in the vault:
  auto commit+push every 5 min to `git@github.com:v0d1ch/obsidian.git`.
  Run it on the macbook only. `/obsidian/.git` is in the macbook's
  Syncthing ignore list for tatty-ysvfv so other devices get the files but
  never the repo metadata.

## Gotchas

- rmc's SVG export draws typed text without word wrap and does not know
  the newest pen colours; the converter renders in-process with a
  fallback palette and pulls typed text straight into the note.
- BusyBox on the tablet: `head -n`, no `timeout`, no `--wildcards` for tar.
- `tailscale up` blocks; run it in the background and read the auth URL
  from `/home/root/opt/tailscale/up.log`.
