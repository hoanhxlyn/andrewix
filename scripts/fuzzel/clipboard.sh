CACHE="$HOME/.cache/cliphist-previews"
mkdir -p "$CACHE"

dmenu_line() {
  printf '%s\0icon\x1f%s\n' "$1" "$2"
}

selection=$(
  {
    dmenu_line "Clear History" "edit-clear"
    cliphist list | head -n 20 | while IFS=$'\t' read -r id display; do
      if [[ "$display" == "[[ binary data"* ]]; then
        img="$CACHE/$id.png"
        if [[ ! -f "$img" ]]; then
          printf '%s\t%s' "$id" "$display" | cliphist decode > "$img" 2>/dev/null
        fi
        printf '%s\t%s\0icon\x1f%s\n' "$id" "$display" "$img"
      else
        printf '%s\t%s\n' "$id" "$display"
      fi
    done
  } | fuzzel --dmenu --prompt="Clipboard: "
)

if [ -n "$selection" ]; then
  if [ "$selection" = "Clear History" ]; then
    cliphist wipe
    rm -f "$CACHE"/*.png
    rm -f "$HOME/.cache/cliphist/db"
    notify-send "Clipboard history cleared! (history + cache purged)"
  else
    printf '%s' "$selection" | cliphist decode | wl-copy
    notify-send "Copied to clipboard!"
  fi
fi
