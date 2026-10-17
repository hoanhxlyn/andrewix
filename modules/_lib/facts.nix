# Host fact options: the single definition of what a host may declare.
# Imported by modules/schema.nix (typing/defaults via den) and by mkHost (to
# reject unknown fact names), so the two can never drift.
{
  lib,
  config,
}: let
  inherit (lib) mkOption mkEnableOption types;
  nullable = type:
    mkOption {
      type = types.nullOr type;
      default = null;
    };
in {
  formFactor = mkOption {
    type = types.enum ["desktop" "laptop"];
    default = "desktop";
  };
  # Derived from formFactor; read by the battery/lid/backlight bits of the UI.
  isLaptop = mkOption {
    type = types.bool;
    readOnly = true;
    default = config.formFactor == "laptop";
  };
  # CPU vendor, drives kvm module and microcode in core.hardware.bootable.
  cpu = mkOption {
    type = types.enum ["intel" "amd"];
    default = "intel";
  };
  gpu = mkOption {
    type = types.listOf (types.enum ["intel" "nvidia"]);
    default = [];
  };
  # Hybrid Intel+NVIDIA only; null leaves PRIME off (and warns).
  nvidiaPrime = nullable (types.submodule {
    options = {
      intelBusId = mkOption {type = types.str;};
      nvidiaBusId = mkOption {type = types.str;};
    };
  });
  bootLoader = mkOption {
    type = types.enum ["systemd-boot" "grub"];
    default = "systemd-boot";
  };
  storage = mkOption {
    default = {};
    type = types.submodule {
      options = {
        # single = one disk; multi = nixos/works/entertainment on three disks;
        # dual = root disk + one btrfs disk holding /works and /entertainment.
        layout = mkOption {
          type = types.enum ["single" "multi" "dual"];
          default = "single";
        };
        swap = mkOption {
          type = types.str;
          default = "24G";
        };
      };
    };
  };
  # Battery charge limits in %; null = unmanaged. Only used by laptops.
  # `stop` is the level charging tops out at. Hosts whose EC needs the
  # out-of-tree msi-ec driver (its in-tree allowlist lacks the firmware) set
  # `msiEc = true`; the driver exposes the standard charge_control sysfs and
  # only honours 60 / 80 / 100, deriving start from stop - 10.
  chargeThreshold = nullable (types.submodule {
    options = {
      start = mkOption {type = types.ints.between 0 100;};
      stop = mkOption {type = types.ints.between 0 100;};
      msiEc = mkOption {
        type = types.bool;
        default = false;
      };
    };
  });
  # Laptop panel refresh throttling per TLP power profile, keyed by connector.
  # `performance` uses the monitor's declared refresh-rate, so only the throttled
  # profiles are listed. Empty = refresh does not follow the profile.
  refreshThrottle = mkOption {
    type = types.attrsOf (types.submodule {
      options = {
        balanced = mkOption {type = types.number;};
        power-saver = mkOption {type = types.number;};
      };
    });
    default = {};
  };
  enableGaming = mkEnableOption "the gaming aspects";

  powerManagement = mkOption {
    default = {};
    type = types.submodule {
      options = {
        profile = mkOption {
          type = types.enum ["performance" "balanced" "power-saver"];
          default = "balanced";
        };
        dim = mkOption {
          type = types.nullOr types.ints.positive;
          default = 60;
        };
        lock = mkOption {
          type = types.nullOr types.ints.positive;
          default = 300;
        };
        monitorOff = mkOption {
          type = types.nullOr types.ints.positive;
          default = 600;
        };
        suspend = mkOption {
          type = types.nullOr types.ints.positive;
          default = 7200;
        };
      };
    };
  };
}
