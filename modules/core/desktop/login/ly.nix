{
  core.desktop.login.ly = {host, ...}: {
    nixos = {lib, ...}:
      lib.mkIf (host.login == "ly") {
        services.displayManager.ly = {
          enable = true;
          settings = {
            animation = "matrix";
            bigclock = "en";
          };
        };
      };
  };
}
