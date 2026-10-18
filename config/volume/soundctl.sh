# soundctl up|down [target]: default target = default sink.
# shebang is added by pkgs.writeShellApplication.
target="${2:-@DEFAULT_AUDIO_SINK@}"
case "${1:-}" in
  up)   exec wpctl set-volume --limit 1.0 "$target" 5%+ ;;
  down) exec wpctl set-volume "$target" 5%- ;;
  *)    echo "usage: soundctl up|down [target]" >&2; exit 1 ;;
esac
