{
  __findFile,
  lib,
  den,
  ...
}: {
  den = {
    default = {
      includes = [
        <den.batteries.define-user>
        <den.batteries.primary-user>
        <den.batteries.hostname>
        (<den.batteries.user-shell> "fish")
        <den.batteries.mutual-provider>
        den.batteries.self'
        den.batteries.inputs'
        <core.nix-setting>
      ];
    };
    schema.user.classes = lib.mkDefault ["homeManager"];
  };
  perSystem = {pkgs, ...}: {
    packages = den.lib.nh.denPackages {fromFlake = true;} pkgs;
  };
}
