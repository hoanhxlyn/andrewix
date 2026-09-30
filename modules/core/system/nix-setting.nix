let
  stateVersion = "26.05";
  backupFileExtension = "bak";
in {
  core.nix-setting = {host, ...}: let
    isLaptop = host.isLaptop or false;
  in {
    homeManager.home.stateVersion = stateVersion;
    nixos = {
      system.stateVersion = stateVersion;
      home-manager.backupFileExtension = backupFileExtension;
      # Disable nixos manual
      documentation.nixos.enable = false;
      nix = {
        gc = {
          automatic = true;
          dates = "daily";
          options = "--delete-older-than 7d";
        };

        settings =
          {
            auto-optimise-store = true;
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            trusted-users = [
              "root"
              "@wheel"
            ];
          }
          // (
            if isLaptop
            then {
              max-jobs = 4;
              cores = 2;
              http-connections = 12;
              max-substitution-jobs = 8;
            }
            else {}
          );
      };
    };
  };
}
