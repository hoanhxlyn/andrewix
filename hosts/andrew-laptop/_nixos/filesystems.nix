{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/42961c1a-eb94-4384-945a-1b5bb54d6f14";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/99E9-7D91";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/036fbd89-d74d-4782-ab66-b58f64a6b169";}
  ];
}
