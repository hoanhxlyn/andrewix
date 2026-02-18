{
  den,
  lib,
  ...
}: {
  andrewix.system.terminal = den.lib.parametric ({
    whichOne ? "wezterm",
    opacity ? 0.8,
    fontSize ? 10,
    padding ? 2,
    ...
  }: {
    options.aspects.terminal = with lib; {
      whichOne = mkOption {
        type = types.enum ["wezterm" "alacritty"];
        default = whichOne;
        description = "Choose which terminal emulator to enable (only one at a time).";
      };
      opacity = mkOption {
        type = types.float;
        default = opacity;
        description = "Terminal window opacity";
      };
      fontSize = mkOption {
        type = types.int;
        default = fontSize;
        description = "Terminal font size";
      };
      padding = mkOption {
        type = types.int;
        default = padding;
        description = "Terminal window padding";
      };
    };
  });
}
