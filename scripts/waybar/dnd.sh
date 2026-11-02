STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/dnd-state"
if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "1" ]; then
  echo '{"text": "󰂛", "tooltip": "DND: On"}'
else
  echo '{"text": "󰂟", "tooltip": "DND: Off"}'
fi
