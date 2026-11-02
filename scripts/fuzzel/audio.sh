mapfile -t sink_lines < <(
  wpctl status | awk '
    /Sinks:/ { in_sinks=1; next }
    in_sinks && /Sources:/ { in_sinks=0 }
    in_sinks && /[0-9]+\..*\[vol:/ {
      is_def = ($0 ~ /\*/) ? 1 : 0
      match($0, /[0-9]+/, m); id = m[0]
      desc = $0; sub(/.*[0-9]+\. /, "", desc); sub(/[[:space:]]+\[vol:.*/, "", desc)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", desc)
      print id "\t" desc "\t" is_def
    }
  '
)
if [ "${#sink_lines[@]}" -eq 0 ]; then
  notify-send "Audio" "No sinks found"
  exit 1
fi
mapfile -t ids   < <(printf '%s\n' "${sink_lines[@]}" | cut -f1)
mapfile -t descs < <(printf '%s\n' "${sink_lines[@]}" | cut -f2)
mapfile -t defs  < <(printf '%s\n' "${sink_lines[@]}" | cut -f3)
dmenu_line() {
  printf '%s\0icon\x1f%s\n' "$1" "$2"
}
selection=$(for i in "${!ids[@]}"; do
  if [ "${defs[$i]}" = "1" ]; then
    dmenu_line "${descs[$i]}" "object-select"
  else
    printf '%s\n' "${descs[$i]}"
  fi
done | fuzzel --dmenu --prompt="Audio: " --index)
if [ -n "$selection" ]; then
  wpctl set-default "${ids[$selection]}"
  notify-send "Audio" "Switched to ${descs[$selection]}"
fi
