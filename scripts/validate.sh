#!/usr/bin/env bash
# Runs every available check. Exit code is non-zero if any check fails.
set -uo pipefail
cd "$(dirname "$0")/.."
fail=0
step() { printf '\n== %s\n' "$1"; }
bad() { echo "FAIL: $1"; fail=1; }

step "JSON syntax"
while IFS= read -r f; do
  if python3 -m json.tool "$f" >/dev/null 2>&1; then echo "ok  $f"; else bad "$f is not valid JSON"; fi
done < <(find . -name '*.json' -not -path './.git/*' -not -path './node_modules/*' | sort)

step "Skill frontmatter"
for skill in skills/*/SKILL.md .agents/skills/*/SKILL.md; do
  [ -e "$skill" ] || continue
  python3 -I - "$skill" <<'PY' || fail=1
import os, re, sys
p = sys.argv[1]
text = open(p, encoding="utf-8").read()
m = re.match(r"---\n(.*?)\n---\n", text, re.S)
if not m: print(f"FAIL {p}: no frontmatter"); sys.exit(1)
top = re.findall(r"^([A-Za-z][\w-]*):", m.group(1), re.M)
fm = dict(re.findall(r"^([A-Za-z][\w-]*):\s*(.*)$", m.group(1), re.M))
ok = True
for k in ("name", "description"):
    if not fm.get(k): print(f"FAIL {p}: missing {k}"); ok = False
allowed = {"name", "description", "license", "compatibility", "metadata"}
extra = set(top) - allowed - {"author", "version"}
if extra: print(f"FAIL {p}: non-portable fields {sorted(extra)}"); ok = False
folder = os.path.basename(os.path.dirname(p))
if fm.get("name") != folder: print(f"FAIL {p}: name {fm.get('name')!r} != folder {folder!r}"); ok = False
if len(fm.get("description", "")) > 1024: print(f"FAIL {p}: description > 1024 chars"); ok = False
if not re.fullmatch(r"[a-z0-9]+(-[a-z0-9]+)*", fm.get("name", "")): print(f"FAIL {p}: bad name format"); ok = False
if ok: print(f"ok  {p}")
sys.exit(0 if ok else 1)
PY
done

step "Skill copy in sync"
scripts/sync-skill.sh --check || fail=1

step "Names and versions agree across manifests"
python3 -I - <<'PY' || fail=1
import json, sys
def load(p): return json.load(open(p))
cp = load(".claude-plugin/plugin.json")
cm = load(".claude-plugin/marketplace.json")
cx = load("plugin.json")
am = load(".agents/plugins/marketplace.json")
names = {"claude plugin.json": cp["name"], "root plugin.json": cx["name"],
         "claude marketplace entry": cm["plugins"][0]["name"], "codex marketplace entry": am["plugins"][0]["name"]}
vers = {"claude plugin.json": cp["version"], "root plugin.json": cx["version"]}
ok = True
if len(set(names.values())) != 1: print("FAIL names differ:", names); ok = False
if len(set(vers.values())) != 1: print("FAIL versions differ:", vers); ok = False
if cm["name"] != am["name"]: print("FAIL marketplace names differ"); ok = False
if cp["name"].startswith(("claude-", "anthropic-")): print("FAIL reserved name prefix"); ok = False
urls = {load(".mcp.json")["mcpServers"]["influently"]["url"], load("mcp.json")["mcpServers"]["influently"]["url"]}
if len(urls) != 1: print("FAIL MCP urls differ:", urls); ok = False
if load(".mcp.json")["mcpServers"]["influently"].get("type") != "http": print("FAIL .mcp.json type"); ok = False
changelog = open("CHANGELOG.md").read()
if f"## {cp['version']}" not in changelog: print("FAIL CHANGELOG lacks current version"); ok = False
if ok: print(f"ok  name={cp['name']} version={cp['version']} marketplace={cm['name']}")
sys.exit(0 if ok else 1)
PY

step "claude plugin validate --strict"
if command -v claude >/dev/null 2>&1; then
  claude plugin validate . --strict || fail=1
else
  echo "skipped: claude CLI not found"
fi

step "Result"
if [ "$fail" -eq 0 ]; then echo "All checks passed"; else echo "Some checks FAILED"; fi
exit "$fail"
