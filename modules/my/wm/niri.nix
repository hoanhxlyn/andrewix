{
  __findFile,
  lib,
  inputs,
  ...
}: {
  flake-file.inputs.niri = {
    url = "github:sodiboo/niri-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.my.wm.niri = {
    includes = [
      (<core.login-manager> "niri")
      <my/de/noctalia>
    ];
    nixos = {pkgs, ...}: {
      imports = [
        inputs.niri.nixosModules.niri
      ];
      environment.systemPackages = with pkgs; [
        brightnessctl
        slurp
        grim
        playerctl
        xwayland-satellite
        nautilus
      ];
      programs.niri.enable = true;
    };

    homeManager = {config, ...}: let
      noctalia = cmd: ["noctalia-shell" "ipc" "call"] ++ (lib.splitString " " cmd);
    in {
      programs.niri.settings = {
        input = {
          keyboard = {
            repeat-rate = 25;
            repeat-delay = 300;
            xkb = {
              layout = "us";
              options = "compose:ralt,ctrl:nocaps";
              model = "";
            };
          };
          touchpad = {
            tap = true;
            natural-scroll = true;
            dwt = true;
          };
          # mouse = {
          #   accel-profile = "flat";
          # };
          focus-follows-mouse.max-scroll-amount = "0%";
        };

        cursor.hide-when-typing = true;

        animations = {
          enable = true;
          slowdown = 1.5;
        };

        outputs = {
          "HDMI-A-2" = {
            focus-at-startup = true;
            mode = {
              height = 1080;
              width = 1920;
              refresh = 74.973;
            };
          };
          "HDMI-A-1" = {
            focus-at-startup = false;
            mode = {
              height = 1080;
              width = 1920;
              refresh = 74.973;
            };
          };
        };

        layout = {
          gaps = 10;
          center-focused-column = "never";
          default-column-width = {proportion = 0.5;};
          preset-column-widths = [
            {proportion = 0.3;}
            {proportion = 0.5;}
            {proportion = 0.7;}
          ];
          focus-ring = {
            enable = true;
            width = 4;
            # active = "#7fc8ff";
            # inactive = "#505050";
          };
          border = {
            enable = false;
            width = 3;
            # active = "#7fc8ff";
            # inactive = "#505050";
            urgent = "#9b0000";
          };
        };
        prefer-no-csd = true;

        spawn-at-startup = [
          {command = ["noctalia-shell"];}
        ];

        hotkey-overlay = {
          skip-at-startup = true;
          hide-not-bound = true;
        };

        screenshot-path = "~/Pictures/Screenshots/Screenshot_%Y-%m-%d_%H-%M-%S.png";

        environment = {
          QT_QPA_PLATFORM = "wayland";
          DISPLAY = null;
        };

        binds = with config.lib.niri.actions; {
          "Mod+Space".action.spawn = noctalia "launcher toggle";
          "Mod+S".action.spawn = noctalia "controlCenter toggle";
          "Mod+Comma".action.spawn = noctalia "settings toggle";
          "Mod+Return".action.spawn = ["alacritty"];
          "Mod+T".action.spawn = ["alacritty"];
          "Mod+E".action.spawn = ["nautilus"];
          "Mod+B".action.spawn = ["zen-beta"];
          "Mod+Shift+B".action.spawn = noctalia "bluetoothManager toggle";
          "Mod+Y".action.spawn = noctalia "plugin:clipper toggle";
          "Mod+Q".action = close-window;
          "Mod+F".action = maximize-column;
          "Mod+O" = {
            repeat = false;
            action = toggle-overview;
          };
          "Mod+semicolon".action.spawn = noctalia "lockScreen lock";
          "Mod+1".action.focus-workspace = 1;
          "Mod+2".action.focus-workspace = 2;
          "Mod+3".action.focus-workspace = 3;
          "Mod+4".action.focus-workspace = 4;
          "Mod+5".action.focus-workspace = 5;
          "Mod+6".action.focus-workspace = 6;
          "Mod+7".action.focus-workspace = 7;
          "Mod+8".action.focus-workspace = 8;
          "Mod+9".action.focus-workspace = 9;
          "Mod+Ctrl+1".action.move-column-to-workspace = 1;
          "Mod+Ctrl+2".action.move-column-to-workspace = 2;
          "Mod+Ctrl+3".action.move-column-to-workspace = 3;
          "Mod+Ctrl+4".action.move-column-to-workspace = 4;
          "Mod+Ctrl+5".action.move-column-to-workspace = 5;
          "Mod+Ctrl+6".action.move-column-to-workspace = 6;
          "Mod+Ctrl+7".action.move-column-to-workspace = 7;
          "Mod+Ctrl+8".action.move-column-to-workspace = 8;
          "Mod+Ctrl+9".action.move-column-to-workspace = 9;
          "Mod+H".action = focus-column-left;
          "Mod+J".action = focus-window-down;
          "Mod+K".action = focus-window-up;
          "Mod+L".action = focus-column-right;
          "Mod+Ctrl+H".action = move-column-left;
          "Mod+Ctrl+J".action = move-window-down;
          "Mod+Ctrl+K".action = move-window-up;
          "Mod+Ctrl+L".action = move-column-right;
          "Mod+R".action = switch-preset-column-width;
          "Mod+Shift+R".action = switch-preset-window-height;
          "Mod+V".action = toggle-window-floating;
          "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;
          "Mod+Minus".action.set-column-width = "-10%";
          "Mod+Equal".action.set-column-width = "+10%";
          "Mod+Shift+Minus".action.set-window-height = "-10%";
          "Mod+Shift+Equal".action.set-window-height = "+10%";
          "Print".action.spawn = ["niri" "msg" "action" "screenshot"];
          "Mod+Shift+S".action.spawn = ["niri" "msg" "action" "screenshot-screen"];
          "Mod+Escape" = {
            allow-inhibiting = false;
            action = toggle-keyboard-shortcuts-inhibit;
          };
          "Mod+Shift+E".action = quit;
          "Mod+Shift+P".action = power-off-monitors;
          "Mod+WheelScrollDown".action = focus-workspace-down;
          "Mod+WheelScrollUp".action = focus-workspace-up;
          "XF86AudioRaiseVolume" = {
            allow-when-locked = true;
            action.spawn = noctalia "volume increase";
          };
          "XF86AudioLowerVolume" = {
            allow-when-locked = true;
            action.spawn = noctalia "volume decrease";
          };
          "XF86AudioMute" = {
            allow-when-locked = true;
            action.spawn = noctalia "volume muteOutput";
          };
          "XF86AudioMicMute" = {
            allow-when-locked = true;
            action.spawn = noctalia "volume muteInput";
          };
          "XF86MonBrightnessUp" = {
            allow-when-locked = true;
            action.spawn = noctalia "brightness increase";
          };
          "XF86MonBrightnessDown" = {
            allow-when-locked = true;
            action.spawn = noctalia "brightness decrease";
          };
        };

        window-rules = [
          {
            matches = [{app-id = "alacritty";}];
            default-column-width = {proportion = 0.5;};
          }
          {
            matches = [
              {
                app-id = "firefox";
                title = "Picture-in-Picture";
              }
              {
                app-id = "zen";
                title = "Picture-in-Picture";
              }
              {
                app-id = "zen-beta";
                title = "Picture-in-Picture";
              }
            ];
            open-floating = true;
          }
          {
            matches = [{}];
            geometry-corner-radius = {
              top-left = 3.0;
              top-right = 3.0;
              bottom-left = 3.0;
              bottom-right = 3.0;
            };
            clip-to-geometry = true;
          }
        ];
      };
    };
  };
}
