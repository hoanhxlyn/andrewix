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
        gc = {
          automatic = true;
          dates = "daily";
          options = "--delete-older-than 7d";
        };

        settings = {
          auto-optimise-store = true;
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
