{inputs, ...}: {
  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  core.hardware.disko.nixos = {
    host,
    lib,
    user,
    ...
  }: let
    ESP = {
      priority = 1;
      size = "512M";
      type = "EF00";
      content = {
        type = "filesystem";
        format = "vfat";
        mountpoint = "/boot";
        mountOptions = ["umask=0077"];
      };
    };
    swap = size: {
      priority = 2;
      inherit size;
      content = {
        type = "swap";
        resumeDevice = true; # hibernate; disko sets boot.resumeDevice for us
      };
    };
    btrfsOptions = ["compress=zstd" "noatime"];
    root = {
      format,
      mountpoint,
      mountOptions ? ["defaults"],
    }: {
      priority = 3;
      size = "100%";
      content = {
        type = "filesystem";
        inherit format mountpoint mountOptions;
        extraArgs = ["-f"];
      };
    };
    systemDisk = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          inherit ESP;
          swap = swap host.storage.swap;
          root = root {
            format = "xfs";
            mountpoint = "/";
          };
        };
      };
    };
    dataDisk = {
      format,
      mountpoint,
      mountOptions ? ["defaults"],
    }: {
      type = "disk";
      device = "/dev/nvme0n1"; # placeholder, overwritten by install.fish's generated config
      content = {
        type = "gpt";
        partitions.root = root {inherit format mountpoint mountOptions;};
      };
    };
    # One btrfs disk split into /works and /entertainment subvolumes.
    subvolumeDisk = {
      type = "disk";
      device = "/dev/sda"; # placeholder, overwritten by install.fish
      content = {
        type = "gpt";
        partitions.data = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = ["-f"];
            subvolumes = {
              works = {
                mountpoint = "/works";
                mountOptions = btrfsOptions;
              };
              entertainment = {
                mountpoint = "/entertainment";
                mountOptions = btrfsOptions;
              };
            };
          };
        };
      };
    };
    # Disk names are baked into partlabels (disk-<name>-<part>); don't rename on installed hosts.
    layouts = {
      single = {
        main = systemDisk;
      };
      dual = {
        main = systemDisk;
        data = subvolumeDisk;
      };
      multi = {
        nixos = systemDisk;
        works = dataDisk {
          format = "btrfs";
          mountpoint = "/works";
          mountOptions = btrfsOptions;
        };
        entertainment = dataDisk {
          format = "xfs";
          mountpoint = "/entertainment";
        };
      };
    };
    # Prompt order install.fish uses per role.
    diskOrders = {
      single = ["main"];
      dual = ["main" "data"];
      multi = ["nixos" "works" "entertainment"];
    };
  in {
    imports = [
      inputs.disko.nixosModules.default
    ];

    # Prompt order install.fish uses per role; [] falls back to attrNames.
    options.core.hardware.disko.diskOrder = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };

    config = {
      core.hardware.disko.diskOrder = diskOrders.${host.storage.layout};

      disko.enableConfig = true;
      virtualisation.vmVariant = {
        boot.resumeDevice = lib.mkForce "";
        users.users.${user.userName}.initialPassword = "admin123";
        virtualisation.qemu.options = [
          "-vga"
          "none"
          "-device"
          "virtio-gpu-gl-pci"
          "-display"
          "sdl,gl=on"
        ];
      };

      disko.devices.disk = layouts.${host.storage.layout};
    };
  };
}
