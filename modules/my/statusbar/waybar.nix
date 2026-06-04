{
  den.aspects.my.statusbar.waybar = {
    homeManager = {
      pkgs,
      host,
      ...
    }: let
      vpnStatusScript = pkgs.writeShellScriptBin "waybar-vpn-status" ''
        if ${pkgs.iproute2}/bin/ip link show proton0 2>/dev/null | ${pkgs.gnugrep}/bin/grep -qE ',UP,'; then
          echo '{"text":"󰖂","tooltip":"Proton VPN","class":"connected"}'
        else
          echo '{"text":""}'
        fi
      '';
    in {
      home.packages = with pkgs; [gsimplecal playerctl] ++ [vpnStatusScript];
      programs.waybar = {
        enable = true;
        settings = {
          mainBar = {
            layer = "top";
            position = "top";
            spacing = 4;

            modules-left = ["niri/workspaces" "mpris"];
            modules-center = ["clock"];
            modules-right = builtins.filter (m: m != null) [
              "tray"
              (
                if host.isLaptop
                then "network#wifi"
                else null
              )
              "network#eth"
              "custom/vpn"
              "bluetooth"
              "wireplumber"
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
            ];

            "niri/workspaces" = {
              all-outputs = false;
              format = "";
              on-click = "activate";
            };

            mpris = {
              format = "{player_icon} {dynamic}: {status_icon}";
              format-paused = "{player_icon} {dynamic}: {status_icon}";
              status-icons = {
                playing = "󰝚";
                paused = "󰏤";
                stopped = "󰓛";
              };
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
              format = "{:%a %m/%d/%y %H:%M}";
              tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
              on-click = "gsimplecal";
            };

            "network#wifi" = {
              interface = "wl*";
              format-wifi = "{icon} {essid}";
              format-disconnected = "";
              tooltip-format = "{ifname} via {gwaddr}";
              format-icon = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
            };

            "network#eth" = {
              interface = "enp*";
              format-ethernet = "󰈀";
              format-disconnected = "";
              tooltip-format = "{ifname} via {gwaddr}";
            };

            "custom/vpn" = {
              exec = "${vpnStatusScript}/bin/waybar-vpn-status";
              return-type = "json";
              interval = 3;
              on-click = "protonvpn-app";
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
              format = "{icon}";
              format-charging = " {icon}";
              tooltip-format = "{capacity}% ({timeTo})";
              format-icons = ["" "" "" "" ""];
              on-click = "fuzzel-battery";
            };

            backlight = {
              device = "intel_backlight";
              format = "{icon}";
              format-icons = ["󰃚" "󰃛" "󰃜" "󰃝" "󰃞" "󰃟" "󰃠"];
              tooltip-format = "{percent}%";
              on-click = "brightnessctl set 0%";
              on-scroll-up = "brightnessctl set +5%";
              on-scroll-down = "brightnessctl set 5%-";
            };

            tray.spacing = 8;
          };
        };
      };

      programs.waybar.style = ''
        #tray,
        #mpris,
        #network,
        #custom-vpn,
        #bluetooth,
        #wireplumber,
        #battery,
        #backlight,
        #clock {
          background-color: @base01;
          border-radius: 8px;
          padding: 0 10px;
          margin: 2px 3px;
        }

        #custom-vpn.connected {
          color: @base0D;
        }

        #workspaces {
          background-color: @base01;
          border-radius: 8px;
          border: none;
          padding: 0 4px;
          margin: 2px 3px;
        }

        .modules-left #workspaces button {
          font-size: 0;
          min-width: 13px;
          padding: 0;
          margin: 0 2px;
          border: none;
          border-bottom: none;
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
