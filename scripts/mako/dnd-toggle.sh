STATE_FILE="$XDG_RUNTIME_DIR/dnd-state"
if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "1" ]; then
  echo "0" > "$STATE_FILE"
  makoctl mode -s default
  notify-send -u critical "DND" "Notifications enabled" -i stock_bell
else
  echo "1" > "$STATE_FILE"
  makoctl mode -s do-not-disturb
  notify-send -u critical "DND" "Do Not Disturb enabled" -i notification-disabled
fi
# waybar's dnd module runs once per signal, not on an interval
pkill --signal RTMIN+10 waybar || true
