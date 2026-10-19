{
  core.desktop.login.regreet = {host, ...}: {
    nixos = {lib, ...}:
      lib.mkIf (host.login == "regreet") {
        services.displayManager.regreet.enable = true;
      };
  };
}
