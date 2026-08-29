#!/usr/bin/env python3
"""Validate skills, registry, and plugin manifests. Exit 1 on any error."""
import json, re, sys, pathlib

root = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
errors, warnings = [], []


def err(m): errors.append(m)
def warn(m): warnings.append(m)


def frontmatter(path):
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---"):
        return None
    end = text.find("\n---", 3)
    return text[3:end] if end != -1 else None


# ---- skills -----------------------------------------------------------------
skills_dir = root / "skills"
slugs = []
if not skills_dir.is_dir():
    err("skills/ directory is missing")
else:
    for d in sorted(p for p in skills_dir.iterdir() if p.is_dir()):
        sk = d / "SKILL.md"
        if not sk.is_file():
            err(f"{d.name}: no SKILL.md")
            continue
        fm = frontmatter(sk)
        if fm is None:
            err(f"{d.name}: SKILL.md has no YAML frontmatter")
            continue
        m = re.search(r"(?m)^name:\s*(.+?)\s*$", fm)
        if not m:
            err(f"{d.name}: frontmatter has no 'name'")
        elif m.group(1) != d.name:
            err(f"{d.name}: name '{m.group(1)}' does not match directory")
        elif not re.fullmatch(r"[a-z0-9]+(-[a-z0-9]+)*", m.group(1)):
            err(f"{d.name}: name is not a lowercase slug")
        else:
            slugs.append(m.group(1))

        dm = re.search(r"(?ms)^description:\s*(.+?)(?=\n[a-z_]+:\s|\Z)", fm)
        if not dm:
            err(f"{d.name}: frontmatter has no 'description'")
        else:
            desc = " ".join(dm.group(1).split()).strip("'\"")
            if len(desc) < 40:
                err(f"{d.name}: description is only {len(desc)} chars (need >=40)")
            elif len(desc) > 1024:
                warn(f"{d.name}: description is {len(desc)} chars, unusually long")

        for ref in (d / "references").glob("*.md") if (d / "references").is_dir() else []:
            if ref.stat().st_size == 0:
                err(f"{d.name}: empty reference {ref.name}")

    dupes = {s for s in slugs if slugs.count(s) > 1}
    for s in dupes:
        err(f"duplicate skill slug: {s}")

# ---- registry ---------------------------------------------------------------
reg_path = root / "registry" / "skills.json"
if not reg_path.is_file():
    err("registry/skills.json is missing")
else:
    try:
        reg = json.loads(reg_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        err(f"registry/skills.json is not valid JSON: {e}")
        reg = None
    if reg:
        seen = set()
        for s in reg.get("sources", []):
            sid = s.get("id", "<no id>")
            for field in ("id", "name", "repo", "author", "license", "why"):
                if not s.get(field):
                    err(f"registry {sid}: missing '{field}'")
            if sid in seen:
                err(f"registry: duplicate id '{sid}'")
            seen.add(sid)
            repo = s.get("repo", "")
            if repo and not re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", repo):
                err(f"registry {sid}: repo '{repo}' is not owner/repo")
            if s.get("license") in ("NONE", "NOASSERTION") and not s.get("license_note"):
                err(f"registry {sid}: non-standard license needs a 'license_note'")
        if not reg.get("sources"):
            err("registry: no sources")

# ---- manifests --------------------------------------------------------------
for rel in (".claude-plugin/marketplace.json", ".claude-plugin/plugin.json",
            ".codex-plugin/plugin.json", "plugin.json"):
    p = root / rel
    if not p.is_file():
        err(f"{rel} is missing")
        continue
    try:
        json.loads(p.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        err(f"{rel} is not valid JSON: {e}")

# ---- hygiene ----------------------------------------------------------------
for junk in root.rglob(".DS_Store"):
    if ".git/" not in str(junk):
        err(f"committed junk file: {junk.relative_to(root)}")

# ---- report -----------------------------------------------------------------
for w in warnings:
    print(f"warn  {w}")
for e in errors:
    print(f"ERROR {e}")

n_ext = len(reg.get("sources", [])) if reg_path.is_file() and reg else 0
print(f"\n{len(slugs)} bundled skills, {n_ext} registry sources, "
      f"{len(errors)} error(s), {len(warnings)} warning(s)")
sys.exit(1 if errors else 0)
