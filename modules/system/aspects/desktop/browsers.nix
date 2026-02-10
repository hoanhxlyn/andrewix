{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.aspects.desktop.enable {
    environment.systemPackages = with pkgs; [
      brave
    ];
    programs.firefox.enable = true;
  };
}
