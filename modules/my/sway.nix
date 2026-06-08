{
  den.aspects.my.sway = {
    nixos.security.pam.services.swaylock = {};
    homeManager = {
      pkgs,
      config,
      lib,
      ...
    }: let
      blurScript = pkgs.writeShellScript "swaylock-blur" ''
        ${pkgs.swaylock}/bin/swaylock -f
      '';
      lockCmd = "${blurScript}";
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
      }: {
        timeout = timeout * unitToSeconds unit;
        inherit command;
      });
    in {
      home.packages = with pkgs; [swaybg imagemagick];
      programs.swaylock.enable = true;
      programs.swaylock.settings.image = lib.mkForce "/tmp/swaylock-blurred.png";
      services.swayidle = {
        enable = true;
        events.before-sleep = lockCmd;
        timeouts = mkTimeout [
          {
            unit = "minutes";
            timeout = 3;
            command = lockCmd;
          }
          {
            unit = "hours";
            timeout = 1;
            command = "systemctl suspend";
          }
        ];
      };
      systemd.user.services.swaybg = {
        Unit = {
          Description = "Wallpaper daemon";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
        };
        Service = {
          ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${config.stylix.image}";
          Restart = "on-failure";
        };
        Install.WantedBy = ["graphical-session.target"];
      };
      systemd.user.services.swaylock-blur = {
        Unit = {
          Description = "Blur stylix image for swaylock";
          After = ["graphical-session.target"];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.imagemagick}/bin/magick ${config.stylix.image} -blur 0x10 /tmp/swaylock-blurred.png";
        };
        Install.WantedBy = ["graphical-session.target"];
      };
    };
  };
}
