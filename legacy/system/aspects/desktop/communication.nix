{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.aspects.desktop.enable {
    environment.systemPackages = with pkgs; [
      caprine
      gnomeExtensions.kimpanel
    ];
  };
}
