#!/usr/bin/env bash
# UserPromptSubmit hook: tracks caveman mode -> statusline flag file.
# statusline.sh reads ${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.caveman-active and
# renders [CAVE:<mode>]. Nothing else writes that flag, so this hook is the
# writer half of the pair. Registered in ~/.claude/settings.json.
set -u

flag="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.caveman-active"

input=$(cat)
# jq may be absent from the hook PATH; on failure fall back to the raw payload
# (grep still finds /caveman inside the JSON envelope).
prompt=$(printf '%s' "$input" | jq -r '.prompt // empty' 2>/dev/null) || prompt=""
[ -n "$prompt" ] || prompt="$input"

lc=$(printf '%s' "$prompt" | tr '[:upper:]' '[:lower:]')

# --- deactivation wins over activation ---
case "$lc" in
  *"stop caveman"*|*"normal mode"*|*"/caveman off"*|*"/caveman stop"*)
    rm -f "$flag"
    exit 0 ;;
esac

# --- activation: explicit /caveman command or trigger phrases ---
if printf '%s' "$lc" | grep -qE '(^|[[:space:]])/caveman([[:space:]]|$)|caveman mode|talk like caveman|use caveman'; then
  # level after /caveman; POSIX leftmost-longest picks wenyan-* over the bare
  # forms. Falls back to full when no level is given.
  level=$(printf '%s' "$lc" \
    | grep -oE '/caveman[[:space:]]+(wenyan-ultra|wenyan-full|wenyan-lite|wenyan|ultra|full|lite)' \
    | grep -oE '(wenyan-ultra|wenyan-full|wenyan-lite|wenyan|ultra|full|lite)$' \
    | head -1)
  [ -n "$level" ] || level="full"
  printf '%s' "$level" > "$flag"
fi

exit 0
