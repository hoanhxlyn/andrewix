{
  core.desktop.screenshot.satty.homeManager = {config, ...}: let
    inherit (config.lib.stylix) colors;
  in {
    # TODO: Ctrl+S -> save-to-file-as (generic keybinds, Satty-org/Satty#555) once it lands in a release
    programs.satty = {
      enable = true;
      settings = {
        general = {
          copy-command = "wl-copy";
          output-filename = "~/Pictures/Screenshots/Screenshot_%Y-%m-%d_%H-%M-%S.png";
          actions-on-enter = ["save-to-file" "exit"];
          early-exit = ["copy"];
        };
        font.family = config.stylix.fonts.sansSerif.name;
        color-palette.palette = map (c: "#${colors.${c}}ff") [
          "base08"
          "base09"
          "base0A"
          "base0B"
          "base0D"
          "base0E"
        ];
      };
    };
  };
}
