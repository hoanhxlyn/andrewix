{
  __findFile,
  lib,
  ...
}: let
  mkHost = import ./_lib/mk-host.nix {inherit lib;};
  hosts = {
    asus-vivo14 = mkHost {
      chassis = "laptop";
      gpu = {
        vendor = "intel";
        kind = "integrated";
      };
      monitors = {
        # panel left, external right; niri focuses the external at startup
        order = ["eDP-1" "HDMI-A-1"];
        "eDP-1" = {
          resolution = {
            width = 2880;
            height = 1800;
          };
          refresh-rate = 90.0;
          is-primary = false;
          scale = 1.85;
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
    asus-rog-gl552vx = mkHost {
      chassis = "laptop";
      is-homelab = true;
      # Intel iGPU only, enough for niri. The NVIDIA dGPU is deliberately undeclared (no driver).
      # Confirm with `lspci -D -d ::03xx` at install time.
      gpu = {
        vendor = "intel";
        kind = "integrated";
      };
    };
    msi-gf63 = mkHost {
      chassis = "laptop";
      wm = "hyprland";
      defaults.terminal = "rio";
      appearance = {
        scheme = "catppuccin-mocha"; # base16-schemes name
        wallpaper = {
          source = "catppuccin";
          path = "sushi.jpg";
        };
      };
      # From `lspci -D -d ::03xx` on the GF63: Intel CometLake-H 0000:00:02.0,
      # NVIDIA GTX 1650 Mobile 0000:02:00.0.
      gpu = [
        {
          vendor = "intel";
          kind = "integrated";
          busId = "PCI:0@0:2:0";
        }
        {
          vendor = "nvidia";
          kind = "discrete";
          busId = "PCI:2@0:0:0";
        }
      ];
      storage = {
        layout = "dual";
        swap = "24G";
      };
      enableGaming = true;
      ethernet.clonedMac = "A8:A1:59:86:D5:33";
      chargeThreshold = {
        msiEc = true;
      };
      monitors = {
        # laptop panel left, external right; niri focuses the external at startup
        order = ["eDP-1" "HDMI-A-2"];
        "eDP-1" = {
          resolution = {
            width = 1920;
            height = 1080;
          };
          refresh-rate = 144.0;
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
      refreshThrottle."eDP-1" = {
        power-saver = 60.002;
      };
    };
    home-pc = mkHost {
      defaults.terminal = "rio";
      appearance = {
        scheme = "gruvbox-material-dark-medium"; # base16-schemes name
        wallpaper = {
          source = "gruvbox";
          path = "wallpapers/brands/amdgruvorange.png";
        };
      };
      cpu = "amd";
      gpu = {
        vendor = "nvidia";
        kind = "discrete";
      };
      bootLoader = "limine";
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
      profiles.andrew.git.email = "andrew.nguyen1@techvify.com.vn";
    };
  };
in {
  den.hosts."x86_64-linux" = hosts;

  # Read by install.fish: every host that has a disk layout (all but WSL).
  flake.installableHosts =
    lib.attrNames (lib.filterAttrs (_: h: !(h.wsl.enable or false)) hosts);

  # Variant (workstation | homelab | wsl) comes from the host flags, not the hostname.
  den.aspects =
    lib.mapAttrs (_: h: {
      provides.to-users.includes = [
        (
          if h.wsl.enable or false
          then <wsl>
          else if h.homelab.enable or false
          then <homelab>
          else <workstation>
        )
      ];
    })
    hosts;
}
