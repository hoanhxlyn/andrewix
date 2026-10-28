{inputs, ...}: {
  core.desktop.statusbar.waybar = {
    homeManager = {
      pkgs,
      host,
      lib,
      config,
      ...
    }: let
      dndScript = pkgs.writeShellApplication {
        name = "waybar-dnd";
        runtimeInputs = [pkgs.coreutils];
        text = ''
          STATE_FILE="''${XDG_RUNTIME_DIR:-/tmp}/dnd-state"
          if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "1" ]; then
            echo '{"text": "󰂛", "tooltip": "DND: On"}'
          else
            echo '{"text": "󰂟", "tooltip": "DND: Off"}'
          fi
        '';
      };
      recordingScript = pkgs.writeShellApplication {
        name = "waybar-recording";
        runtimeInputs = [pkgs.procps];
        text = ''
          if pgrep -x wl-screenrec > /dev/null; then
            echo '{"text": "󰑊", "tooltip": "Recording", "class": "recording"}'
          else
            echo '{"text": "", "tooltip": "Not recording"}'
          fi
        '';
      };
      # xpad exposes no battery, and the pad's radio sleep never reaches the
      # kernel (the USB device and input node stay), so the bar keys off real
      # input with a grace window: it clears after 60s of silence.
      gamepad = pkgs.writeShellApplication {
        name = "waybar-gamepad";
        runtimeInputs = [pkgs.coreutils pkgs.libnotify];
        text = ''
          STATE="''${XDG_RUNTIME_DIR:-/tmp}/waybar-gamepad"
          ACTIVE="$STATE.last"
          pad=""
          ev=""
          for js in /sys/class/input/js*; do
            [ -r "$js/device/name" ] || continue
            name=$(cat "$js/device/name")
            case "$name" in
              *[Xx]box* | *[Xx]-[Bb]ox*) pad="$name"; ev=/dev/input/$(basename "$js"/device/event*); break ;;
            esac
          done
          # notify only on real plug/unplug (radio sleep is invisible here)
          prev=$(cat "$STATE" 2>/dev/null || true)
          if [ ! -e "$STATE" ]; then
            printf '%s' "$pad" > "$STATE"
          elif [ "$pad" != "$prev" ]; then
            if [ -n "$pad" ]; then
              notify-send "Controller" "$pad connected"
            else
              notify-send "Controller" "$prev disconnected"
            fi
            printf '%s' "$pad" > "$STATE"
          fi
          now=$(date +%s)
          if [ -n "$ev" ] && [ "$( { timeout 2 cat "$ev" 2>/dev/null || true; } | wc -c )" -gt 0 ]; then
            printf '%s' "$now" > "$ACTIVE"
          fi
          last=$(cat "$ACTIVE" 2>/dev/null || true)
          if [ -n "$pad" ] && [ -n "$last" ] && [ "$((now - last))" -le 60 ]; then
            printf '{"text":"󰊗","tooltip":"%s"}\n' "$pad"
          else
            printf '{"text":""}\n'
          fi
        '';
      };
    in {
      # wrap waybar so the bar's own on-click/exec tools are declared deps,
      # not whatever happens to be on the session PATH
      imports = [
        (inputs.nwm.lib.getInstallModule {
          name = "waybar";
          value = {wlib, ...}: {
            imports = [wlib.modules.default];
            config.binName = "waybar";
          };
        })
      ];

      wrappers.waybar.enable = true;
      wrappers.waybar.package = pkgs.waybar;
      wrappers.waybar.runtimePkgs = with pkgs; [
        playerctl
        libnotify
        procps
        wireplumber
        brightnessctl
      ];

      home.packages = with pkgs; [playerctl] ++ [dndScript];
      stylix.targets.waybar.enable = true;
      stylix.targets.waybar.enableLeftBackColors = false;
      stylix.targets.waybar.background = lib.mkForce "alpha(@base00, 0.55)";

      programs.waybar = {
        enable = true;
        package = config.wrappers.waybar.wrapper;
        systemd.enable = true;
        style =
          /*
          css
          */
          ''
             #waybar {
               min-height: 32px;
             }

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
            #custom-vpn {border-bottom: 3px solid @base0C;}
            #wireplumber, #pulseaudio, #sndio {
               border-bottom: 3px solid @base07;
            }
            #clock { border-bottom: 3px solid @base06; }
            #backlight {border-bottom: 3px solid @base05;}
            #bluetooth {border-bottom: 3px solid @base0D;}
            #custom-dnd {padding: 0 5px; min-width: 18px; border-bottom: 3px solid @base04;}
            #custom-gamepad {padding: 0 5px; border-bottom: 3px solid @base0E;}
            #custom-recording {padding: 0 5px; min-width: 18px; border-bottom: 3px solid @base08;}
            #custom-recording.recording {color: @base08; border-bottom-color: @base08;}
            #tray {border-bottom: 3px solid @base0C;}
            #cpu { border-bottom: 3px solid @base09; }
            #memory { border-bottom: 3px solid @base0A; }
            #window { margin:0 5px; border-bottom: 3px solid @base03 }
            window#waybar.empty #window { border-bottom: none; margin: 0; padding: 0; }
            #mpris { margin:0 5px }

          '';
        settings.mainBar = {
          layer = "top";
          position = "top";
          height = 32;
          spacing = 5;

          modules-left = [
            "niri/workspaces"
            "niri/window"
            "group/mpris"
          ];
          modules-center = [
            "clock"
          ];
          modules-right = builtins.filter (m: m != null) [
            "tray"
            "privacy"
            "bluetooth"
            "custom/gamepad"
            "custom/dnd"
            "custom/recording"
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
            "cpu"
            "memory"
            "wireplumber"
          ];

          "niri/workspaces" = {
            all-outputs = false;
            hide-empty = true;
            on-click = "activate";
            format = "{index}";
          };

          "niri/window" = {
            max-length = 30;
            icon = true;
            icon-size = 16;
            format = "{title}";
          };

          "group/mpris".orientation = "inherit";
          "group/mpris".drawer.transition-duration = 300;
          "group/mpris".drawer.transition-left-to-right = true;
          "group/mpris".drawer.click-to-reveal = false;
          "group/mpris".modules = ["mpris#icon" "mpris#info"];

          "mpris#icon" = {
            format = "{status_icon}";
            format-paused = "{status_icon}";
            status-icons.playing = "󰝚 ";
            status-icons.paused = "󰏤";
            status-icons.stopped = "󰓛";
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

          cpu.format = "󰻠 {usage}%";
          cpu.tooltip-format = "CPU: {usage}% | {avg_frequency}GHz";
          cpu.interval = 3;

          memory.format = "󰍛 {percentage}%";
          memory.tooltip-format = "{used:0.1f}G / {total:0.1f}G";
          memory.interval = 3;

          wireplumber = {
            format = "{icon} {volume}%";
            format-muted = " Muted";
            format-icons = ["" "" ""];
            on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            on-scroll-up = "soundctl up";
            on-scroll-down = "soundctl down";
          };

          clock.format = "{:%m/%d %H:%M}";
          clock.on-click = "waycal";

          "custom/dnd" = {
            exec = "${dndScript}/bin/waybar-dnd";
            return-type = "json";
            signal = 10;
            on-click = "dnd-toggle";
          };

          "custom/gamepad" = {
            exec = "${gamepad}/bin/waybar-gamepad";
            return-type = "json";
            interval = 2;
            tooltip = true;
          };

          "custom/recording" = {
            exec = "${recordingScript}/bin/waybar-recording";
            return-type = "json";
            signal = 11;
            on-click = "record-toggle";
          };

          bluetooth = {
            format = "󰂯 {status}";
            format-no-controller = "";
            format-connected = "󰂱 {device_alias}";
            format-connected-battery = "󰂱 {device_alias} {device_battery_percentage}%";
            on-click = "${host.defaults.terminal} -e bluetui";
            tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
            tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          };

          battery = {
            states.warning = 40;
            states.critical = 15;
            format = "{icon} {capacity}%";
            tooltip-format = "{capacity}% ({timeTo})";
            format-icons.default = ["󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
            format-icons.charging = ["󰢟" "󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅"];
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
}
