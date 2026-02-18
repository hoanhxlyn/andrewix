{
  stateVersion,
  username,
  pkgs,
  ...
}: {
  imports = [
    ./aspects
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
