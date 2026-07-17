{lib, ...}: let
  mkHost = import ./_lib {inherit lib;};
in {
  den.hosts."x86_64-linux" = {
    andrew-laptop = mkHost {
      terminal.name = "rio";
      isLaptop = true;
      monitors."eDP-1" = {
        resolution = {
          width = 2880;
          height = 1800;
        };
        refresh-rate = 90.0;
        is-primary = true;
        scale = 1.85;
      };
      monitors."HDMI-A-1" = {
        resolution = {
          width = 1920;
          height = 1080;
        };
        refresh-rate = 100.0;
        is-primary = false;
        scale = 1;
        focus-at-startup = true;
      };
    };
    andrew-pc = mkHost {
      monitors."HDMI-A-1" = {
        resolution = {
          width = 1920;
          height = 1080;
        };
        refresh-rate = 74.973;
        is-primary = true;
        scale = 1;
      };
      monitors."HDMI-A-2" = {
        resolution = {
          width = 1920;
          height = 1080;
        };
        refresh-rate = 74.973;
        is-primary = false;
        scale = 1;
      };
    };
    andrew-home-wsl = mkHost {
      is-workstation = false;
      windowsName = "hoanganh";
    };
    andrew-work-wsl = mkHost {
      is-workstation = false;
      windowsName = "andrew.nguyen1";
    };
  };
}
