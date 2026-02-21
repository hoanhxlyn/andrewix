{
  andrew.browsers.provides.brave = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.brave];
    };
    homeManager = {pkgs, ...}: let
      keepass = pkgs.keepassxc;
    in {
      programs = {
        brave = {
          nativeMessagingHosts = [keepass];
        };
      };
    };
  };
}
