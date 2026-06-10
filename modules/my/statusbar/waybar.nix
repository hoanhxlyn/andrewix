{
  den.aspects.my.statusbar.waybar = {
    homeManager = {
      pkgs,
      host,
      ...
    }: let
      vpnStatusScript = pkgs.writeShellScriptBin "waybar-vpn-status" ''
        if ${pkgs.iproute2}/bin/ip link show proton0 2>/dev/null | ${pkgs.gnugrep}/bin/grep -qE ',UP,'; then
          echo '{"text":"󰖂 ","tooltip":"Proton VPN","class":"connected"}'
        else
          echo '{"text":""}'
        fi
      '';
    in {
      home.packages = with pkgs; [gsimplecal playerctl] ++ [vpnStatusScript];
      xdg.configFile."gsimplecal/config".text = ''
        mainwindow_position = mouse
        mainwindow_yoffset = 5
        mainwindow_keep_above = 1
        mainwindow_decorated = 0
        mainwindow_resizable = 0
        mainwindow_skip_taskbar = 1
        mainwindow_sticky = 1
        close_on_unfocus = 1
      '';
      stylix.targets.waybar = {
        enable = true;
        enableLeftBackColors = false;
      };

      programs.waybar = {
        enable = true;
        style =
          /*
          css
          */
          ''
            .modules-left #workspaces button {
              border-radius: 0;
            }
            .modules-left #workspaces button.active,
            .modules-left #workspaces button.focused {
              color: @base0E;
              border-radius: 0;
              border-bottom-color: @base0E;
            }

            #upower, #battery  { border-bottom: 3px solid @base0B; }
            #network { border-bottom: 3px solid @base08; }
            #wireplumber, #pulseaudio, #sndio {
               border-bottom: 3px solid @base07;
            }
            #clock { border-bottom: 3px solid @base06; }
            #backlight {border-bottom: 3px solid @base05;}
            #bluetooth {border-bottom: 3px solid @base0D;}
            #tray {border-bottom: 3px solid @base0C;}

          '';
        settings = {
          mainBar = {
            layer = "top";
            position = "top";
            spacing = 5;

            modules-left = [
              "niri/workspaces"
              "group/mpris"
            ];
            modules-center = ["niri/window"];
            modules-right = builtins.filter (m: m != null) [
              "group/tray"
              (
                if host.isLaptop
                then "network#wifi"
                else null
              )
              "privacy"
              "network#eth"
              "custom/vpn"
              "bluetooth"
              (
                if host.isLaptop
                then "battery"
                else null
              )
              (
                if host.isLaptop
                then "backlight"
                else null
              )
              "wireplumber"
              "clock"
            ];

            "niri/workspaces" = {
              all-outputs = false;
              hide-empty = true;
              on-click = "activate";
              format = "{icon}";
              format-icons = {
                "1" = "";
                "2" = "󰈹";
                "3" = "󰍡";
                "4" = "";
                "5" = "󰝰";
              };
            };

            "niri/window" = {
              max-length = 30;
              rewrite = {
                "(.*) - Mozilla Firefox" = "󰈹 $1";
                "(.*) — Zen Browser" = "󰈹 $1";
                "(.*) - Helium" = " $1";
                "(.*) - KeePassXC" = "󰌆 $1";
                "(.*) - Discord" = " $1";
                "(.*) - Obsidian.*" = " $1";
                "bunx? (.*)" = " $1";
                "pnpm (.*)" = " $1";
                "npm? (.*)" = "󰛷 $1";
                "nvim (.*)" = " [$1]";
              };
            };

            "group/mpris" = {
              orientation = "inherit";
              drawer = {
                transition-duration = 300;
                transition-left-to-right = true;
                click-to-reveal = false;
              };
              modules = ["mpris#icon" "mpris#info"];
            };

            "mpris#icon" = {
              format = "{status_icon}";
              format-paused = "{status_icon}";
              status-icons = {
                playing = "󰝚 ";
                paused = "󰏤";
                stopped = "󰓛";
              };
              on-click = "playerctl play-pause";
              tooltip = false;
            };

            "mpris#info" = {
              format = "{player_icon} {dynamic}";
              format-paused = "{player_icon} {dynamic}";
              player-icons = {
                default = "󰝚 ";
                spotify = "󰓇 ";
                firefox = "󰈹 ";
                chromium = " ";
              };
              dynamic-len = 25;
              dynamic-order = ["title" "artist"];
              tooltip = false;
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
              format = "󰥔 {:%H:%M}";
              tooltip-format = "{:%a %m/%d/%y}";
              on-click = "gsimplecal";
            };

            "network#wifi" = {
              interface = "wl*";
              format-wifi = "{icon} {essid}";
              format-disconnected = "";
              tooltip-format = "{ifname}";
              format-icon = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
            };

            "custom/vpn" = {
              exec = "${vpnStatusScript}/bin/waybar-vpn-status";
              return-type = "json";
              interval = 3;
              on-click = "protonvpn-app";
            };

            "network#eth" = {
              interface = "enp*";
              format-ethernet = "{icon} {ipaddr}";
              format-disconnected = "";
              tooltip-format = "{ifname} - {gwaddr}";
              format-icons = ["󰈀"];
            };

            bluetooth = {
              format = "󰂯 {status}";
              format-no-controller = "";
              format-connected = "󰂱 {device_alias}";
              format-connected-battery = "󰂱 {device_alias} {device_battery_percentage}%";
              on-click = "blueman-manager";
              tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
              tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
              tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
            };

            battery = {
              states = {
                warning = 40;
                critical = 15;
              };
              format = "{icon} {capacity}%";
              format-charging = " {icon}";
              tooltip-format = "{capacity}% ({timeTo})";
              format-icons = ["" "" "" "" ""];
              on-click = "fuzzel-battery";
            };

            backlight = {
              device = "intel_backlight";
              format = "{icon} {percent}%";
              format-icons = ["󰃝" "󰃞" "󰃟" "󰃠"];
              tooltip-format = "{percent}%";
              on-scroll-up = "brightnessctl set +5%";
              on-scroll-down = "brightnessctl set 5%-";
            };

            "group/tray" = {
              orientation = "inherit";
              drawer = {
                transition-duration = 500;
                children-class = "tray-child";
                transition-left-to-right = false;
                click-to-reveal = true;
              };
              modules = ["custom/tray-icon" "tray"];
            };

            "custom/tray-icon" = {
              format = " 󰁂";
              tooltip = false;
            };

            tray.spacing = 8;

            privacy = {
              icon-spacing = 4;
              icon-size = 14;
              transition-duration = 250;
              modules = [
                {
                  type = "screenshare";
                  tooltip = true;
                }
                {
                  type = "audio-in";
                  tooltip = true;
                }
              ];
            };
          };
        };
      };
    };
  };
}
