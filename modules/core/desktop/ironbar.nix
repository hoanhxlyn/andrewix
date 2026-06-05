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
    in {
      imports = [
        inputs.ironbar.homeManagerModules.default
      ];

      home.packages = with pkgs; [
        playerctl
        dndScript
      ];

      programs.ironbar = {
        enable = true;
        systemd = false;
        config = {
          position = "top";
          height = 32;
          layer = "top";
          anchor_to_edges = true;
          start = [
            {
              type = "workspaces";
              all_monitors = false;
              name_map = {
                "1" = "";
                "2" = "󰈹";
                "3" = "󰍡";
                "4" = "";
                "5" = "󰝰";
              };
            }
            {
              type = "music";
              player_type = "mpris";
              show_status_icon = false;
              format = "{icon} {title} - {artist}";
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
              on_click_left = "!playerctl play-pause";
            }
          ];
          center = [
            {
              type = "focused";
              show_icon = true;
              show_title = true;
              truncate = {
                mode = "end";
                max_length = 30;
              };
            }
          ];
          end = lib.flatten [
            [{type = "tray";}]
            [
              {
                type = "network_manager";
                types_blacklist = ["loopback" "bridge"];
              }
            ]
            [
              {
                type = "bluetooth";
                format = {
                  not_found = "";
                  disabled = "󰂯 off";
                  enabled = "󰂯";
                  connected = "󰂱 {device_alias}";
                  connected_battery = "󰂱 {device_alias} {device_battery_percent}%";
                };
                on_click_left = "blueman-manager";
              }
            ]
            [
              {
                type = "script";
                name = "dnd";
                cmd = "${dndScript}/bin/ironbar-dnd";
                mode = "poll";
                interval = 2000;
                on_click_left = "!dnd-toggle";
              }
            ]
            (lib.optionals host.isLaptop [
              {
                type = "battery";
                name = "battery";
                format = "{icon} {percentage}%";
              }
              {
                type = "brightness";
                name = "brightness";
                format = "{icon} {percentage}%";
                mode = {
                  type = "systemd";
                  subsystem = "backlight";
                  name = "intel_backlight";
                };
                smooth_scroll_speed = 5.0;
              }
            ])
            [
              {
                type = "sys_info";
                name = "cpu";
                format = ["󰻠 {cpu_percent}%"];
                interval = {cpu = 3;};
              }
            ]
            [
              {
                type = "sys_info";
                name = "memory";
                format = ["󰍛 {memory_percent}%"];
                interval = {memory = 3;};
              }
            ]
            [{type = "volume";}]
            [
              {
                type = "clock";
                format = "󰥔 %H:%M";
                on_click_middle = "!waycal";
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
              color: ${colors.base05};
              background-color: alpha(${colors.base00}, 0.85);
              border-radius: 0;
              border: none;
              box-shadow: none;
              background-image: none;
            }

            .workspaces .item {
              padding: 0 5px;
              margin: 0 5px;
              color: ${colors.base04};
              border-bottom: 3px solid ${colors.base04};
            }

            .workspaces .item.visible {
              border-radius: 0;
              color: ${colors.base0E};
              border-bottom: 3px solid ${colors.base0E};
            }

            .battery { border-bottom: 3px solid ${colors.base0B}; }
            .network-manager { border-bottom: 3px solid ${colors.base08}; }
            .bluetooth { border-bottom: 3px solid ${colors.base0D}; }
            .volume { border-bottom: 3px solid ${colors.base07}; }
            .clock { border-bottom: 3px solid ${colors.base06}; }
            .brightness { border-bottom: 3px solid ${colors.base05}; }
            #dnd { border-bottom: 3px solid ${colors.base04}; padding: 0 5px; }
            .tray { border-bottom: 3px solid ${colors.base0C}; }
            #cpu { border-bottom: 3px solid ${colors.base09}; }
            #memory { border-bottom: 3px solid ${colors.base0A}; }
            .focused { margin: 0 5px; border-bottom: 3px solid ${colors.base03}; }
          '';
      };
    };
  };
}
