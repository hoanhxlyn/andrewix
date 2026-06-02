{
  den.aspects.my.statusbar.waybar = {
    homeManager = {
      programs.waybar = {
        enable = true;
        settings = {
          mainBar = {
            layer = "top";
            position = "top";
            # height = 32;
            spacing = 4;

            modules-left = ["tray"];
            modules-center = ["niri/workspaces"];
            modules-right = ["clock" "network" "pulseaudio" "battery" "backlight"];

            "niri/workspaces" = {
              all-outputs = false;
              format = "";
              on-click = "activate";
            };

            "custom/sep".format = "│";

            clock = {
              format = "{:%a %d %b  %H:%M}";
              tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            };

            pulseaudio = {
              format = "{icon} {volume}%";
              format-muted = "  Muted";
              format-icons = ["" "" ""];
              on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            };

            network = {
              format-wifi = "  {essid}";
              format-ethernet = " {ifname}";
              format-disconnected = "  Disconnected";
              tooltip-format = "{ifname} via {gwaddr}";
            };

            battery = {
              states = {
                warning = 40;
                critical = 15;
              };
              format = "{icon} {capacity}%";
              format-charging = "  {capacity}%";
              format-icons = ["" "" "" "" ""];
            };

            backlight = {
              device = "intel_backlight";
              format = "󰖨  {percent}%";
              on-scroll-up = "brightnessctl set +5%";
              on-scroll-down = "brightnessctl set 5%-";
            };

            tray.spacing = 8;
          };
        };
      };
      programs.waybar.style = ''
        #workspaces button {
          min-width: 8px;
          min-height: 8px;
          max-width: 8px;
          max-height: 8px;
          padding: 0;
          margin: 0 3px;
          border-radius: 50%;
          border: none;
        }

        #workspaces button.active {
          min-width: 10px;
          min-height: 10px;
          max-width: 10px;
          max-height: 10px;
        }
      '';

      stylix.targets.waybar = {
        enable = true;
        enableLeftBackColors = true;
        enableRightBackColors = true;
        enableCenterBackColors = true;
      };
    };
  };
}
