{
  den.aspects.my.sway = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [swaybg];
      programs.swaylock.enable = true;
      services.swayidle = {
        enable = true;
        events = [
          {
            event = "before-sleep";
            command = "swaylock -f";
          }
        ];
        timeouts = [
          {
            timeout = 300;
            command = "swaylock -f";
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
