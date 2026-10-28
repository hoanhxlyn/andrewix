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
      # nscd and nss-lookup.target / nss-user-lookup.target form a dependency
      # cycle that churns during boot; the default nscd start limit (5 per 10s)
      # turns that churn into a permanent `start-limit-hit`. Allow enough starts
      # to ride it out. See the nss targets in `journalctl -b -u nscd`.
      systemd.services.nscd.startLimitBurst = 50;
      nix.settings =
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
}
