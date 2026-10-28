{
  core.gui = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.caprine];
      programs.dbeaver.enable = true;
      programs.vesktop.enable = true;
      programs.vesktop.settings = {
        autoUpdate = false;
        "minimizeToTray" = true;
        "arRPC" = true;
        "autoStartMinimized" = true;
        "hardwareVideoAcceleration" = true;
        "clickTrayToShowHide" = true;
        "enableTaskbarFlashing" = true;
      };
    };
  };
}
