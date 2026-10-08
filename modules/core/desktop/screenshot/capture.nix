{
  core.desktop.screenshot.capture.homeManager = {
    config,
    pkgs,
    ...
  }: let
    inherit (config.lib.stylix) colors;
    screenshot-annotate = pkgs.writeShellScriptBin "screenshot-annotate" ''
      mkdir -p ~/Pictures/Screenshots
      region=$(slurp -d -b '#00000066' -c '#${colors.base0D}ff' -s '#${colors.base0D}22') || exit 0
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
