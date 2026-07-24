{inputs, ...}: {
  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  core.disko.nixos = {
    imports = [
      inputs.disko.nixosModules.default
    ];

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
                  # ponytail: 8G swapfile; bump >= RAM only if you want hibernate
                  swap.swapfile.size = "8G";
                };
              };
            };
          };
        };
      };
    };
  };
}
