{
  core.desktop.screenshot.capture.homeManager = {
    config,
    pkgs,
    ...
  }: let
    inherit (config.lib.stylix) colors;
    screenshot-annotate = pkgs.writeShellScriptBin "screenshot-annotate" ''
      state=$HOME/.local/state/screenshot/last-region
      mkdir -p ~/Pictures/Screenshots "$(dirname "$state")"
      # previous region is offered as a clickable predefined box; drag to pick a new one
      region=$({ [ -f "$state" ] && echo "$(cat "$state") last"; } |
        slurp -d -b '#00000066' -B '#${colors.base0A}33' -c '#${colors.base0D}ff' -s '#${colors.base0D}22') || exit 0
      echo "$region" > "$state"
      grim -g "$region" - | satty -f -
    '';
    screenshot-fullscreen = pkgs.writeShellScriptBin "screenshot-fullscreen" ''
      mkdir -p ~/Pictures/Screenshots
      grim -o "$(niri msg --json focused-output | jq -r .name)" - | satty -f -
    '';
  in {
    home.packages = with pkgs; [
      grim
      slurp
      jq
      screenshot-annotate
      screenshot-fullscreen
    ];
  };
}
