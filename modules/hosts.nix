_: let
  arch = "x86_64-linux";
  terminal = {
    fontSize = 12;
    padding = 2;
    opacity = 0.8;
    name = "alacritty";
  };
  gdrive-path = "/mnt/gdrive";
  gen_monitors = monitors: let
    rightOffset =
      builtins.foldl'
      (acc: name: let
        m = monitors.${name};
        s = m.scale or 1;
      in
        if !(m.is-primary or false)
        then acc + (m.resolution.width / s)
        else acc)
      0
      (builtins.attrNames monitors);
  in
    builtins.mapAttrs (_: m: {
      mode = {
        inherit (m.resolution) width height;
        refresh = m.refresh-rate;
      };
      scale = m.scale or 1;
      position = {
        x =
          if (m.is-primary or false)
          then rightOffset
          else 0;
        y = 0;
      };
    })
    monitors;
in {
  den.hosts.${arch} = {
    andrew-laptop = {
      inherit terminal;
      inherit gdrive-path;
      isLaptop = true;
      users.andrew = {};
      monitors = gen_monitors {
        "eDP-1" = {
          resolution = {
            width = 2880;
            height = 1800;
          };
          refresh-rate = 90.0;
          is-primary = false;
          scale = 2;
        };
        "HDMI-A-1" = {
          resolution = {
            width = 1920;
            height = 1080;
          };
          refresh-rate = 100.0;
          is-primary = true;
          scale = 1;
        };
      };
    };
    andrew-pc = {
      inherit terminal;
      inherit gdrive-path;
      isLaptop = false;
      monitors = gen_monitors {
        "HDMI-A-1" = {
          resolution = {
            width = 1920;
            height = 1080;
          };
          refresh-rate = 74.973;
          is-primary = false;
          scale = 1;
        };
        "HDMI-A-2" = {
          resolution = {
            width = 1920;
            height = 1080;
          };
          refresh-rate = 74.973;
          is-primary = true;
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
