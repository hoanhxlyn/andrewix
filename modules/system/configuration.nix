{
  stateVersion,
  username,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    (inputs.import-tree ./aspects)
  ];

  users.users.${username} = {
    isNormalUser = true;
    description = "Andrew Nguyen";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
  };
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    supportedFilesystems = ["fuse"];
    kernelPackages = pkgs.linuxPackages_latest;
  };
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Ho_Chi_Minh";
  security.rtkit.enable = true;
  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    settings.auto-optimise-store = true;
  };
  system.stateVersion = stateVersion;
}
