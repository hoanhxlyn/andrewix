{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.aspects.utilities.enable {
    environment.systemPackages = with pkgs; [
      brave
      alacritty
    ];
    programs.firefox.enable = true;
  };
}
