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
      # TODO: Fill after install from `lspci -D -d ::03xx` (format is
      # "PCI:<bus>@<domain>:<dev>:<func>" in decimal, e.g. 0000:01:00.0 ->
      # "PCI:1@0:0:0"). Offload stays off until then.
      nvidiaPrime = null;
      storage = {
        layout = "dual";
        swap = "24G";
      };
      enableGaming = true;
      monitors."eDP-1" = {
        resolution = {
          width = 1920;
          height = 1080;
        };
        refresh-rate = 144.0;
        is-primary = true;
        scale = 1;
      };
      monitors."HDMI-A-1" = {
        resolution = {
          width = 1920;
          height = 1080;
        };
        refresh-rate = 60.0; # TODO: verify the panel/port's real rate after install
        is-primary = false;
        scale = 1;
      };
      # Panel drops to 75/60 Hz with the TLP profile (see fuzzel's power menu).
      refreshThrottle."eDP-1" = {
        balanced = 75;
        power-saver = 60;
      };
    };
    home-pc = mkHost {
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
