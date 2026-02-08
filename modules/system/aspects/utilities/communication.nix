{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.aspects.utilities.enable {
    environment.systemPackages = with pkgs; [
      caprine
      gnomeExtensions.kimpanel
    ];
  };
}
