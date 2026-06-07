{lib, ...}: let
  gen_host = {
    is-workstation ? true,
    users,
    isLaptop ? false,
    monitors ? {},
    windowsName ? null,
  }: let
    base = {
      terminal = {
        fontSize = 12;
        padding = 2;
        opacity = 0.8;
        name = "ghostty";
      };
      inherit users;
    };
    workstation = {
      inherit isLaptop;
      rclone.path = "/mnt/gdrive";
      monitors = let
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
    };
    wsl =
      lib.recursiveUpdate
      {wsl.enable = true;}
      (
        if windowsName != null
        then {inherit windowsName;}
        else {}
      );
  in
    lib.recursiveUpdate base (
      if is-workstation
      then workstation
      else wsl
    );
in {
  den.hosts."x86_64-linux" = {
    andrew-laptop = gen_host {
      users.andrew = {};
      isLaptop = true;
      monitors."eDP-1" = {
        resolution = {
          width = 2880;
          height = 1800;
        };
        refresh-rate = 90.0;
        is-primary = false;
        scale = 2;
      };
      monitors."HDMI-A-1" = {
        resolution = {
          width = 1920;
          height = 1080;
        };
        refresh-rate = 100.0;
        is-primary = true;
        scale = 1;
      };
    };
    andrew-pc = gen_host {
      users.andrew = {};
      monitors."HDMI-A-1" = {
        resolution = {
          width = 1920;
          height = 1080;
        };
        refresh-rate = 74.973;
        is-primary = false;
        scale = 1;
      };
      monitors."HDMI-A-2" = {
        resolution = {
          width = 1920;
          height = 1080;
        };
        refresh-rate = 74.973;
        is-primary = true;
        scale = 1;
      };
    };
    andrew-home-wsl = gen_host {
      is-workstation = false;
      users.andrew = {};
      windowsName = "hoanganh";
    };
    andrew-work-wsl = gen_host {
      is-workstation = false;
      users.andrew = {};
      windowsName = "andrew.nguyen1";
    };
  };
}
