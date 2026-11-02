EMOJI_FILE="$HOME/.cache/emoji_list.txt"
if [ ! -f "$EMOJI_FILE" ] || [ ! -s "$EMOJI_FILE" ]; then
  notify-send "Fuzzel" "Downloading emoji list..."
  mkdir -p "$(dirname "$EMOJI_FILE")"
  curl -sf https://raw.githubusercontent.com/muan/emojilib/main/dist/emoji-en-US.json \
    | jq -r 'to_entries | .[] | "\(.key) \(.value[0])"' > "$EMOJI_FILE"
fi
selection=$(fuzzel --dmenu --prompt="Emoji: " < "$EMOJI_FILE")
if [ -n "$selection" ]; then
  emoji=$(echo "$selection" | awk '{print $1}')
  echo -n "$emoji" | wl-copy
  notify-send "Emoji" "Copied $emoji to clipboard"
fi
