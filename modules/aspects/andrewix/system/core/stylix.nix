{
  den,
  pkgs,
  lib,
  config,
  ...
}: {
  andrewix.system.core.stylix = den.lib.parametric ({
    fontFamily ? "CaskaydiaCove Nerd Font",
    colorScheme ? "catppuccin-mocha",
    cursorPackage ? pkgs.bibata-cursors,
    cursorName ? "Bibata-Modern-Ice",
    cursorSize ? 20,
    ...
  }: {
    config = {
      stylix = {
        enable = lib.mkDefault true;
        autoEnable = true;
        polarity = "dark";
        opacity.terminal = config.aspects.terminal.opacity or 0.8;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/${colorScheme}.yaml";
        cursor = {
          package = cursorPackage;
          name = cursorName;
          size = cursorSize;
        };

        fonts = {
          monospace = {
            package = pkgs.nerd-fonts.caskaydia-cove;
            name = fontFamily;
          };
          sansSerif = {
            package = pkgs.inter;
            name = "Inter";
          };
          serif = {
            package = pkgs.inter;
            name = "Inter";
          };
          emoji = {
            package = pkgs.noto-fonts-color-emoji;
            name = "Noto Color Emoji";
          };
          sizes = {
            applications = config.aspects.terminal.fontSize or 10;
            terminal = config.aspects.terminal.fontSize or 10;
            desktop = lib.add (config.aspects.terminal.fontSize or 10) 2;
            popups = lib.add (config.aspects.terminal.fontSize or 10) 2;
          };
        };
      };
    };
  });
}
