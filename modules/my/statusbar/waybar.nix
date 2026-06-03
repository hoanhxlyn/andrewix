{
  den.aspects.my.statusbar.waybar = {
    homeManager = {pkgs, host, ...}:
    let
      withSeps = mods:
        let present = builtins.filter (m: m != null) mods;
        in builtins.tail (builtins.concatMap (m: ["custom/sep" m]) present);
    in {
      home.packages = with pkgs; [gsimplecal playerctl];
      programs.waybar = {
        enable = true;
        settings = {
          mainBar = {
            layer = "top";
            position = "top";
            spacing = 4;

            modules-left = ["custom/nixos" "tray" "mpris" "custom/sep" "niri/workspaces"];
            modules-center = ["clock"];
            modules-right = withSeps [
              "network"
              "wireplumber"
              (if host.isLaptop then "battery" else null)
              (if host.isLaptop then "backlight" else null)
            ];

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
              format = "{dynamic} {player_icon}";
              format-paused = " {dynamic}";
              player-icons = {
                default = "󰝚 ";
                spotify = "󰓇 ";
                firefox = "󰈹 ";
                chromium = " ";
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
              format = "{:%A %m/%d/%y %H:%M}";
              tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
              on-click = "gsimplecal";
            };

            network = {
              format-wifi = "{icon} {essid}";
              format-ethernet = "󰈀 {ifname}";
              format-disconnected = "󰤭  Disconnected";
              tooltip-format = "{ifname} via {gwaddr}";
              format-icon = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
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
              format-icons = ["󰃚" "󰃛" "󰃜" "󰃝" "󰃞" "󰃟" "󰃠"];
              on-click = "brightnessctl set 0%";
              on-scroll-up = "brightnessctl set +5%";
              on-scroll-down = "brightnessctl set 5%-";
            };

            tray.spacing = 8;
          };
        };
      };

      programs.waybar.style = ''
        #workspaces {
          background: transparent;
          border: none;
          padding: 0 4px;
        }

        .modules-left #workspaces button {
          font-size: 0;
          min-width: 13px;
          padding: 0;
          margin: 0 2px;
          border: none;
          background-color: transparent;
          background-image: radial-gradient(circle at 50% 50%, @base03 3px, transparent 3px);
          box-shadow: none;
        }

        .modules-left #workspaces button.active,
        .modules-left #workspaces button.focused {
          background-image: radial-gradient(circle at 50% 50%, @base0D 3px, transparent 3px);
          border-bottom: none;
        }

        .modules-left #workspaces button:hover {
          background-image: radial-gradient(circle at 50% 50%, @base04 3px, transparent 3px);
        }
      '';

      stylix.targets.waybar.enable = true;
    };
  };
}
