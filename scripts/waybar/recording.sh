if pgrep -x wl-screenrec > /dev/null; then
  echo '{"text": "󰑊", "tooltip": "Recording", "class": "recording"}'
else
  echo '{"text": "", "tooltip": "Not recording"}'
fi
