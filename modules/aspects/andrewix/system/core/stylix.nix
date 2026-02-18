{
  pkgs,
  lib,
  config,
  ...
}: {
  stylix = {
    enable = lib.mkDefault true;
    autoEnable = true;
    polarity = "dark";
    opacity.terminal = config.aspects.terminal.opacity or 0.8;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 20;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.caskaydia-cove;
        name = "CaskaydiaCove Nerd Font";
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
}
