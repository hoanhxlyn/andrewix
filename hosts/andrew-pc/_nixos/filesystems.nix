{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b8589191-3b30-4cb9-bf2a-54164fff9325";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/D98A-14CA";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/e2e35b8b-aca6-42bf-9c74-7fd819efbda7";}
  ];
}
