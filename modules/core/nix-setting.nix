let
  stateVersion = "26.05";
  backupFileExtension = "bak";
in {
  core.nix-setting = {
    homeManager.home.stateVersion = stateVersion;
    nixos = {
      system.stateVersion = stateVersion;
      home-manager.backupFileExtension = backupFileExtension;
      nix = {
        optimise.automatic = true;
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          trusted-users = [
            "root"
            "@wheel"
          ];
        };
      };
    };
  };
}
