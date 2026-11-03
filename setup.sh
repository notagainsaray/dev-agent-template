#!/usr/bin/env bash
# Sets up a Mac for agentic development: Ghostty + Claude Code + worktree workflow.
# Safe to re-run. Existing config is backed up or merged, never silently replaced.
#
#   ./setup.sh            install everything
#   ./setup.sh --dry-run  show what would happen, change nothing

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/.local/bin"
DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

say()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
note() { printf '    %s\n' "$*"; }
run()  { if ((DRY_RUN)); then note "[dry-run] $*"; else "$@"; fi; }
has()  { command -v "$1" >/dev/null 2>&1; }

install_file() { # <src> <dest> — backs up a different existing dest first
  local src="$1" dest="$2"
  cmp -s "$src" "$dest" && { note "$dest already up to date"; return; }
  if [[ -f "$dest" ]]; then
    run cp "$dest" "$dest.bak.$(date +%Y%m%d%H%M%S)"
    note "backed up existing $dest"
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
  say "Helpers: wt (worktree + agent), claude-notify (alerts), claude-guard (safety hook)"
  local f
  for f in wt claude-notify claude-guard; do
    install_file "$REPO_DIR/bin/$f" "$BIN_DIR/$f"
    run chmod +x "$BIN_DIR/$f"
  done
}

install_ghostty_config() {
  say "Ghostty config"
  install_file "$REPO_DIR/config/ghostty/config" "$HOME/.config/ghostty/config"
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

main() {
  ((DRY_RUN)) && say "Dry run: nothing will be changed"
  install_prereqs
  install_tools
  install_claude
  install_helpers
  install_ghostty_config
  install_claude_md
  install_claude_settings
  say "Done. Open Ghostty, run 'claude' once to sign in, then 'wt <branch>' inside any repo."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then main; fi
