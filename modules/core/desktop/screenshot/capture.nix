{
  core.desktop.screenshot.capture.homeManager = {
    config,
    host,
    pkgs,
    ...
  }: let
    inherit (config.lib.stylix) colors;
    focusedOutput =
      if host.wm == "hyprland"
      then "hyprctl monitors -j | jq -r '.[] | select(.focused) | .name'"
      else "niri msg --json focused-output | jq -r .name";
    # one capture at a time: a second key press while slurp/satty is already up is ignored
    lock = ''
      exec 9>"''${XDG_RUNTIME_DIR:-/tmp}/screenshot.lock"
      ${pkgs.util-linux}/bin/flock -n 9 || exit 0
    '';
    screenshot-annotate = pkgs.writeShellScriptBin "screenshot-annotate" ''
      ${lock}
      state=$HOME/.local/state/screenshot/last-region
      mkdir -p ~/Pictures/Screenshots "$(dirname "$state")"
      # previous region is offered as a clickable predefined box; drag to pick a new one
      region=$({ [ -f "$state" ] && echo "$(cat "$state") last"; } |
        slurp -d -b '#00000066' -B '#${colors.base0A}33' -c '#${colors.base0D}ff' -s '#${colors.base0D}22') || exit 0
      echo "$region" > "$state"
      grim -g "$region" - | satty -f -
    '';
    screenshot-fullscreen = pkgs.writeShellScriptBin "screenshot-fullscreen" ''
      ${lock}
      mkdir -p ~/Pictures/Screenshots
      grim -o "$(${focusedOutput})" - | satty -f -
    '';
    # toggle recording; the instance that started it waits, so the "saved"
    # notification only fires once wl-screenrec finalized the mp4
    record-toggle = pkgs.writeShellApplication {
      name = "record-toggle";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.libnotify
        pkgs.procps
        pkgs.wl-screenrec
      ];
      text = ''
        if pgrep -x wl-screenrec > /dev/null; then
          pkill -SIGINT wl-screenrec || true
          exit 0
        fi
        # wl-screenrec opens the output via ffmpeg and does not create the dir
        mkdir -p "$HOME/Videos"
        file="$HOME/Videos/recording_$(date +%Y%m%d_%H%M%S).mp4"
        # several outputs -> wl-screenrec bails unless one is picked
        output=$(${focusedOutput})
        notify-send "Screen recording" "Started" || true
        wl-screenrec -f "$file" --output "$output" &
        pid=$!
        pkill --signal RTMIN+11 waybar || true
        if wait "$pid"; then
          notify-send "Screen recording" "Saved to $file" || true
        else
          notify-send "Screen recording" "Recording failed" || true
        fi
        pkill --signal RTMIN+11 waybar || true
      '';
    };
  in {
    home.packages = with pkgs; [
      grim
      slurp
      jq
      screenshot-annotate
      screenshot-fullscreen
      record-toggle
    ];
  };
}
