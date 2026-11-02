# xpad exposes no battery, and the pad's radio sleep never reaches the
# kernel (the USB device and input node stay), so the bar keys off real
# input with a grace window: it clears after 60s of silence.
STATE="${XDG_RUNTIME_DIR:-/tmp}/waybar-gamepad"
ACTIVE="$STATE.last"
pad=""
ev=""
for js in /sys/class/input/js*; do
  [ -r "$js/device/name" ] || continue
  name=$(cat "$js/device/name")
  case "$name" in
    *[Xx]box* | *[Xx]-[Bb]ox*) pad="$name"; ev=/dev/input/$(basename "$js"/device/event*); break ;;
  esac
done
# notify only on real plug/unplug (radio sleep is invisible here)
prev=$(cat "$STATE" 2>/dev/null || true)
if [ ! -e "$STATE" ]; then
  printf '%s' "$pad" > "$STATE"
elif [ "$pad" != "$prev" ]; then
  if [ -n "$pad" ]; then
    notify-send "Controller" "$pad connected"
  else
    notify-send "Controller" "$prev disconnected"
  fi
  printf '%s' "$pad" > "$STATE"
fi
now=$(date +%s)
if [ -n "$ev" ] && [ "$( { timeout 2 cat "$ev" 2>/dev/null || true; } | wc -c )" -gt 0 ]; then
  printf '%s' "$now" > "$ACTIVE"
fi
last=$(cat "$ACTIVE" 2>/dev/null || true)
if [ -n "$pad" ] && [ -n "$last" ] && [ "$((now - last))" -le 60 ]; then
  printf '{"text":"󰊗","tooltip":"%s"}\n' "$pad"
else
  printf '{"text":""}\n'
fi
