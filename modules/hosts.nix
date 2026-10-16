{
  __findFile,
  lib,
  ...
}: let
  mkHost = import ./_lib {inherit lib;};
  hosts = {
    andrew-asus-vivo14 = mkHost {
      formFactor = "laptop";
      gpu = ["intel"];
      # asus_wmi on the X1405VA: see core.hardware.power-manager.
      chargeThreshold = {
        start = 40;
        stop = 85;
      };
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
    andrew-asus-rog-gl552vx = mkHost {
      formFactor = "laptop";
      gpu = ["intel" "nvidia"];
      # TODO: Fill after install from `lspci -nn | grep -E "VGA|3D"`, e.g. "PCI:0:2:0" / "PCI:1:0:0".
      nvidiaPrime = null;
      monitors."eDP-1" = {
        resolution = {
          width = 1920;
          height = 1080;
        };
        refresh-rate = 60.0;
        is-primary = false;
        scale = 1;
      };
      # TODO: Verify connector names after install with `niri msg outputs`; with nvidia driving,
      monitors."HDMI-A-1" = {
        resolution = {
          width = 1920;
          height = 1080;
        };
        refresh-rate = 74.973;
        is-primary = true; # TODO: change between 2
        scale = 1;
      };
      monitors."HDMI-A-2" = {
        resolution = {
          width = 1920;
          height = 1080;
        };
        refresh-rate = 74.973;
        is-primary = false; # TODO: change between 2
        scale = 1;
      };
    };
    andrew-pc = mkHost {
      gpu = ["nvidia"];
      bootLoader = "grub";
      storage = {
        layout = "multi";
        swap = "32G";
      };
      enableGaming = true;
      powerManagement = {
        profile = "performance";
        suspend = null;
        monitorOff = null;
        dim = null;
        lock = null;
      };
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
in {
  den.hosts."x86_64-linux" = hosts;

  # Read by install.fish: every host that has a disk layout (all but WSL).
  flake.installableHosts =
    lib.attrNames (lib.filterAttrs (_: h: !(h.wsl.enable or false)) hosts);

  # Variant (workstation | wsl) comes from the host facts, not the hostname.
  den.aspects =
    lib.mapAttrs (_: h: {
      provides.to-users.includes = [
        (
          if h.wsl.enable or false
          then <wsl>
          else <workstation>
        )
      ];
    })
    hosts;
}
