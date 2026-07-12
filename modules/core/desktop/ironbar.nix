{inputs, ...}: {
  flake-file.inputs.ironbar = {
    url = "github:JakeStanger/ironbar";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  core.desktop.statusbar.ironbar = {
    nixos.nix.settings = {
      extra-substituters = ["https://jakestanger.cachix.org"];
      extra-trusted-public-keys = [
        "jakestanger.cachix.org-1:VWJE7AWNe5/KOEvCQRxoE8UsI2Xs2nHULJ7TEjYm7mM="
      ];
    };

    homeManager = {
      pkgs,
      host,
      config,
      lib,
      ...
    }: let
      colors = config.lib.stylix.colors.withHashtag;
      fontName = config.stylix.fonts.monospace.name;
      fontSize = toString config.stylix.fonts.sizes.applications;
      dndScript = pkgs.writeShellScriptBin "ironbar-dnd" ''
        STATE_FILE="$XDG_RUNTIME_DIR/dnd-state"
        if [ -f "$STATE_FILE" ] && [ "$(${pkgs.coreutils}/bin/cat "$STATE_FILE")" = "1" ]; then
          echo "󰂛"
        else
          echo "󰂟"
        fi
      '';
      # network_manager has no text/label field at all (verified in its source -
      # NetworkManagerProfile only has `icon`), so unlike every other module here
      # this one falls back to a script, mirroring waybar's own network script.
      networkScript = pkgs.writeShellScriptBin "ironbar-network" ''
        ICONS=("󰤯" "󰤟" "󰤢" "󰤥" "󰤨")
        TEXT=""

        WIFI_INFO=$(${pkgs.networkmanager}/bin/nmcli -t -f IN-USE,SIGNAL,SSID dev wifi 2>/dev/null | ${pkgs.gnugrep}/bin/grep '^\*' | ${pkgs.coreutils}/bin/head -n1)
        if [ -n "$WIFI_INFO" ]; then
          SIGNAL=$(echo "$WIFI_INFO" | ${pkgs.coreutils}/bin/cut -d: -f2)
          SSID=$(echo "$WIFI_INFO" | ${pkgs.coreutils}/bin/cut -d: -f3-)
          IDX=$((SIGNAL / 25))
          [ "$IDX" -gt 4 ] && IDX=4
          TEXT="''${ICONS[$IDX]} $SSID"
        else
          ETH_INFO=$(${pkgs.networkmanager}/bin/nmcli -t -f DEVICE,STATE,TYPE dev 2>/dev/null | ${pkgs.gnugrep}/bin/grep ':connected:ethernet$' | ${pkgs.coreutils}/bin/head -n1)
          if [ -n "$ETH_INFO" ]; then
            DEV=$(echo "$ETH_INFO" | ${pkgs.coreutils}/bin/cut -d: -f1)
            IP=$(${pkgs.iproute2}/bin/ip -4 addr show "$DEV" 2>/dev/null | ${pkgs.gnugrep}/bin/grep -oP 'inet \K[\d.]+')
            TEXT="󰈀 $IP"
          fi
        fi

        if ${pkgs.iproute2}/bin/ip link show proton0 2>/dev/null | ${pkgs.gnugrep}/bin/grep -qE ',UP,'; then
          TEXT="$TEXT 󰖂"
        fi

        echo "$TEXT"
      '';
      batteryThresholds = [9 18 27 36 45 54 63 72 81 90 100];
      batteryIcons = ["󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
      batteryChargingIcons = ["󰢟" "󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅"];
      mkBatteryProfiles = prefix: charging: icons:
        lib.listToAttrs (lib.imap0 (i: icon: {
            name = "${prefix}${toString i}";
            value = {
              when = {
                percent = lib.elemAt batteryThresholds i;
                inherit charging;
              };
              format = "${icon} {percentage}%";
            };
          })
          icons);
    in {
      imports = [
        inputs.ironbar.homeManagerModules.default
      ];

      home.packages = with pkgs; [
        playerctl
        dndScript
        networkScript
      ];

      programs.ironbar = {
        enable = true;
        systemd = false;
        config = {
          position = "top";
          height = 32;
          layer = "top";
          anchor_to_edges = true;
          popup_autohide = true;
          start = [
            {
              type = "workspaces";
              all_monitors = false;
              format = "{index}";
            }
            {
              type = "focused";
              show_icon = true;
              icon_size = 16;
              show_title = true;
              truncate = {
                mode = "end";
                max_length = 30;
              };
            }
          ];
          center = [
            {
              type = "music";
              player_type = "mpris";
              show_status_icon = true;
              format = "{title} - {artist}";
              truncate = {
                mode = "end";
                max_length = 25;
              };
              icons = {
                play = "󰝚";
                pause = "󰏤";
                stopped = "󰓛";
              };
              show_if = "playerctl status 2>/dev/null | ${pkgs.gnugrep}/bin/grep -qE 'Playing|Paused'";
              on_click_left = "playerctl play-pause";
            }
          ];
          end = lib.flatten [
            [{type = "tray";}]
            [
              {
                type = "script";
                name = "network";
                cmd = "${networkScript}/bin/ironbar-network";
                mode = "poll";
                interval = 3000;
                on_click_left = "nm-connection-editor";
              }
            ]
            [
              {
                type = "bluetooth";
                format = {
                  not_found = "";
                  disabled = "󰂯 off";
                  enabled = "󰂯 on";
                  connected = "󰂱 {device_alias}";
                  connected_battery = "󰂱 {device_alias} {device_battery_percent}%";
                };
                popup = {
                  max_height.devices = 6;
                  header = "󰂯 Bluetooth";
                  device = {
                    header = "{device_alias}";
                    header_battery = "{device_alias} 󰂁 {device_battery_percent}%";
                    footer = "{device_status}";
                  };
                };
              }
            ]
            [
              {
                type = "script";
                name = "dnd";
                cmd = "${dndScript}/bin/ironbar-dnd";
                mode = "poll";
                interval = 2000;
                on_click_left = "dnd-toggle";
              }
            ]
            (lib.optionals host.isLaptop [
              {
                type = "battery";
                name = "battery";
                show_icon = false;
                format = "{percentage}%";
                profiles =
                  (mkBatteryProfiles "discharging" false batteryIcons)
                  // (mkBatteryProfiles "charging" true batteryChargingIcons);
              }
              {
                # Same {icon} caveat as battery. use_default_profiles off so waybar's own 4-icon set (not ironbar's 11-step ramp) is what shows.
                type = "brightness";
                name = "brightness";
                format = "{percentage}%";
                mode = {
                  type = "systemd";
                  subsystem = "backlight";
                  name = "intel_backlight";
                };
                smooth_scroll_speed = 5.0;
                use_default_profiles = false;
                profiles = {
                  level25 = {
                    when = 25;
                    icon_label = "󰃝";
                  };
                  level50 = {
                    when = 50;
                    icon_label = "󰃞";
                  };
                  level75 = {
                    when = 75;
                    icon_label = "󰃟";
                  };
                  level100 = {
                    when = 100;
                    icon_label = "󰃠";
                  };
                };
              }
            ])
            [
              {
                type = "volume";
                name = "mic";
                show_sinks = false;
                show_sources = true;
                popup_orientation = "vertical";
                on_scroll_up = "wpctl set-volume --limit 1.0 @DEFAULT_SOURCE@ 5%+";
                on_scroll_down = "wpctl set-volume @DEFAULT_SOURCE@ 5%-";
              }
              {
                type = "volume";
                name = "volume";
                show_sinks = true;
                show_sources = false;
                popup_orientation = "vertical";
                on_scroll_up = "wpctl set-volume --limit 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
                on_scroll_down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
              }
            ]
            [
              {
                type = "sys_info";
                name = "cpu";
                format = ["󰻠 {cpu_percent:1.0}%"];
                interval = {cpu = 3;};
              }
            ]
            [
              {
                type = "sys_info";
                name = "memory";
                format = ["󰍛 {memory_percent:1.0}%"];
                interval = {memory = 3;};
              }
            ]
            [
              {
                type = "clock";
                format = "󰥔 %H:%M";
                on_click_left = "waycal";
              }
            ]
          ];
        };
        style =
          /*
          css
          */
          ''
            * {
              font-family: "${fontName}";
              font-size: ${fontSize}pt;
              font-weight: normal;
              color: ${colors.base05};
              border-radius: 0;
              border: none;
              box-shadow: none;
              background-image: none;
              background-color: transparent;
              margin: 0;
              padding: 0;
            }

            #bar {
              background-color: alpha(${colors.base00}, 0.55);
            }

            .widget {
              margin: 0 2px;
            }

            .widget:not(.workspaces):hover {
              background-color: alpha(${colors.base03}, 0.3);
            }

            .workspaces .item,
            .music,
            #network,
            .bluetooth,
            .volume,
            .clock,
            #dnd,
            .battery,
            .tray .item {
              cursor: pointer;
            }

            .workspaces .item {
              padding: 0 9px;
              border-bottom: none;
            }

            .workspaces .item:hover {
              background-color: alpha(${colors.base03}, 0.3);
            }

            .workspaces .item.visible {
              border-bottom: 3px solid ${colors.base0E};
            }

            .workspaces .item.focused label {
              color: ${colors.base0E};
              font-weight: bold;
            }

            .battery { padding: 0 6px; border-bottom: 3px solid ${colors.base0B}; }
            #network { padding: 0 6px; border-bottom: 3px solid ${colors.base08}; }
            .bluetooth { padding: 0 6px; border-bottom: 3px solid ${colors.base0D}; }
            .volume { padding: 0 6px; border-bottom: 3px solid ${colors.base07}; }
            .clock { padding: 0 6px; border-bottom: 3px solid ${colors.base06}; }
            .brightness { padding: 0 6px; border-bottom: 3px solid ${colors.base05}; }
            #dnd { padding: 0 6px; border-bottom: 3px solid ${colors.base04}; }
            .tray { padding: 0 6px; border-bottom: 3px solid ${colors.base0C}; }
            .tray .item { padding: 0 4px; }
            #cpu { padding: 0 6px; border-bottom: 3px solid ${colors.base09}; }
            #memory { padding: 0 6px; border-bottom: 3px solid ${colors.base0A}; }
            .music { padding: 0 6px; }
            .focused .icon { padding-left: 6px; }
            .focused .label { padding-right: 6px; border-bottom: 3px solid ${colors.base03}; }

            .popup {
              background-color: ${colors.base00};
              border: 1px solid alpha(${colors.base04}, 0.4);
              padding: 10px;
            }

            .popup button {
              background-color: alpha(${colors.base03}, 0.3);
              padding: 4px 8px;
            }

            .popup button:hover {
              background-color: alpha(${colors.base03}, 0.5);
            }

            .popup scale trough {
              min-height: 4px;
              background-color: alpha(${colors.base04}, 0.4);
            }

            .popup scale trough highlight {
              background-color: ${colors.base0D};
            }

            .popup scale trough slider {
              background-color: ${colors.base05};
              min-width: 12px;
              min-height: 12px;
            }
          '';
      };
    };
  };
}
