{
  den.aspects.my.sway = {
    nixos = {...}: {
      security.pam.services.swaylock-plugin = {};
    };

    homeManager = {pkgs, ...}: let
      blurScript = pkgs.writeShellScript "swaylock-blur" ''
        tmpfile=$(mktemp /tmp/swaylock-XXXXXX.png)
        trap "rm -f $tmpfile" EXIT
        ${pkgs.grim}/bin/grim "$tmpfile"
        ${pkgs.imagemagick}/bin/convert "$tmpfile" -blur 0x10 "$tmpfile"
        ${pkgs.swaybg}/bin/swaybg -m fill -i "$tmpfile"
      '';
      lockCmd = "${pkgs.swaylock-plugin}/bin/swaylock-plugin -f --command-each '${blurScript}'";
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
