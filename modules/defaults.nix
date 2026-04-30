{
  __findFile,
  lib,
  den,
  ...
}: {
  den = {
    default = {
      includes = [
        <den/define-user>
        <den/primary-user>
        <den/hostname>
        <den/define-user>
        (<den/user-shell> "fish")
        <den/mutual-provider>
        den._.self'
        den._.inputs'
      ];
      homeManager = {
        home.stateVersion = "26.05";
      };
      nixos = {
        system.stateVersion = "26.05";
        home-manager.backupFileExtension = "bak";
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
    schema.user.classes = lib.mkDefault ["homeManager"];
  };
  perSystem = {pkgs, ...}: {
    packages = den.lib.nh.denPackages {fromFlake = true;} pkgs;
  };
}
