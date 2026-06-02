_: let
  arch = "x86_64-linux";
  terminal = {
    fontSize = 12;
    padding = 2;
    opacity = 0.8;
    name = "alacritty";
  };
  gdrive-path = "/mnt/gdrive";
in {
  den.hosts.${arch} = {
    andrew-laptop = {
      inherit terminal;
      inherit gdrive-path;
      users.andrew = {};
      monitors = {
        "eDP-1" = {
          resolution = "2880x1800";
          refresh-rate = 90.0;
          primary = false;
          scale = 2;
        };
        "HDMI-A-1" = {
          resolution = "1920x1080";
          refresh-rate = 100.0;
          primary = true;
          scale = 1;
        };
      };
    };
    andrew-pc = {
      inherit terminal;
      inherit gdrive-path;
      monitors = {
        "HDMI-A-1" = {
          resolution = "1920x1080";
          refresh-rate = 74.973;
          primary = false;
          scale = 1;
        };
        "HDMI-A-2" = {
          resolution = "1920x1080";
          refresh-rate = 74.973;
          primary = true;
          scale = 1;
        };
      };
      users.andrew = {};
    };
    andrew-home-wsl = {
      wsl.enable = true;
      users.andrew = {};
      inherit terminal;
      windowsName = "hoanganh";
    };
    andrew-work-wsl = {
      wsl.enable = true;
      users.andrew = {};
      inherit terminal;
      windowsName = "andrew.nguyen1";
    };
  };
}
