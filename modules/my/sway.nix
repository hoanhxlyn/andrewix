{lib, ...}: {
  den.aspects.my.sway = hostConf: let
    isLaptop = hostConf.host.isLaptop or false;
  in {
    nixos.security.pam.services.swaylock = {};
    homeManager = {pkgs, ...}: let
      lockCmd = "swaylock -f --grace 5 --fade-in 0.5 --clock";
      unitToSeconds = unit:
        if unit == "second" || unit == "seconds"
        then 1
        else if unit == "minute" || unit == "minutes"
        then 60
        else if unit == "hour" || unit == "hours"
        then 3600
        else 1;
      mkTimeout = map ({
        unit ? "minute",
        timeout,
        command,
        resumeCommand ? null,
      }:
        {
          timeout = timeout * unitToSeconds unit;
          inherit command;
        }
        // (
          if resumeCommand != null
          then {inherit resumeCommand;}
          else {}
        ));
    in {
      home.packages = with pkgs; [swaybg imagemagick brightnessctl wayland-pipewire-idle-inhibit niri];
      programs.swaylock = {
        enable = true;
        package = pkgs.swaylock-effects;
      };
      services.swayidle = {
        enable = true;
        events.before-sleep = lockCmd;
        timeouts = mkTimeout (
          lib.optionals isLaptop [
            {
              unit = "minutes";
              timeout = 1;
              command = "${pkgs.brightnessctl}/bin/brightnessctl get > /tmp/swayidle-brightness && ${pkgs.brightnessctl}/bin/brightnessctl set 10%";
              resumeCommand = "${pkgs.brightnessctl}/bin/brightnessctl set $(cat /tmp/swayidle-brightness)";
            }
          ]
          ++ [
            {
              unit = "minutes";
              timeout = 3; # TODO [Experimental] change this
              command = lockCmd;
            }
            {
              unit = "minutes";
              timeout = 5; # TODO [Experimental] change this
              command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
              resumeCommand = "${pkgs.niri}/bin/niri msg action power-on-monitors";
            }
            {
              unit = "hours";
              timeout = 1;
              command = "systemctl suspend";
            }
          ]
        );
      };
      systemd.user.services.wayland-pipewire-idle-inhibit = {
        Unit = {
          Description = "Inhibit Wayland idle when media plays through PipeWire";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target" "pipewire.service"];
          Wants = ["pipewire.service"];
        };
        Service = {
          ExecStart = "${pkgs.wayland-pipewire-idle-inhibit}/bin/wayland-pipewire-idle-inhibit --media-minimum-duration 5 --verbosity WARN";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = ["graphical-session.target"];
        };
      };
    };
  };
}
