{
  core.desktop.login.ly = {host, ...}: {
    nixos = {lib, ...}:
      lib.mkIf (host.login == "ly") {
        services.displayManager.ly.enable = true;
        services.displayManager.ly.settings.animation = "matrix";
        services.displayManager.ly.settings.bigclock = "en";
      };
  };
}
