{
  stateVersion,
  username,
  pkgs,
  ...
}:
{
  imports = [
    ./programs.nix
    ./i18n.nix
    ./fonts.nix
    ./services.nix
    ./neovim.nix
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

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "fuse" ];
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Ho_Chi_Minh";
  security.rtkit.enable = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.auto-optimise-store = true;
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = stateVersion;
}
