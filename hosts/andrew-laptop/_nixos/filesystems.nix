{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/f3a6f458-c000-4b08-9516-f61200cb5d40";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/9F54-403C";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/0a1a6498-4acf-4f37-849d-6786d13a5306";}
  ];
}
