{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a314a0b5-2cca-4fae-8b47-ce14f2f9a4fd";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/E2C0-5C9B";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/2bb13172-d6ac-47aa-a06b-6c797f1e0912";}
  ];
}
