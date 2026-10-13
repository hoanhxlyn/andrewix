{inputs, ...}: {
  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  core.hardware.disko.nixos = {host, ...}: let
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
    root = {format, mountpoint}: {
      priority = 3;
      size = "100%";
      content = {
        type = "filesystem";
        inherit format mountpoint;
        extraArgs = ["-f"];
      };
    };
    dataDisk = {format, mountpoint}: {
      type = "disk";
      device = "/dev/nvme0n1"; # placeholder, overwritten by disko-install --disk
      content = {
        type = "gpt";
        partitions.root = root {inherit format mountpoint;};
      };
    };
  in {
    imports = [
      inputs.disko.nixosModules.default
    ];

    # disko owns fileSystems / swapDevices / boot.resumeDevice. Hardware boot
    # bits (initrd vmd/nvme, kvm, microcode) live in core.hardware.bootable.
    disko.enableConfig = true;

    # `device` is a placeholder — disko-install overwrites it per disk:
    #   --disk <name> /dev/<dev>
    disko.devices.disk =
      if host.isLaptop
      then {
        main = {
          type = "disk";
          device = "/dev/nvme0n1";
          content = {
            type = "gpt";
            partitions = {
              ESP = efi;
              swap = swap "24G";
              root = root {format = "xfs"; mountpoint = "/";};
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
              swap = swap "32G";
              root = root {format = "xfs"; mountpoint = "/";};
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
}
