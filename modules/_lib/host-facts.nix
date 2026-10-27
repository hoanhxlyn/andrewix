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
  chassis = mkOption {
    type = types.enum ["desktop" "laptop"];
    default = "desktop";
  };
  # Derived from chassis; read by the battery/lid/backlight bits of the UI.
  isLaptop = mkOption {
    type = types.bool;
    readOnly = true;
    default = config.chassis == "laptop";
  };
  # CPU vendor, drives kvm module and microcode in core.hardware.bootable.
  cpu = mkOption {
    type = types.enum ["intel" "amd"];
    default = "intel";
  };
  # One entry per GPU, given as a single entry or a list; always read as a list. `kind` tells an
  # iGPU from a dGPU, so Intel iGPU + Intel Arc is expressible. `busId` is the NixOS PRIME form
  # (`PCI:bus@domain:dev:fn`, decimal, from `lspci -D -d ::03xx`); only needed for hybrid offload.
  # An integrated Intel plus a discrete NVIDIA entry makes the host hybrid (see core.hardware.nvidia).
  gpu = let
    entry = types.submodule {
      options = {
        vendor = mkOption {type = types.enum ["intel" "nvidia"];};
        kind = mkOption {type = types.enum ["integrated" "discrete"];};
        busId = nullable types.str;
      };
    };
  in
    mkOption {
      # `coercedTo` rejects a submodule as its source type, so match any attrset instead.
      type = types.coercedTo types.attrs lib.singleton (types.listOf entry);
      default = [];
    };
  bootLoader = mkOption {
    type = types.enum ["systemd-boot" "grub" "limine"];
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
  # Ethernet MAC to clone, per host; null = leave the NIC's burned-in address.
  # Consumed by core.hardware.network, which adds a `work` NM profile when set.
  ethernet = mkOption {
    default = {};
    type = types.submodule {
      options = {
        clonedMac = nullable types.str;
      };
    };
  };
  # Battery charge limits in %. Laptops default to stopping at 80% (start = stop - 10, the
  # step msi-ec derives); desktops and homelab hosts have no battery, so null = unmanaged. A laptop
  # opts out with `chargeThreshold = null`.
  # `stop` is the level charging tops out at. Hosts whose EC needs the
  # out-of-tree msi-ec driver (its in-tree allowlist lacks the firmware) set
  # `msiEc = true`; the driver exposes the standard charge_control sysfs and
  # only honours 60 / 80 / 100, deriving start from stop - 10.
  chargeThreshold = mkOption {
    type = types.nullOr (types.submodule {
      options = {
        start = mkOption {
          type = types.ints.between 0 100;
          default = 70;
        };
        stop = mkOption {
          type = types.ints.between 0 100;
          default = 80;
        };
        msiEc = mkOption {
          type = types.bool;
          default = false;
        };
      };
    });
    # `{}` takes the field defaults above, so a host can set just `msiEc = true`.
    default =
      if config.chassis == "laptop"
      then {}
      else null;
  };
  # Laptop panel refresh throttling per TLP power profile, keyed by connector.
  # `performance` uses the monitor's declared refresh-rate, and so does any profile left
  # null, so list only the profiles that throttle. Empty = refresh does not follow the profile.
  refreshThrottle = mkOption {
    type = types.attrsOf (types.submodule {
      options = {
        balanced = nullable types.number;
        power-saver = nullable types.number;
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
