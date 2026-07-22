#!/usr/bin/env bash
# Claude Code statusline, styled after ~/andrewix/config/omp/andrew.omp.json
# Reads the statusline JSON payload from stdin.

set -u

input=$(cat)

# --- colors (24-bit ANSI, matching the oh-my-posh theme) ---
RED=$'\033[38;2;227;100;100m'      # username
GREEN=$'\033[38;2;98;237;139m'     # lightning icon
CYAN=$'\033[38;2;86;182;194m'      # path
PURPLE=$'\033[38;2;212;170;252m'   # git
NODEGREEN=$'\033[38;2;152;195;121m' # model (via)
YELLOW=$'\033[38;2;220;185;119m'   # context / status
WHITE=$'\033[38;2;255;255;255m'
RESET=$'\033[0m'

# --- nerd-font glyphs (kept as separate vars, never mixed into printf's %s count) ---
ICON_LIGHTNING=$'\U000F140B'  # lightning bolt, matches andrew.omp.json's text segment
ICON_FOLDER=$'\UF07B'         # folder, matches the path segment's "folder" style
ICON_GIT=$'\UE725'           # git branch (nf-dev-git_branch)
ICON_MODEL=$'\UF544'          # robot, denotes the Claude model (new "via" segment)
ICON_CTX=$'\UF0E4'            # dashboard/gauge, denotes context-window usage (new segment)

# --- fields from stdin JSON ---
model_name=$(printf '%s' "$input" | jq -r '.model.display_name // "Claude"')
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
[ -n "$cwd" ] || cwd="$PWD"

used_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
remaining_pct=$(printf '%s' "$input" | jq -r '.context_window.remaining_percentage // empty')
total_input=$(printf '%s' "$input" | jq -r '.context_window.total_input_tokens // empty')
ctx_size=$(printf '%s' "$input" | jq -r '.context_window.context_window_size // empty')
exceeds_200k=$(printf '%s' "$input" | jq -r '.exceeds_200k_tokens // empty')

# --- path: basename only ---
short_path=$(basename "$cwd")

# --- git branch + status (skip optional locks so we never block on git's index lock) ---
git_segment=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
           || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    git_status=""

    # ahead/behind upstream
    if git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
      ahead=$(git -C "$cwd" --no-optional-locks rev-list --count '@{u}..HEAD' 2>/dev/null || echo 0)
      behind=$(git -C "$cwd" --no-optional-locks rev-list --count 'HEAD..@{u}' 2>/dev/null || echo 0)
      [ "$ahead" -gt 0 ] && git_status="${git_status} ↑${ahead}"
      [ "$behind" -gt 0 ] && git_status="${git_status} ↓${behind}"
    fi

    # working / staging counts
    porcelain=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
    working=$(printf '%s\n' "$porcelain" | grep -c '^.[^ ]')
    staging=$(printf '%s\n' "$porcelain" | grep -c '^[^ ]')
    [ "$working" -gt 0 ] && git_status="${git_status} ~${working}"
    [ "$staging" -gt 0 ] && git_status="${git_status} +${staging}"

    git_segment=$(printf '%son%s %s%s %s%s%s ' "$WHITE" "$RESET" "$PURPLE" "$ICON_GIT" "$branch" "$git_status" "$RESET")
  fi
fi

# --- context usage (percentage only) ---
if [ -n "$used_pct" ] && [ "$used_pct" != "null" ]; then
  ctx_display="${used_pct%%.*}%"
elif [ "$exceeds_200k" = "true" ]; then
  ctx_display=">200K"
else
  ctx_display="?%"
fi

# --- caveman mode badge (reads plugin's flag file; absent/symlink = off) ---
ORANGE=$'\033[38;2;217;140;40m'
cave_segment=""
cave_flag="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.caveman-active"
if [ -f "$cave_flag" ] && [ ! -L "$cave_flag" ]; then
  cave_mode=$(head -c 64 "$cave_flag" 2>/dev/null | tr -cd 'a-z0-9-')
  case "$cave_mode" in
    lite|full|ultra|wenyan-lite|wenyan|wenyan-full|wenyan-ultra)
      cave_segment=$(printf ' %s[CAVE:%s]%s' "$ORANGE" "$cave_mode" "$RESET") ;;
  esac
fi

# --- assemble the line ---
printf '%s@%s %s' "$RED" "$(whoami)" "$RESET"
printf '%s%s %s' "$GREEN" "$ICON_LIGHTNING" "$RESET"
printf '%s%s %s' "$CYAN" "$short_path" "$RESET"
printf '%s' "$git_segment"
printf '%svia%s %s%s %s' "$WHITE" "$RESET" "$NODEGREEN" "$model_name" "$RESET"
printf '%s(%s)%s' "$YELLOW" "$ctx_display" "$RESET"
printf '%s' "$cave_segment"
printf '\n'
