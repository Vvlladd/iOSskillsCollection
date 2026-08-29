#!/usr/bin/env bash
# iOSskillsCollection installer
# Installs the bundled skills, or pulls any skill from the curated registry.
# Portable: works on macOS's stock bash 3.2 (no mapfile, no associative arrays).
set -euo pipefail

REPO_URL="https://github.com/Vvlladd/iOSskillsCollection"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGISTRY="$HERE/registry/skills.json"

if [ -t 1 ]; then
  bold=$'\033[1m'; dim=$'\033[2m'; red=$'\033[31m'; grn=$'\033[32m'; ylw=$'\033[33m'; rst=$'\033[0m'
else
  bold=""; dim=""; red=""; grn=""; ylw=""; rst=""
fi
say()  { printf '%s\n' "$*"; }
ok()   { printf '%s✓%s %s\n' "$grn" "$rst" "$*"; }
warn() { printf '%s!%s %s\n' "$ylw" "$rst" "$*"; }
die()  { printf '%s✗%s %s\n' "$red" "$rst" "$*" >&2; exit 1; }

TARGET=""; SCOPE="user"; ADD=""; DO_LIST=0; DRY=0

usage() {
  cat <<EOF
${bold}iOSskillsCollection${rst} - lean iOS/Swift Agent Skills

${bold}USAGE${rst}
  ./install.sh [--target TOOL] [--project] [--dry-run]
  ./install.sh --list
  ./install.sh --add <id|owner/repo> [--add <id> ...] [--target TOOL] [--project]

${bold}OPTIONS${rst}
  --target TOOL   claude | codex | cursor | opencode | all   (default: autodetect)
  --project       install into ./.<tool>/skills instead of \$HOME
  --list          print the curated registry of external skills
  --add ID        install an external skill from the registry (repeatable)
  --dry-run       show what would happen, change nothing
  -h, --help      this help

${bold}EXAMPLES${rst}
  ./install.sh --target claude              # bundled skills -> ~/.claude/skills
  ./install.sh --project                    # into this project only
  ./install.sh --list                       # browse the curated external sources
  ./install.sh --add avdlee-swiftui         # pull AvdLee's SwiftUI skill from upstream
  ./install.sh --add avdlee-swift-concurrency --add avdlee-swiftui
  ./install.sh --add AvdLee/Core-Data-Agent-Skill

External skills are fetched from their author's repo at install time. Nothing is
vendored here, so you always get the current upstream version.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --target)  TARGET="${2:-}"; shift 2 ;;
    --project) SCOPE="project"; shift ;;
    --list)    DO_LIST=1; shift ;;
    --add)     [ -n "${2:-}" ] || die "--add needs a value"; ADD="$ADD${ADD:+\n}$2"; shift 2 ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown option: $1 (try --help)" ;;
  esac
done

# ---------------------------------------------------------------- registry --
registry_list() {
  [ -f "$REGISTRY" ] || die "registry not found at $REGISTRY"
  python3 - "$REGISTRY" <<'PY'
import json,sys,textwrap
d=json.load(open(sys.argv[1]))
B="\033[1m";D="\033[2m";Y="\033[33m";R="\033[0m"
if not sys.stdout.isatty(): B=D=Y=R=""
print(f"\n{B}Curated external iOS/Swift Agent Skills{R}  {D}(linked, not vendored){R}\n")
for s in sorted(d["sources"], key=lambda x:-x.get("stars",0)):
    lic=s["license"]
    flag=f"  {Y}[{lic}]{R}" if lic in ("NONE","NOASSERTION") else f"  {D}[{lic}]{R}"
    print(f"{B}{s['id']}{R}{flag}")
    print(f"  {s['name']} - {s['author']}  {D}*{s.get('stars',0)}  {s['repo']}{R}")
    for line in textwrap.wrap(s['why'], 86): print(f"    {line}")
    if s.get("license_note"): print(f"    {Y}note:{R} {s['license_note']}")
    print()
print(f"{B}See also{R}")
for s in d["see_also"]:
    print(f"  {s['repo']}  {D}[{s['license']}] {s['why']}{R}")
print(f"\n{D}Install one with:  ./install.sh --add <id>{R}\n")
PY
}

registry_repo_for() {
  python3 - "$REGISTRY" "$1" <<'PY'
import json,sys
d=json.load(open(sys.argv[1])); q=sys.argv[2]
for s in d["sources"]:
    if s["id"]==q or s["repo"].lower()==q.lower():
        print(s["repo"]); sys.exit(0)
sys.exit(1)
PY
}

# ----------------------------------------------------------------- targets --
skills_dir_for() {
  case "$1" in
    claude)   if [ "$SCOPE" = project ]; then echo ".claude/skills";   else echo "$HOME/.claude/skills";   fi ;;
    codex)    if [ "$SCOPE" = project ]; then echo ".codex/skills";    else echo "$HOME/.codex/skills";    fi ;;
    cursor)   if [ "$SCOPE" = project ]; then echo ".cursor/skills";   else echo "$HOME/.cursor/skills";   fi ;;
    opencode) if [ "$SCOPE" = project ]; then echo ".opencode/skills"; else echo "$HOME/.config/opencode/skills"; fi ;;
    *) die "unknown target: $1 (claude|codex|cursor|opencode|all)" ;;
  esac
}

resolve_targets() {
  if [ -n "$TARGET" ]; then
    if [ "$TARGET" = all ]; then printf '%s\n' claude codex cursor opencode
    else printf '%s\n' "$TARGET"; fi
    return
  fi
  found=""
  [ -d "$HOME/.claude" ] && found="$found claude"
  [ -d "$HOME/.codex"  ] && found="$found codex"
  [ -d "$HOME/.cursor" ] && found="$found cursor"
  [ -z "$found" ] && found=" claude"
  for t in $found; do printf '%s\n' "$t"; done
}

copy_skill() {  # <src_dir> <dest_root>
  src="$1"; root="$2"; name="$(basename "$src")"
  if [ "$DRY" = 1 ]; then say "  ${dim}would install${rst} $name -> $root/$name"; return 0; fi
  mkdir -p "$root"
  rm -rf "${root:?}/$name"
  cp -R "$src" "$root/$name"
  ok "$name"
}

# ----------------------------------------------------------------- actions --
[ "$DO_LIST" = 1 ] && { registry_list; exit 0; }
command -v python3 >/dev/null 2>&1 || die "python3 is required"

if [ -n "$ADD" ]; then
  command -v git >/dev/null 2>&1 || die "git is required to fetch external skills"
  tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
  resolve_targets > "$tmp/targets.txt"
  printf '%b\n' "$ADD" | grep . > "$tmp/wanted.txt"
  total=0

  while IFS= read -r want; do
  if repo="$(registry_repo_for "$want" 2>/dev/null)"; then :
  elif printf '%s' "$want" | grep -Eq '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$'; then repo="$want"
  else warn "'$want' is not a registry id or an owner/repo - skipping"; continue
  fi

  rm -rf "$tmp/src"
  say "${bold}Fetching${rst} https://github.com/$repo"
  git clone -q --depth 1 "https://github.com/$repo.git" "$tmp/src" 2>/dev/null || { warn "clone failed for $repo - skipping"; continue; }

  list="$tmp/skills.txt"; : > "$list"
  [ -d "$tmp/src/skills" ] && find "$tmp/src/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort > "$list"
  if [ ! -s "$list" ]; then
    find "$tmp/src" -name SKILL.md -not -path "*/.git/*" -exec dirname {} \; 2>/dev/null | sort -u > "$list"
  fi
  count="$(grep -c . "$list" || true)"
  if [ "${count:-0}" -eq 0 ]; then warn "no SKILL.md found in $repo - skipping"; continue; fi

  while IFS= read -r tt; do
    [ -z "$tt" ] && continue
    root="$(skills_dir_for "$tt")"
    say "${bold}$tt${rst} ${dim}-> $root${rst}"
    while IFS= read -r d; do
      [ -f "$d/SKILL.md" ] && copy_skill "$d" "$root"
    done < "$list"
    say ""
  done < "$tmp/targets.txt"
  total=$((total+count))
  done < "$tmp/wanted.txt"

  [ "$total" -eq 0 ] && die "nothing installed"
  ok "Installed $total skill(s)"
  say "${dim}Upstream is authoritative - re-run --add to update.${rst}"
  exit 0
fi

# default: install bundled skills
[ -d "$HERE/skills" ] || die "no bundled skills found in $HERE/skills"
n=0; for d in "$HERE"/skills/*/; do [ -f "$d/SKILL.md" ] && n=$((n+1)); done
[ "$n" -eq 0 ] && die "no bundled skills found in $HERE/skills"

say "${bold}iOSskillsCollection${rst} - installing $n skills (${SCOPE} scope)"
say ""
tmpt="$(mktemp)"; trap 'rm -f "$tmpt"' EXIT
resolve_targets > "$tmpt"
while IFS= read -r t; do
  [ -z "$t" ] && continue
  root="$(skills_dir_for "$t")"
  say "${bold}$t${rst} ${dim}-> $root${rst}"
  for d in "$HERE"/skills/*/; do
    [ -f "$d/SKILL.md" ] && copy_skill "${d%/}" "$root"
  done
  if [ "$t" = claude ] && [ -d "$HERE/agents" ]; then
    aroot="$(dirname "$root")/agents"
    if [ "$DRY" = 1 ]; then say "  ${dim}would install${rst} agents -> $aroot"
    else mkdir -p "$aroot"; cp "$HERE/agents/"*.md "$aroot/" && ok "agent: ios-swift-engineer"; fi
  fi
  say ""
done < "$tmpt"

ok "Done."
say ""
say "${bold}Next${rst}"
say "  ./install.sh --list                browse the curated external sources"
say "  ./install.sh --add avdlee-swiftui  pull a skill straight from its author"
say ""
say "${dim}$REPO_URL${rst}"
