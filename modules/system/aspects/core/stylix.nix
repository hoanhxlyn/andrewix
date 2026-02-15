{
  pkgs,
  lib,
  config,
  fontFamily,
  ...
}: {
  config = lib.mkIf config.aspects.stylix.enable {
    stylix = {
      enable = true;
      autoEnable = true;
      polarity = "dark";
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
          applications = 12;
          terminal = 12;
          desktop = 10;
          popups = 10;
        };
      };
    };
  };
}
