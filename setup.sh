#!/usr/bin/env bash
# Sets up a Mac for agentic development: Ghostty + Claude Code + worktree workflow.
# Safe to re-run. Existing config is backed up or merged, never silently replaced.
# Already using Claude Code? It asks whether to merge, start fresh or keep (see README).
#
#   ./setup.sh            install everything
#   ./setup.sh --dry-run      show what would happen, change nothing
#   ./setup.sh --with-linear  also connect Claude Code to Linear (you sign in with /mcp)

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
DRY_RUN=0
WITH_LINEAR=0
for arg in "$@"; do
  case "$arg" in
    --dry-run)     DRY_RUN=1 ;;
    --with-linear) WITH_LINEAR=1 ;;
    *) echo "unknown option: $arg" >&2; exit 1 ;;
  esac
done

say()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
note() { printf '    %s\n' "$*"; }
run()  { if ((DRY_RUN)); then note "[dry-run] $*"; else "$@"; fi; }
has()  { command -v "$1" >/dev/null 2>&1; }

install_file() { # <src> <dest> — backs up a different existing dest first
  local src="$1" dest="$2"
  cmp -s "$src" "$dest" && { note "$dest already up to date"; return; }
  if [[ -f "$dest" ]]; then
    backup_path "$dest" cp
    note "backed up existing $dest to $BACKUP_DIR"
  fi
  run mkdir -p "$(dirname "$dest")"
  run cp "$src" "$dest"
  ((DRY_RUN)) || note "installed $dest"
}

add_to_zshrc() { # <line>
  local line="$1" rc="$HOME/.zshrc"
  grep -qsF "$line" "$rc" && return
  if ((DRY_RUN)); then note "[dry-run] append to $rc: $line"; return; fi
  printf '\n%s\n' "$line" >>"$rc"
  note "added to $rc: $line"
}

install_prereqs() {
  say "Command line tools and Homebrew"
  xcode-select -p >/dev/null 2>&1 || run xcode-select --install
  if ! has brew; then
    run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  has brew || { note "Homebrew not available yet. Re-run this script once it is."; exit 1; }
}

install_tools() {
  say "Ghostty, git tools, tmux, Node manager"
  [[ -d /Applications/Ghostty.app ]] || run brew install --cask ghostty
  local pkg missing=()
  for pkg in gh tmux fnm jq; do has "$pkg" || missing+=("$pkg"); done
  ((${#missing[@]})) && run brew install "${missing[@]}"
  add_to_zshrc 'eval "$(fnm env --use-on-cd --shell zsh)"'
  if ! has node; then
    if has fnm; then run fnm install --lts; else note "run 'fnm install --lts' in a new shell"; fi
  fi
}

install_claude() {
  say "Claude Code"
  if has claude || [[ -x "$BIN_DIR/claude" ]]; then
    note "already installed ($(claude --version 2>/dev/null || echo "$BIN_DIR/claude"))"
  else
    run bash -c 'curl -fsSL https://claude.ai/install.sh | bash'
  fi
  add_to_zshrc 'export PATH="$HOME/.local/bin:$PATH"'
}

install_helpers() {
  say "Helpers: wt (worktree + agent), claude-notify (alerts), claude-guard + claude-mcp-guard (safety hooks)"
  local f
  for f in wt claude-notify claude-guard claude-mcp-guard; do
    install_file "$REPO_DIR/bin/$f" "$BIN_DIR/$f"
    run chmod +x "$BIN_DIR/$f"
  done
}

install_ghostty_config() {
  say "Ghostty config"
  install_file "$REPO_DIR/config/ghostty/config" "$HOME/.config/ghostty/config"
}

# --- An existing Claude setup: merge it, start fresh, or keep it (see README) ---

BACKUP_DIR="$HOME/.claude-backups/$(date +%Y%m%d-%H%M%S)"
EXISTING=()  # everything found
COMMITTED=() # the part committed in a git repo: listed, never moved
CHOICE=keep

find_claude_docs() { # global CLAUDE.md, skills, agents, commands, rules and memory
  local p
  for p in "$HOME/.claude/CLAUDE.md" "$HOME/.claude"/{skills,agents,commands,rules} \
           "$HOME/.claude"/projects/*/memory; do
    [[ -f "$p" || -n "$(ls -A "$p" 2>/dev/null)" ]] && EXISTING+=("$p")
  done
  return 0
}

find_project_docs() { # CLAUDE.md, AGENTS.md, CLAUDE.local.md in each project Claude has opened
  local dir f
  while IFS= read -r dir; do
    [[ "$dir" == "$REPO_DIR" ]] && continue
    for f in "$dir"/{CLAUDE.md,AGENTS.md,CLAUDE.local.md}; do
      [[ -f "$f" ]] || continue
      EXISTING+=("$f")
      git -C "$dir" ls-files --error-unmatch "$f" >/dev/null 2>&1 && COMMITTED+=("$f")
    done
  done < <(jq -r '.projects // {} | keys[]' "$HOME/.claude.json" 2>/dev/null)
  return 0
}

is_committed() { # <path>
  local c
  for c in ${COMMITTED[@]+"${COMMITTED[@]}"}; do [[ "$c" == "$1" ]] && return 0; done
  return 1
}

backup_path() { # <path> <cp|mv> — keeps its place relative to $HOME inside BACKUP_DIR
  local rel="${1#"$HOME"/}"
  run mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
  if [[ "$2" == mv ]]; then run mv "$1" "$BACKUP_DIR/$rel"; else run cp -R "$1" "$BACKUP_DIR/$rel"; fi
}

list_existing() {
  local p
  for p in "${EXISTING[@]}"; do
    if is_committed "$p"; then note "$p  (committed in its repo)"; else note "$p"; fi
  done
}

ask_existing_choice() { # prints merge, fresh or keep
  local answer
  [[ -r /dev/tty ]] || { echo keep; return; }
  {
    echo "    1) Merge: back everything up, then Claude proposes what to keep, with a diff for each change"
    echo "    2) Fresh start: move all of it (memory too) into a backup folder and install the template"
    echo "    3) Keep: leave it all as it is"
  } >/dev/tty
  read -r -p "    Choose 1, 2 or 3 [3]: " answer </dev/tty
  case "$answer" in
    1) echo merge ;;
    2) read -r -p "    Moves the files above to $BACKUP_DIR. Type 'fresh' to confirm: " answer </dev/tty
       [[ "$answer" == fresh ]] && echo fresh || echo keep ;;
    *) echo keep ;;
  esac
}

start_fresh() {
  local p
  for p in "${EXISTING[@]}"; do
    if is_committed "$p"; then note "left $p (it belongs to its repo; change it there with a PR)"; continue; fi
    backup_path "$p" mv
  done
  note "moved to $BACKUP_DIR. To undo, move the files back."
}

back_up_all() {
  local p
  for p in "${EXISTING[@]}"; do backup_path "$p" cp; done
  printf '%s\n' "${EXISTING[@]}" >"$BACKUP_DIR/FOUND.txt"
  note "backed up to $BACKUP_DIR"
}

review_existing_setup() {
  say "Existing Claude setup"
  find_claude_docs
  find_project_docs
  ((${#EXISTING[@]})) || { note "none found"; return 0; }
  list_existing
  ((DRY_RUN)) && { note "[dry-run] would ask: merge, fresh start or keep"; return 0; }
  CHOICE="$(ask_existing_choice)"
  case "$CHOICE" in
    merge) back_up_all ;;
    fresh) start_fresh ;;
    *)     note "kept everything as it is" ;;
  esac
}

merge_prompt() {
  cat <<EOF
Merge my existing Claude Code setup with this template. Everything is backed up in
$BACKUP_DIR, and $BACKUP_DIR/FOUND.txt lists what was found. Use sub-agents to read
the files and bring back only conclusions, so this session stays small.
1. ~/.claude/CLAUDE.md: propose one merged file. Start from config/claude/CLAUDE.md, add
   my rules that still apply, drop duplicates, contradictions and stale lines (dates,
   versions, "currently"). Rules that belong to one project go to that project; say which.
2. Memory folders: list memories that are stale, duplicated or contradict the template,
   and propose deleting or rewriting each one.
3. Skills, agents and commands: flag overlaps with the template and ones that look unused.
4. Project CLAUDE.md / AGENTS.md: suggest changes only. Committed files change through a PR.
Show each change as a diff and wait for my yes before writing anything.
EOF
}

start_merge_session() {
  [[ "$CHOICE" == merge ]] || return 0
  say "Merging your old setup with Claude"
  note "Claude proposes each change as a diff and waits for your yes."
  (cd "$REPO_DIR" && claude --add-dir "$HOME/.claude" --add-dir "$BACKUP_DIR" "$(merge_prompt)")
}

install_claude_md() {
  say "Global CLAUDE.md"
  local dest="$HOME/.claude/CLAUDE.md"
  if [[ -f "$dest" ]]; then
    note "kept your existing $dest (compare with config/claude/CLAUDE.md)"
  else
    install_file "$REPO_DIR/config/claude/CLAUDE.md" "$dest"
  fi
}

# Deep merge: your values win, arrays are unioned in order (yours first),
# and template hooks whose command you already have are skipped.
MERGE_JQ='
  def merge($a; $b):
    if ($a|type) == "object" and ($b|type) == "object" then
      reduce (($a + $b) | keys_unsorted[]) as $k ({}; .[$k] = merge($a[$k]; $b[$k]))
    elif ($a|type) == "array" and ($b|type) == "array" then
      reduce $b[] as $x ($a; if any(.[]; . == $x) then . else . + [$x] end)
    elif $a == null then $b else $a end;
  .[0] as $cur
  | (.[1] | .hooks |= with_entries(.key as $k | .value |= map(
      select([.hooks[].command] - [$cur.hooks[$k][]?.hooks[]?.command] | length > 0)))) as $new
  | merge($cur; $new)
'

install_claude_settings() {
  say "Claude Code settings (merged into ~/.claude/settings.json)"
  local dest="$HOME/.claude/settings.json" merged
  merged="$(mktemp)"
  jq -s "$MERGE_JQ" <(cat "$dest" 2>/dev/null || echo '{}') \
    <(sed "s|__BIN_DIR__|$BIN_DIR|g" "$REPO_DIR/config/claude/settings.json") >"$merged"
  install_file "$merged" "$dest"
  rm -f "$merged"
}

install_linear() {
  say "Linear (MCP server, user scope)"
  if jq -e '.mcpServers.linear' "$HOME/.claude.json" >/dev/null 2>&1; then
    note "already connected"
  else
    run claude mcp add --scope user --transport http linear https://mcp.linear.app/mcp
  fi
  note "sign in: run 'claude', then /mcp, pick linear and authenticate in the browser"
}

main() {
  ((DRY_RUN)) && say "Dry run: nothing will be changed"
  install_prereqs
  install_tools
  install_claude
  review_existing_setup
  install_helpers
  install_ghostty_config
  install_claude_md
  install_claude_settings
  ((WITH_LINEAR)) && install_linear
  say "Done. Open Ghostty, run 'claude' once to sign in, then 'wt <branch>' inside any repo."
  start_merge_session
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then main; fi
