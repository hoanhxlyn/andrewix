{
  den.aspects.my.sway = {
    nixos = {...}: {
      security.pam.services.swaylock = {};
    };

    homeManager = {pkgs, ...}: let
      blurScript = pkgs.writeShellScript "swaylock-blur" ''
        tmpfile=$(mktemp /tmp/swaylock-XXXXXX.png)
        ${pkgs.grim}/bin/grim "$tmpfile"
        ${pkgs.imagemagick}/bin/convert "$tmpfile" -blur 0x10 "$tmpfile"
        ${pkgs.swaylock}/bin/swaylock -f --image "$tmpfile"
        rm -f "$tmpfile"
      '';
      lockCmd = "${blurScript}";
    in {
      home.packages = with pkgs; [swaybg imagemagick];
      programs.swaylock.enable = true;
      services.swayidle = {
        enable = true;
        events.before-sleep = lockCmd;
        timeouts = [
          {
            timeout = 300;
            command = lockCmd;
          }
          {
            timeout = 600;
            command = "niri msg action power-off-monitors";
          }
        ];
      };
    };
  };
}
