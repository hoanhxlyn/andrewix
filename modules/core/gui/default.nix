{
  core.gui = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.caprine];
      programs.dbeaver.enable = true;
      programs.vesktop = {
        enable = true;
        settings = {
          autoUpdate = false;
          "minimizeToTray" = true;
          "arRPC" = true;
          "autoStartMinimized" = true;
          "hardwareVideoAcceleration" = true;
          "clickTrayToShowHide" = true;
          "enableTaskbarFlashing" = true;
        };
      };
      programs.satty = {
        enable = true;
      };
    };
  };
}
