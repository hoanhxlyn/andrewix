{inputs, ...}: {
  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  core.disko.nixos = {host, ...}: {
    imports = [
      inputs.disko.nixosModules.default
    ];

    # false: disko provides the format/install scripts but does NOT own the
    # running system's fileSystems — so the live ext4 hosts keep booting via
    # their by-uuid hardware-configuration.nix and `just switch` stays safe.
    # At a real btrfs reinstall, flip to true AND drop the by-uuid fileSystems
    # from hosts/<host>/_nixos/hardware-configuration.nix so disko owns fstab.
    disko.enableConfig = false;

    # Shared layout for both physical hosts. Device is a placeholder — pick the
    # real disk at install time: disko-install --disk main /dev/nvme0n1
    disko.devices.disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            name = "ESP";
            start = "1M";
            end = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["umask=0077"];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = ["-f"];
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "@swap" = {
                  mountpoint = "/.swapvol";
                  swap.swapfile.size = "${toString host.ramGB}G";
                };
              };
            };
          };
        };
      };
    };
  };
}
