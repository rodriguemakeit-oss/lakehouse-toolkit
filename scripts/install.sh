#!/usr/bin/env bash
# Vendors lakehouse-toolkit into a target project repo so GitHub Copilot (native — not the CLI),
# Claude Code, and Databricks Genie Code all work with zero per-developer setup after a plain
# `git clone` (or, for Genie Code, opening the Databricks Repo).
#
# Usage:
#   ./scripts/install.sh /path/to/target-project
#
# What it copies:
#   standards/                         -> <target>/standards/                  (always overwritten)
#   .github/instructions/              -> <target>/.github/instructions/       (always overwritten)
#   .github/prompts/                   -> <target>/.github/prompts/            (always overwritten)
#   .github/copilot-instructions.md    -> <target>/.github/copilot-instructions.md
#   templates/CLAUDE.md                -> <target>/CLAUDE.md
#   skills/                            -> <target>/.claude/skills/             (always overwritten)
#   skills/                            -> <target>/.assistant/skills/          (always overwritten)
#
# The last two are the same SKILL.md content in two locations: Databricks Genie Code and Claude
# Code both implement the open "Agent Skills" standard (agentskills.io) — same file format
# (`name`/`description` frontmatter + Markdown body), different discovery folder. Genie Code also
# auto-discovers CLAUDE.md (and AGENTS.md, if present) the same way Claude Code does — walking up
# the directory tree, no configuration needed. See:
# https://docs.databricks.com/aws/en/agent-skills/ and https://docs.databricks.com/aws/en/genie-code/skills
#
# For the two files that can hold project-specific additions (copilot-instructions.md, CLAUDE.md),
# only the block between the "lakehouse-toolkit:vendored:start/end" markers is replaced — anything
# a project added outside those markers is preserved. If a target file predates the markers
# entirely, it's left untouched and the fresh version is written next to it as *.new for a manual
# merge, rather than silently overwritten.
#
# Safe to re-run any time to pick up updates (re-sync).

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${1:-}"

if [[ -z "$TARGET_DIR" ]]; then
  echo "Usage: $0 /path/to/target-project" >&2
  exit 1
fi
if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Target directory does not exist: $TARGET_DIR" >&2
  exit 1
fi
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

echo "Vendoring lakehouse-toolkit ($SOURCE_DIR) into $TARGET_DIR"

mkdir -p "$TARGET_DIR/.github/instructions" "$TARGET_DIR/.github/prompts" "$TARGET_DIR/.claude/skills" "$TARGET_DIR/.assistant/skills"

echo "  standards/"
rm -rf "$TARGET_DIR/standards"
cp -R "$SOURCE_DIR/standards" "$TARGET_DIR/standards"

echo "  .github/instructions/"
rm -rf "$TARGET_DIR/.github/instructions"
cp -R "$SOURCE_DIR/.github/instructions" "$TARGET_DIR/.github/instructions"

echo "  .github/prompts/"
rm -rf "$TARGET_DIR/.github/prompts"
cp -R "$SOURCE_DIR/.github/prompts" "$TARGET_DIR/.github/prompts"

echo "  .claude/skills/ (Claude Code)"
rm -rf "$TARGET_DIR/.claude/skills"
cp -R "$SOURCE_DIR/skills" "$TARGET_DIR/.claude/skills"

echo "  .assistant/skills/ (Databricks Genie Code — same SKILL.md files, Agent Skills standard)"
rm -rf "$TARGET_DIR/.assistant/skills"
cp -R "$SOURCE_DIR/skills" "$TARGET_DIR/.assistant/skills"

# Merge a marker-delimited file: replace only the vendored block, keep anything outside it.
merge_vendored_block() {
  local src_file="$1" dst_file="$2"
  local start_marker="<!-- lakehouse-toolkit:vendored:start"
  local end_marker="<!-- lakehouse-toolkit:vendored:end -->"

  if [[ ! -f "$dst_file" ]]; then
    cp "$src_file" "$dst_file"
    echo "  $(basename "$dst_file") (new)"
    return
  fi

  if ! grep -qF "$start_marker" "$dst_file" || ! grep -qF "$end_marker" "$dst_file"; then
    cp "$src_file" "${dst_file}.new"
    echo "  $(basename "$dst_file") already exists without vendor markers — wrote ${dst_file}.new, merge by hand"
    return
  fi

  python3 - "$src_file" "$dst_file" "$start_marker" "$end_marker" <<'PY'
import sys
src_file, dst_file, start_marker, end_marker = sys.argv[1:5]
src = open(src_file).read()
dst = open(dst_file).read()

def block(text):
    s = text.index(start_marker)
    e = text.index(end_marker) + len(end_marker)
    return text[s:e]

new_block = block(src)
s = dst.index(start_marker)
e = dst.index(end_marker) + len(end_marker)
merged = dst[:s] + new_block + dst[e:]
open(dst_file, "w").write(merged)
PY
  echo "  $(basename "$dst_file") (vendored block re-synced, project notes kept)"
}

merge_vendored_block "$SOURCE_DIR/.github/copilot-instructions.md" "$TARGET_DIR/.github/copilot-instructions.md"
merge_vendored_block "$SOURCE_DIR/templates/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"

echo "Done. Commit the result. Re-run this script any time to pick up lakehouse-toolkit updates."
