{
  den.aspects.my.statusbar.waybar = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [gsimplecal playerctl];
      programs.waybar = {
        enable = true;
        settings = {
          mainBar = {
            layer = "top";
            position = "top";
            spacing = 4;

            modules-left = ["custom/nixos" "tray" "mpris"];
            modules-center = ["niri/workspaces"];
            modules-right = ["clock" "custom/sep" "network" "custom/sep" "wireplumber" "custom/sep" "battery" "custom/sep" "backlight"];

            "niri/workspaces" = {
              all-outputs = false;
              format = "";
              on-click = "activate";
            };

            "custom/sep".format = "▌";

            "custom/nixos" = {
              format = " ";
              tooltip = false;
            };

            mpris = {
              format = "{player_icon} {dynamic}";
              format-paused = " {dynamic}";
              player-icons = {
                default = "";
                spotify = "";
                firefox = "";
                chromium = "";
              };
              dynamic-len = 30;
              dynamic-order = ["title" "artist"];
              on-click = "playerctl play-pause";
            };

            wireplumber = {
              format = "{icon} {volume}%";
              format-muted = " Muted";
              format-icons = ["" "" ""];
              on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
              on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
              on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
            };

            clock = {
              format = "{:%a %d %b  %H:%M}";
              tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
              on-click = "gsimplecal";
            };

            network = {
              format-wifi = "{icon} {essid}";
              format-ethernet = "󰈀 {ifname}";
              format-disconnected = "󰤭  Disconnected";
              tooltip-format = "{ifname} via {gwaddr}";
              format-icon = ["󰤯 " "󰤟 " "󰤢 " "󰤥 " "󰤨 "];
            };

            battery = {
              states = {
                warning = 40;
                critical = 15;
              };
              format = "{icon} {capacity}%";
              format-charging = " {capacity}%";
              format-icons = ["" "" "" "" ""];
            };

            backlight = {
              device = "intel_backlight";
              format = "{icon} {percent}%";
              format-icons = ["󰃚 " "󰃛 " "󰃜 " "󰃝 " "󰃞 " "󰃟 " "󰃠 "];
              on-click = "brightnessctl set 0%";
              on-scroll-up = "brightnessctl set +5%";
              on-scroll-down = "brightnessctl set 5%-";
            };

            tray.spacing = 8;
          };
        };
      };

      stylix.targets.waybar = {
        enable = true;
        enableLeftBackColors = false;
        enableRightBackColors = false;
        enableCenterBackColors = true;
      };
    };
  };
}
