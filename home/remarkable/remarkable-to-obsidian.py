#!/usr/bin/env python3
"""Turn the reMarkable raw document store into an Obsidian-friendly tree.

Input : ~/reMarkable/raw   (Syncthing receive-only copy of the tablet's
                            ~/.local/share/remarkable/xochitl, UUID-named)
Output: ~/Sync/obsidian/reMarkable/<tablet folders>/<Name>.pdf + <Name>.md

- Folder tree and names come from the *.metadata files (trash is skipped).
- PDFs/EPUBs are copied through unchanged (pen annotations are not overlaid).
- Notebooks are rendered page by page with rmc -> svglib -> one PDF.
- Each document gets a markdown note embedding the PDF; notebooks also get a
  handwriting transcription per page from a local ollama vision model, cached
  by the page's content hash so re-runs only OCR new/changed pages.
- Documents deleted on the tablet are removed from the vault on the next run.
- Tablet tags (document and page tags) become `tags: [[name]]` wikilinks in the
  note, following the vault convention of one empty note per tag in Tags/;
  missing tag notes are created (matching existing ones case-insensitively).

Runs from the venv at ~/reMarkable/venv (rmc, svglib, reportlab, pypdf,
pypdfium2). Env: REMARKABLE_RAW, REMARKABLE_OUT, REMARKABLE_OCR_MODEL,
OLLAMA_URL, REMARKABLE_OCR_FOLDERS (default "Notes"), REMARKABLE_TAGS_DIR
(default <vault>/Tags). Flags: --no-ocr, --force, --only SUBSTR, -v.
"""
import argparse, base64, hashlib, io, json, os, re, shutil, subprocess, sys, time, urllib.request, urllib.error
from datetime import datetime, timezone
from pathlib import Path

HOME = Path.home()
RAW = Path(os.environ.get("REMARKABLE_RAW", HOME / "reMarkable/raw"))
OUT = Path(os.environ.get("REMARKABLE_OUT", HOME / "Sync/obsidian/reMarkable"))
TAGS_DIR = Path(os.environ.get("REMARKABLE_TAGS_DIR", OUT.parent / "Tags"))
CACHE = HOME / "reMarkable/cache"
STATE = CACHE / "state.json"
LOCK = CACHE / "run.lock"
MODEL = os.environ.get("REMARKABLE_OCR_MODEL", "qwen2.5vl:7b")
OLLAMA = os.environ.get("OLLAMA_URL", "http://127.0.0.1:11434")
# Only notebooks in these tablet folders (comma separated, subfolders included)
# get handwriting OCR; the rest may be drawings and are only rendered.
OCR_FOLDERS = [f.strip().strip("/") for f in os.environ.get("REMARKABLE_OCR_FOLDERS", "Notes").split(",") if f.strip()]
OCR_PROMPT = ("Transcribe all handwritten text in this image as plain markdown. "
              "Keep line breaks, headings and lists. Describe drawings or diagrams "
              "briefly in [square brackets]. If the page is blank, output exactly: (blank). "
              "Output only the transcription, no commentary.")

BAD = re.compile(r'[\\/:*?"<>|#^\[\]]+')
def sanitize(name: str) -> str:
    name = BAD.sub("-", name).strip(" .")
    return name[:120] or "untitled"

def log(*a):
    print(datetime.now().strftime("%H:%M:%S"), *a, file=sys.stderr, flush=True)

def load_json(p: Path, default=None):
    try:
        return json.loads(p.read_text())
    except Exception:
        return default

# ---------- tablet metadata ----------
def load_meta():
    meta = {}
    for f in RAW.glob("*.metadata"):
        d = load_json(f)
        if d:
            meta[f.stem] = d
    return meta

def doc_path(uuid, meta, _seen=None):
    """Folder path of a doc inside the vault, or None if trashed/deleted."""
    parts, cur, seen = [], meta[uuid].get("parent", ""), set()
    if meta[uuid].get("deleted"):
        return None
    while cur:
        if cur == "trash" or cur in seen or cur not in meta or meta[cur].get("deleted"):
            return None if cur == "trash" or (cur in meta and meta[cur].get("deleted")) else Path(*reversed(parts))
        seen.add(cur)
        parts.append(sanitize(meta[cur].get("visibleName", cur)))
        cur = meta[cur].get("parent", "")
    return Path(*reversed(parts)) if parts else Path()

def page_ids(content):
    cp = content.get("cPages", {}).get("pages")
    if cp:
        return [p["id"] for p in cp if "deleted" not in p]
    return list(content.get("pages", []))

# ---------- rendering ----------
def _patch_rmc():
    """rmc draws typed text as unwrapped, unescaped single lines and crashes on
    pen colours newer than its palette. Patch both in-process."""
    import html, textwrap
    from rmc.exporters import writing_tools as wt, svg as rsvg
    from rmscene.text import TextDocument
    if getattr(rsvg, "_patched", False):
        return
    wt.RM_PALETTE = _Palette(wt.RM_PALETTE)
    FONT_PT = {"heading": 14, "bold": 8}
    PREFIX = {"bullet": "\u2022 ", "bullet2": "    \u2022 ", "checkbox": "\u2610 ", "checkbox_checked": "\u2611 "}
    def draw_text(text, output):
        output.write('\t\t<g class="root-text" style="display:inline">\n<style>'
                     'text.heading{font:14pt serif}text.bold{font:8pt sans-serif;font-weight:bold}'
                     'text,text.plain{font:7pt sans-serif}</style>\n')
        width_pt = max(rsvg.xx(text.width or rsvg.SCREEN_WIDTH), 100)
        y = text.pos_y + rsvg.TEXT_TOP_Y
        for para in TextDocument.from_scene_item(text).contents:
            style = para.style.value
            line_h = rsvg.LINE_HEIGHTS.get(style, 70)
            y += line_h
            cls = style.name.lower()
            content = str(para).strip()
            if not content:
                continue
            pt = FONT_PT.get(cls, 7)
            cols = max(int(width_pt / (pt * 0.52)), 10)
            lines = textwrap.wrap(PREFIX.get(cls, "") + content, cols) or [""]
            for i, line in enumerate(lines):
                if i:
                    y += max(line_h, 35) if line_h < 60 else line_h * 0.6
                output.write(f'\t\t\t<text x="{rsvg.xx(text.pos_x)}" y="{rsvg.yy(y)}" class="{cls}">{html.escape(line)}</text>\n')
        output.write('\t\t</g>\n')
    rsvg.draw_text = draw_text
    rsvg._patched = True

def page_typed_text(tree) -> str:
    """Typed (keyboard) text of a page as markdown, or ''."""
    from rmscene.text import TextDocument
    if tree.root_text is None:
        return ""
    out = []
    for para in TextDocument.from_scene_item(tree.root_text).contents:
        cls, content = para.style.value.name.lower(), str(para).strip()
        if not content:
            out.append(""); continue
        out.append({"heading": "## ", "bold": "**", "bullet": "- ", "bullet2": "    - ",
                    "checkbox": "- [ ] ", "checkbox_checked": "- [x] "}.get(cls, "") + content
                   + ("**" if cls == "bold" else ""))
    return "\n".join(out).strip()

def page_has_strokes(tree) -> bool:
    from rmscene import scene_items as si
    def walk(g):
        for item in g.children.values():
            if isinstance(item, si.Line):
                return True
            if isinstance(item, si.Group) and walk(item):
                return True
        return False
    return walk(tree.root)

def read_page(rm: Path):
    from rmscene import read_tree
    with open(rm, "rb") as fh:
        return read_tree(fh)

def rm_to_svg_text(tree) -> str:
    from rmc.exporters.svg import tree_to_svg
    _patch_rmc()
    buf = io.StringIO()
    tree_to_svg(tree, buf)
    return buf.getvalue()

class _Palette(dict):
    def __missing__(self, key):
        return (0, 0, 0)

def rm_to_pdf_bytes(tree, rm: Path, tmp: Path):
    from svglib.svglib import svg2rlg
    from reportlab.graphics import renderPDF
    svg = tmp / (rm.stem + ".svg")
    svg.write_text(rm_to_svg_text(tree))
    drawing = svg2rlg(str(svg))
    svg.unlink(missing_ok=True)
    if drawing is None:
        raise RuntimeError("svglib returned nothing")
    return renderPDF.drawToString(drawing)

def pdf_page_png(pdf_bytes: bytes) -> bytes:
    import pypdfium2 as pdfium
    doc = pdfium.PdfDocument(pdf_bytes)
    img = doc[0].render(scale=2).to_pil().convert("RGB")
    buf = io.BytesIO(); img.save(buf, format="PNG"); return buf.getvalue()

# ---------- OCR ----------
class OllamaUnavailable(Exception):
    pass

def ollama_transcribe(png: bytes) -> str:
    body = json.dumps({"model": MODEL, "stream": False, "images": [base64.b64encode(png).decode()],
                       "prompt": OCR_PROMPT, "options": {"temperature": 0}}).encode()
    req = urllib.request.Request(f"{OLLAMA}/api/generate", data=body,
                                 headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=600) as r:
            d = json.load(r)
    except urllib.error.HTTPError as e:
        msg = e.read().decode(errors="replace")
        raise OllamaUnavailable(f"HTTP {e.code}: {msg[:200]}")
    except (urllib.error.URLError, TimeoutError, OSError) as e:
        raise OllamaUnavailable(str(e))
    if "error" in d:
        raise OllamaUnavailable(d["error"])
    text = d.get("response", "").strip()
    text = re.sub(r"^```[a-zA-Z]*\s*\n", "", text)
    text = re.sub(r"\n```\s*$", "", text)
    return text.strip()

def cached_transcript(rm: Path, pdf_bytes: bytes, allow_ocr: bool):
    """Return (text, done). done=False means OCR still pending for this page."""
    h = hashlib.sha256(rm.read_bytes()).hexdigest()
    cf = CACHE / "transcripts" / f"{h}.md"
    if cf.exists():
        return cf.read_text(), True
    if not allow_ocr:
        return None, False
    text = ollama_transcribe(pdf_page_png(pdf_bytes))
    cf.parent.mkdir(parents=True, exist_ok=True)
    cf.write_text(text)
    return text, True

# ---------- tags ----------
class TagNotes:
    """The vault keeps one (empty) note per tag in Tags/ and notes link to them
    with [[name]]. Reuse an existing note whatever its case, else create it."""
    def __init__(self, folder: Path):
        self.folder = folder
        self.existing = {p.stem.lower(): p.stem for p in folder.glob("*.md")} if folder.is_dir() else {}
        self.created = 0

    def resolve(self, name: str) -> str:
        stem = sanitize(name)
        hit = self.existing.get(stem.lower())
        if hit:
            return hit
        self.folder.mkdir(parents=True, exist_ok=True)
        (self.folder / f"{stem}.md").touch()
        self.existing[stem.lower()] = stem
        self.created += 1
        log(f"  created tag note {self.folder.name}/{stem}.md")
        return stem

def doc_tags(content, ids, resolve):
    """(document tags, {1-based page number: [tags]}) of a document, deduplicated
    and mapped to the vault's tag note names."""
    def uniq(names):
        out = []
        for n in names:
            r = resolve(n)
            if r not in out:
                out.append(r)
        return out
    tags = uniq(t["name"] for t in content.get("tags", []) if t.get("name", "").strip())
    pos = {pid: i for i, pid in enumerate(ids, 1)}
    by_page = {}
    for t in content.get("pageTags", []):
        if t.get("name", "").strip() and t.get("pageId") in pos:
            by_page.setdefault(pos[t["pageId"]], []).append(t["name"])
    return tags, {n: uniq(v) for n, v in sorted(by_page.items())}

def tag_links(names) -> str:
    return " ".join(f"[[{n}]]" for n in names)

# ---------- notes ----------
def ms_to_iso(ms):
    try:
        return datetime.fromtimestamp(int(ms) / 1000, tz=timezone.utc).astimezone().strftime("%Y-%m-%d %H:%M")
    except Exception:
        return ""

def write_note(md: Path, name, uuid, kind, meta, pages, embed_rel, transcripts, annotated_pages=0,
               tags=(), page_tags=None):
    page_tags = page_tags or {}
    lines = ["---", "source: remarkable", f"remarkable_id: {uuid}", f"type: {kind}",
             f"modified: {ms_to_iso(meta.get('lastModified'))}", f"pages: {pages}",
             "tags:", "  - remarkable", f"  - remarkable/{kind}", "---", "", f"# {name}", ""]
    if tags:
        lines += [f"tags: {tag_links(tags)}", ""]
    if embed_rel:
        lines += [f"![[{embed_rel}]]", ""]
    if kind != "notebook" and annotated_pages:
        lines += [f"> {annotated_pages} page(s) carry pen annotations on the tablet; they are not rendered here.", ""]
    if transcripts is None and page_tags:
        lines += ["## Page tags", ""] + [f"- page {n}: {tag_links(t)}" for n, t in page_tags.items()] + [""]
    if transcripts is not None:
        lines += ["## Transcription", ""]
        for i, t in enumerate(transcripts, 1):
            lines += [f"### Page {i}", ""]
            if i in page_tags:
                lines += [f"tags: {tag_links(page_tags[i])}", ""]
            lines += [(t if t is not None else "_(transcription pending)_"), ""]
    md.parent.mkdir(parents=True, exist_ok=True)
    md.write_text("\n".join(lines))

# ---------- main ----------
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--no-ocr", action="store_true", help="skip handwriting transcription")
    ap.add_argument("--force", action="store_true", help="re-render everything")
    ap.add_argument("--only", help="only documents whose name contains this")
    ap.add_argument("-v", "--verbose", action="store_true")
    args = ap.parse_args()

    CACHE.mkdir(parents=True, exist_ok=True)
    if LOCK.exists() and time.time() - LOCK.stat().st_mtime < 3 * 3600:
        log("another run is active, exiting"); return 0
    LOCK.write_text(str(os.getpid()))
    try:
        return run(args)
    finally:
        LOCK.unlink(missing_ok=True)

def run(args):
    if not RAW.exists():
        log(f"raw folder {RAW} missing"); return 1
    from pypdf import PdfReader, PdfWriter
    state = load_json(STATE, {}) or {}
    meta = load_meta()
    tmp = CACHE / "tmp"; tmp.mkdir(exist_ok=True)
    seen, stats = set(), {"rendered": 0, "copied": 0, "skipped": 0, "ocr": 0, "pending": 0, "errors": 0, "removed": 0, "tag_notes_created": 0}
    ocr_ok = not args.no_ocr
    tag_notes = TagNotes(TAGS_DIR)
    used_names = {}

    docs = [(u, m) for u, m in meta.items() if m.get("type") == "DocumentType"]
    docs.sort(key=lambda um: um[1].get("visibleName", ""))
    for uuid, m in docs:
        name = m.get("visibleName", uuid)
        if args.only and args.only.lower() not in name.lower():
            continue
        folder = doc_path(uuid, meta)
        if folder is None:
            continue  # trashed
        content = load_json(RAW / f"{uuid}.content", {}) or {}
        kind = content.get("fileType") or "notebook"
        if kind not in ("notebook", "pdf", "epub"):
            kind = "pdf" if (RAW / f"{uuid}.pdf").exists() else "notebook"
        stem = sanitize(re.sub(r"\.(pdf|epub)$", "", name, flags=re.I))
        key = (str(folder), stem.lower())
        if used_names.get(key, uuid) != uuid:
            stem = f"{stem} ({uuid[:8]})"
        used_names[key] = uuid
        dest = OUT / folder
        pdf_out, md_out = dest / f"{stem}.pdf", dest / f"{stem}.md"
        seen.add(uuid)

        # tag notes are (re)created on every run, even for up-to-date documents
        all_tags = sorted({tag_notes.resolve(t["name"]) for t in content.get("tags", []) + content.get("pageTags", [])
                           if t.get("name", "").strip()})

        prev = state.get(uuid, {})
        outputs_exist = all(Path(p).exists() for p in prev.get("outputs", []))
        up_to_date = (prev.get("lastModified") == m.get("lastModified") and outputs_exist
                      and prev.get("stem") == stem and prev.get("folder") == str(folder)
                      and prev.get("tags", []) == all_tags)
        if up_to_date and (prev.get("ocr_done", True) or not ocr_ok) and not args.force:
            stats["skipped"] += 1
            continue

        # a rename/move: drop old outputs
        for p in prev.get("outputs", []):
            if Path(p).parent != dest or Path(p).stem != stem:
                Path(p).unlink(missing_ok=True)

        outputs, transcripts, ocr_done, pages = [], None, True, 0
        try:
            dest.mkdir(parents=True, exist_ok=True)
            if kind in ("pdf", "epub"):
                src = RAW / f"{uuid}.{kind}"
                if not src.exists():
                    raise FileNotFoundError(src.name)
                target = dest / f"{stem}.{kind}"
                if not up_to_date or not target.exists():
                    shutil.copy2(src, target); stats["copied"] += 1
                outputs.append(str(target))
                pages = content.get("pageCount") or len(page_ids(content))
                annotated = sum(1 for pid in page_ids(content) if (RAW / uuid / f"{pid}.rm").exists())
                embed = f"reMarkable/{folder}/{stem}.{kind}" if str(folder) != "." else f"reMarkable/{stem}.{kind}"
                tags, page_tags = doc_tags(content, page_ids(content), tag_notes.resolve)
                write_note(md_out, stem, uuid, kind, m, pages, embed if kind == "pdf" else None, None, annotated,
                           tags=tags, page_tags=page_tags)
                if kind == "epub":
                    md_out.write_text(md_out.read_text() + f"\n[[{embed}|Open EPUB]]\n")
                outputs.append(str(md_out))
            else:
                ids = [pid for pid in page_ids(content) if (RAW / uuid / f"{pid}.rm").exists()]
                pages = len(ids)
                writer, transcripts = PdfWriter(), []
                in_ocr_folder = any(str(folder) == f or str(folder).startswith(f + "/") for f in OCR_FOLDERS)
                doc_ocr = ocr_ok and in_ocr_folder
                need_render = args.force or not up_to_date or not pdf_out.exists()
                for pid in ids:
                    rm = RAW / uuid / f"{pid}.rm"
                    tree = read_page(rm)
                    page_pdf = rm_to_pdf_bytes(tree, rm, tmp)
                    if need_render:
                        for pg in PdfReader(io.BytesIO(page_pdf)).pages:
                            writer.add_page(pg)
                    typed = page_typed_text(tree)
                    if not page_has_strokes(tree):           # nothing handwritten: no OCR needed
                        transcripts.append(typed or "(blank)"); continue
                    if not in_ocr_folder:                    # drawings etc.: render only
                        transcripts.append(typed or "_(handwriting not transcribed: folder outside REMARKABLE_OCR_FOLDERS)_"); continue
                    if doc_ocr:
                        try:
                            text, done = cached_transcript(rm, page_pdf, allow_ocr=True)
                            if done: stats["ocr"] += 1
                        except OllamaUnavailable as e:
                            log(f"  ocr unavailable ({e}); continuing without"); ocr_ok = doc_ocr = False
                            text, done = cached_transcript(rm, page_pdf, allow_ocr=False)
                    else:
                        text, done = cached_transcript(rm, page_pdf, allow_ocr=False)
                    if typed:
                        text = typed + "\n\n**Handwritten:**\n\n" + (text if text is not None else "_(transcription pending)_")
                    transcripts.append(text)
                    if not done:
                        ocr_done = False; stats["pending"] += 1
                if need_render:
                    if pages:
                        with open(pdf_out, "wb") as fh: writer.write(fh)
                    elif pdf_out.exists():
                        pdf_out.unlink()
                    stats["rendered"] += 1
                if pdf_out.exists():
                    outputs.append(str(pdf_out))
                embed = (f"reMarkable/{folder}/{stem}.pdf" if str(folder) != "." else f"reMarkable/{stem}.pdf") if pages else None
                tags, page_tags = doc_tags(content, ids, tag_notes.resolve)
                write_note(md_out, stem, uuid, kind, m, pages, embed, transcripts, tags=tags, page_tags=page_tags)
                outputs.append(str(md_out))
            state[uuid] = {"lastModified": m.get("lastModified"), "outputs": outputs, "stem": stem,
                           "folder": str(folder), "ocr_done": ocr_done, "kind": kind, "tags": all_tags}
            if args.verbose:
                log(f"  {kind:8} {folder}/{stem}  pages={pages} ocr_done={ocr_done}")
        except Exception as e:
            stats["errors"] += 1
            log(f"  ERROR {name} ({uuid[:8]}): {e}")
        json.dump(state, open(STATE, "w"), indent=1)

    # documents gone from the tablet (or trashed): remove their outputs
    if not args.only:
        for uuid in list(state):
            if uuid not in seen:
                for p in state[uuid].get("outputs", []):
                    Path(p).unlink(missing_ok=True); stats["removed"] += 1
                del state[uuid]
        for d in sorted((p for p in OUT.rglob("*") if p.is_dir()), reverse=True):
            if not any(d.iterdir()):
                d.rmdir()
    json.dump(state, open(STATE, "w"), indent=1)
    shutil.rmtree(tmp, ignore_errors=True)
    stats["tag_notes_created"] = tag_notes.created
    log("done", json.dumps(stats))
    return 0

if __name__ == "__main__":
    sys.exit(main())
