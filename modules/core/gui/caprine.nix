{
  core.gui.caprine.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.caprine];
    systemd.user.services.caprine-autostart = {
      Unit = {
        Description = "Caprine";
        After = ["graphical-session.target"];
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.caprine}/bin/caprine";
        Restart = "on-failure";
        RestartSec = "10s";
      };
    };
  };
}
