{
  username,
  pkgs,
  den,
  ...
}: {
  andrewix.system.core = den.lib.parametric {
    imports = [
      ./boot.nix
      ./fonts.nix
      ./i18n.nix
      ./programs.nix
      ./stylix.nix
      ./fingerprint.nix
    ];

    config = {
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
    };
  };
}
