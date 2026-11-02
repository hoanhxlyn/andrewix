# Mice have no BlueZ-like source: the G703 shows up as a kernel hidpp battery, the
# ATTACK SHARK has to be asked over its dongle. Hidden (empty text) when absent.
icon="󰍽"
case "$1" in
  logitech)
    dir=""
    for d in /sys/class/power_supply/hidpp_battery_*; do
      if [ -e "$d/capacity" ]; then
        dir="$d"
        break
      fi
    done
    [ -n "$dir" ] || { printf '{"text":""}\n'; exit 0; }
    p=$(cat "$dir/capacity" 2>/dev/null || true)
    s=$(cat "$dir/status" 2>/dev/null || true)
    name="Logitech G703"
    ;;
  *)
    # x11ctl exits non-zero when the mouse is asleep: that is "absent", not an error
    p=$(timeout 5 x11ctl info 2>/dev/null | awk '/^battery/ {print $2}' || true)
    [ -n "$p" ] || { printf '{"text":""}\n'; exit 0; }
    s=""
    name="ATTACK SHARK X11SE"
    ;;
esac
suffix=""
if [ -n "$s" ]; then
  suffix=" ($s)"
fi
printf '{"text":"%s %s","tooltip":"%s %s%s"}\n' "$icon" "$p" "$name" "$p" "$suffix"
