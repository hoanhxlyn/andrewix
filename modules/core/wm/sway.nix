{
  core.wm.sway = {host, ...}: let
    isLaptop = host.isLaptop or false;
  in {
    nixos.security.pam.services.swaylock = {};
    homeManager = {
      pkgs,
      lib,
      config,
      ...
    }: let
      blurredBackground = import ../../_lib/blurred-image.nix {
        inherit pkgs;
        image = config.stylix.image;
      };
      lockCmd = "${pkgs.swaylock-effects}/bin/swaylock -f";
      display = status:
        if status == "off"
        then "${pkgs.niri}/bin/niri msg action power-off-monitors"
        else ":";
      cat = "${pkgs.coreutils}/bin/cat";
      restoreBrightness = "test -f $XDG_RUNTIME_DIR/swayidle-brightness && ${pkgs.brightnessctl}/bin/brightnessctl set $(${cat} $XDG_RUNTIME_DIR/swayidle-brightness) || true";
      unitToSeconds = unit:
        if unit == "second" || unit == "seconds"
        then 1
        else if unit == "minute" || unit == "minutes"
        then 60
        else if unit == "hour" || unit == "hours"
        then 3600
        else 1;
      mkTimeout = map (
        {
          unit ? "minute",
          timeout,
          command,
          resumeCommand ? "",
        }: {
          timeout = timeout * unitToSeconds unit;
          inherit command;
          inherit resumeCommand;
        }
      );
    in {
      home.packages = with pkgs; [swaybg brightnessctl];
      programs.swaylock = {
        enable = true;
        package = pkgs.swaylock-effects;
        settings = {
          indicator-idle-visible = true;
          show-failed-attempts = false;
          image = lib.mkForce "${blurredBackground}";
          fade-in = 0.5;
          clock = true;
          grace = 10;
        };
      };
      services.swayidle = {
        enable = true;
        events = {
          before-sleep = lockCmd;
          after-resume = "${display "on"}; ${restoreBrightness}";
        };
        timeouts = mkTimeout (
          lib.optionals isLaptop [
            {
              unit = "seconds";
              timeout = 50;
              command = "${pkgs.brightnessctl}/bin/brightnessctl get > $XDG_RUNTIME_DIR/swayidle-brightness && ${pkgs.brightnessctl}/bin/brightnessctl set 10%";
              resumeCommand = "${pkgs.brightnessctl}/bin/brightnessctl set $(${cat} $XDG_RUNTIME_DIR/swayidle-brightness)";
            }
          ]
          ++ [
            {
              unit = "minutes";
              timeout = 3;
              command = lockCmd;
            }
            {
              unit = "minutes";
              timeout = 10;
              command = display "off";
              resumeCommand = display "on";
            }
            {
              unit = "hours";
              timeout = 1;
              command = "${pkgs.systemd}/bin/systemctl suspend --ignore-inhibitors";
            }
          ]
        );
      };
    };
  };
}
