{
  __findFile,
  lib,
  ...
}: let
  # Relative import on purpose: `self` is not resolvable while den builds the
  # flake outputs (see the same note in modules/schema.nix).
  mkHost = import ./_lib/mk-host.nix {inherit lib;};
  hosts = {
    asus-vivo14 = mkHost {
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
    asus-rog-gl552vx = mkHost {
      formFactor = "laptop";
      # Headless homelab server (see modules/devices/server.nix): no desktop and
      # no GPU offload, the dGPU is unused. Facts only, the variant comes from
      # is-server.
      is-server = true;
      # On AC permanently as a server; cap the charge so the battery is not held
      # at 100%. See core.hardware.power-manager.
      chargeThreshold = {
        start = 40;
        stop = 85;
      };
    };
    msi-gf63 = mkHost {
      formFactor = "laptop";
      gpu = ["intel" "nvidia"];
      # From `lspci -D -d ::03xx` on the GF63: Intel CometLake-H 0000:00:02.0,
      # NVIDIA GTX 1650 Mobile 0000:02:00.0.
      nvidiaPrime = {
        intelBusId = "PCI:0@0:2:0";
        nvidiaBusId = "PCI:2@0:0:0";
      };
      storage = {
        layout = "dual";
        swap = "24G";
      };
      enableGaming = true;
      # The GF63 Thin 10SC (16R5EMS1) is missing from the in-tree msi-ec
      # allowlist, so use the out-of-tree driver; see core.hardware.power-manager.
      # MSI only honours 60 / 80 / 100 %.
      chargeThreshold = {
        start = 70;
        stop = 80;
        msiEc = true;
      };
      monitors."eDP-1" = {
        resolution = {
          width = 1920;
          height = 1080;
        };
        refresh-rate = 144.0;
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
      # Panel only advertises 144.000 and 60.002 Hz; niri matches the refresh
      # exactly (round(hz*1000)), so both throttled profiles use the 60 Hz mode.
      refreshThrottle."eDP-1" = {
        balanced = 60.002;
        power-saver = 60.002;
      };
    };
    home-pc = mkHost {
      cpu = "amd";
      gpu = ["nvidia"];
      bootLoader = "limine";
      defaults.terminal = "rio";
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
    home-wsl = mkHost {
      is-workstation = false;
      windowsName = "hoanganh";
    };
    work-wsl = mkHost {
      is-workstation = false;
      windowsName = "andrew.nguyen1";
    };
  };
in {
  den.hosts."x86_64-linux" = hosts;

  # Read by install.fish: every host that has a disk layout (all but WSL).
  flake.installableHosts =
    lib.attrNames (lib.filterAttrs (_: h: !(h.wsl.enable or false)) hosts);

  # Variant (workstation | server | wsl) comes from the host flags, not the hostname.
  den.aspects =
    lib.mapAttrs (_: h: {
      provides.to-users.includes = [
        (
          if h.wsl.enable or false
          then <wsl>
          else if h.server.enable or false
          then <server>
          else <workstation>
        )
      ];
    })
    hosts;
}
