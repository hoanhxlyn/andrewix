history=$(makoctl history -j 2>/dev/null)

if [ -z "$history" ] || [ "$history" = "[]" ]; then
  notify-send "Notification History" "No history"
  exit 0
fi

count=$(echo "$history" | jq 'length')
if [ "$count" -eq 0 ]; then
  notify-send "Notification History" "No history"
  exit 0
fi

dmenu_line() {
  printf '%s\0icon\x1f%s\n' "$1" "$2"
}

selection=$(
  {
    dmenu_line "Restore Most Recent" "preferences-desktop-notification"
    echo "$history" | jq -r '.[:5] | .[] | "\(.app_name // "Unknown") | \(.summary)"' | while IFS= read -r line; do
      dmenu_line "$line" "preferences-desktop-notification"
    done
  } | fuzzel --dmenu --prompt="History: "
)

if [ "$selection" = "Restore Most Recent" ]; then
  makoctl restore
elif [ -n "$selection" ]; then
  app_name=${selection%% | *}
  summary=${selection#* | }

  body=$(echo "$history" | jq -r --arg app "$app_name" --arg sum "$summary" '.[] | select(.app_name == $app and .summary == $sum) | .body // "No body" | tostring' | head -1)
  urgency=$(echo "$history" | jq -r --arg app "$app_name" --arg sum "$summary" '.[] | select(.app_name == $app and .summary == $sum) | .urgency // "normal" | tostring' | head -1)

  if [ "$body" != "null" ] && [ -n "$body" ]; then
    notify-send -u "$urgency" "$app_name: $summary" "$body"
  else
    notify-send "$app_name: $summary"
  fi
fi
