{
  den.aspects.my.statusbar.waybar = {
    homeManager = {
      pkgs,
      host,
      ...
    }: let
      networkScript = pkgs.writeShellScriptBin "waybar-network" ''
        ICONS="󰤯 󰤟 󰤢 󰤥 󰤨 "
        TEXT=""
        TOOLTIP=""
        CLASS=""

        # WiFi
        WIFI_INFO=$(${pkgs.networkmanager}/bin/nmcli -t -f IN-USE,SIGNAL,SSID dev wifi 2>/dev/null | ${pkgs.coreutils}/bin/head -n1)
        if [ -n "$WIFI_INFO" ]; then
          SIGNAL=$(echo "$WIFI_INFO" | ${pkgs.coreutils}/bin/cut -d: -f2)
          SSID=$(echo "$WIFI_INFO" | ${pkgs.coreutils}/bin/cut -d: -f3)
          IDX=$((SIGNAL / 25))
          [ "$IDX" -gt 4 ] && IDX=4
          ICON=$(echo "$ICONS" | ${pkgs.coreutils}/bin/tr ' ' '\n' | ${pkgs.coreutils}/bin/sed -n "$((IDX+1))p")
          TEXT="$ICON $SSID"
          TOOLTIP="WiFi: $SIGNAL%"
        else
          # Ethernet
          ETH_INFO=$(${pkgs.networkmanager}/bin/nmcli -t -f DEVICE,STATE,TYPE dev 2>/dev/null | ${pkgs.gnugrep}/bin/grep ':connected:ethernet$' | ${pkgs.coreutils}/bin/head -n1)
          if [ -n "$ETH_INFO" ]; then
            DEV=$(echo "$ETH_INFO" | ${pkgs.coreutils}/bin/cut -d: -f1)
            IP=$(${pkgs.iproute2}/bin/ip -4 addr show "$DEV" 2>/dev/null | ${pkgs.gnugrep}/bin/grep -oP 'inet \K[\d.]+')
            TEXT="󰈀 $IP"
            TOOLTIP="$DEV"
          fi
        fi

        # VPN
        if ${pkgs.iproute2}/bin/ip link show proton0 2>/dev/null | ${pkgs.gnugrep}/bin/grep -qE ',UP,'; then
          TEXT="$TEXT 󰖂 "
          TOOLTIP="$TOOLTIP\nVPN: Connected"
        fi

        [ -z "$TEXT" ] && exit 0

        printf '{"text":"%s","tooltip":"%s"}' "$TEXT" "$TOOLTIP"
      '';
      dndScript = pkgs.writeShellScriptBin "waybar-dnd" ''
        STATE_FILE="$XDG_RUNTIME_DIR/dnd-state"
        if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "1" ]; then
          echo '{"text": "󰂛", "tooltip": "DND: On"}'
        else
          echo '{"text": "󰂟", "tooltip": "DND: Off"}'
        fi
      '';
    in {
      home.packages = with pkgs; [gsimplecal playerctl] ++ [networkScript dndScript];
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
            #custom-network { border-bottom: 3px solid @base08; }
            #custom-vpn {border-bottom: 3px solid @base0C;}
            #wireplumber, #pulseaudio, #sndio {
               border-bottom: 3px solid @base07;
            }
            #clock { border-bottom: 3px solid @base06; }
            #backlight {border-bottom: 3px solid @base05;}
            #bluetooth {border-bottom: 3px solid @base0D;}
            #custom-dnd {padding: 0 5px; min-width: 18px; border-bottom: 3px solid @base04;}
            #tray {border-bottom: 3px solid @base0C;}
            #cpu { border-bottom: 3px solid @base09; }
            #memory { border-bottom: 3px solid @base0A; }
            #window { margin:0 5px; border-bottom: 3px solid @base03 }
            window#waybar.empty #window { border-bottom: none; margin: 0; padding: 0; }
            #mpris { margin:0 5px }

          '';
        settings = {
          mainBar = {
            layer = "top";
            position = "top";
            spacing = 5;

            modules-left = [
              "niri/workspaces"
              "niri/window"
            ];
            modules-center = ["group/mpris"];
            modules-right = builtins.filter (m: m != null) [
              "tray"
              "privacy"
              "custom/network"
              "bluetooth"
              "custom/dnd"
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
              "cpu"
              "memory"
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
              dynamic-len = 25;
              dynamic-order = ["title" "artist"];
              tooltip = false;
            };

            cpu = {
              format = "󰻠 {usage}%";
              tooltip-format = "CPU: {usage}% | {avg_frequency}GHz";
              interval = 3;
            };

            memory = {
              format = "󰍛 {percentage}%";
              tooltip-format = "{used:0.1f}G / {total:0.1f}G";
              interval = 3;
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

            "custom/dnd" = {
              exec = "${dndScript}/bin/waybar-dnd";
              return-type = "json";
              signal = 10;
              on-click = "dnd-toggle";
            };

            "custom/network" = {
              exec = "${networkScript}/bin/waybar-network";
              return-type = "json";
              interval = 3;
              on-click = "nm-connection-editor";
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
              tooltip-format = "{capacity}% ({timeTo})";
              format-icons = {
                default = ["󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
                charging = ["󰢟" "󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅"];
              };
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
