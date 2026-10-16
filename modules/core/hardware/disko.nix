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
    efi = {
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
    root = {
      format,
      mountpoint,
    }: {
      priority = 3;
      size = "100%";
      content = {
        type = "filesystem";
        inherit format mountpoint;
        extraArgs = ["-f"];
      };
    };
    dataDisk = {
      format,
      mountpoint,
    }: {
      type = "disk";
      device = "/dev/nvme0n1"; # placeholder, overwritten by install.fish's generated config
      content = {
        type = "gpt";
        partitions.root = root {inherit format mountpoint;};
      };
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
      core.hardware.disko.diskOrder =
        if host.storage.layout == "single"
        then ["main"]
        else ["nixos" "works" "entertainment"];

      # disko owns fileSystems / swapDevices / boot.resumeDevice. Hardware boot
      # bits (initrd vmd/nvme, kvm, microcode) live in core.hardware.bootable.
      disko.enableConfig = true;

      # `just vm` tweaks. qemu-vm overrides fileSystems/swapDevices for the VM
      # but not boot.resumeDevice, so the host's `resume=` swap leaks in and
      # initrd waits forever for a device the VM does not have. And niri needs
      # host GL: gtk has none, so use sdl + virtio-gpu-gl (no -vga std).
      virtualisation.vmVariant = {
        boot.resumeDevice = lib.mkForce "";
        # vmVariant is applied only by `system.build.vm`, so this known password
        # never reaches a hardware config; it exists just to log into `just vm`.
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

      disko.devices.disk =
        if host.storage.layout == "single"
        then {
          main = {
            type = "disk";
            device = "/dev/nvme0n1";
            content = {
              type = "gpt";
              partitions = {
                ESP = efi;
                swap = swap host.storage.swap;
                root = root {
                  format = "xfs";
                  mountpoint = "/";
                };
              };
            };
          };
        }
        else {
          nixos = {
            type = "disk";
            device = "/dev/nvme0n1";
            content = {
              type = "gpt";
              partitions = {
                ESP = efi;
                swap = swap host.storage.swap;
                root = root {
                  format = "xfs";
                  mountpoint = "/";
                };
              };
            };
          };
          works = dataDisk {
            format = "btrfs";
            mountpoint = "/works";
          };
          entertainment = dataDisk {
            format = "xfs";
            mountpoint = "/entertainment";
          };
        };
    };
  };
}
