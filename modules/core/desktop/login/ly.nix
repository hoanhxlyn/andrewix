{
  core.desktop.login.ly = {host, ...}: {
    nixos = {
      config,
      lib,
      ...
    }: let
      inherit (config.lib.stylix.colors) base00 base05 base0B base0D;
      lyColor = style: color: "0x${style}${color}";
    in
      lib.mkIf (host.login == "ly") {
        services.displayManager.ly = {
          enable = true;
          settings = {
            animation = "matrix";
            bigclock = "en";
            bg = lyColor "00" base00;
            fg = lyColor "00" base05;
            border_fg = lyColor "00" base0D;
            cmatrix_fg = lyColor "00" base0B;
            cmatrix_head_col = lyColor "01" base05;
          };
        };
      };
  };
}
