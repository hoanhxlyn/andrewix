# Stylix theming configuration
# Provides system-wide theming using base16 color schemes
# Automatically themes terminal, desktop, and applications
{
  pkgs,
  lib,
  config,
  fontFamily,
  ...
}: let
  terminal_aspects = config.aspects.terminal;
in {
  stylix = {
    enable = lib.mkDefault config.aspects.stylix.enable;
    autoEnable = true;
    polarity = "dark";
    opacity.terminal = terminal_aspects.opacity;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 20;
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
        applications = terminal_aspects.fontSize;
        terminal = terminal_aspects.fontSize;
        desktop = lib.add terminal_aspects.fontSize 2;
        popups = lib.add terminal_aspects.fontSize 2;
      };
    };
  };
}
