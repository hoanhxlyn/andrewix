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
      ];
      programs.niri = {
        enable = true;
      };
    };

    homeManager = {
      pkgs,
      config,
      ...
    }: let
      noctalia = cmd: ["noctalia-shell" "ipc" "call"] ++ (lib.splitString " " cmd);
    in {
      programs.niri.settings = {
        input = {
          keyboard = {
            repeat-rate = 25;
            repeat-delay = 300;
            xkb = {};
            numlock = true;
          };
          touchpad = {
            tap = true;
            natural-scroll = true;
            dwt = true;
          };
          mouse = {
            accel-profile = "flat";
          };
        };

        layout = {
          gaps = 8;
          center-focused-column = "never";
          default-column-width = {proportion = 0.5;};
          preset-column-widths = [
            {proportion = 0.33333;}
            {proportion = 0.5;}
            {proportion = 0.66667;}
          ];
          focus-ring = {
            enable = true;
            width = 3;
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

        cursor = {
          hide-when-typing = true;
        };

        animations = {
          enable = true;
          slowdown = 1.5;
        };

        binds = with config.lib.niri.actions; {
          "Mod+Space".action.spawn = noctalia "launcher toggle";
          "Mod+S".action.spawn = noctalia "controlCenter toggle";
          "Mod+Comma".action.spawn = noctalia "settings toggle";
          "Mod+Return".action.spawn = ["alacritty"];
          "Mod+Q".action = close-window;
          "Mod+F".action = fullscreen-window;
          "Mod+O" = {
            repeat = false;
            action = toggle-overview;
          };
          "Mod+L".action.spawn = noctalia "lockScreen lock";
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
          "Mod+semicolon".action.spawn = noctalia "lockScreen lock";
          "Mod+Left".action = focus-column-left;
          "Mod+Down".action = focus-window-down;
          "Mod+Up".action = focus-window-up;
          "Mod+Right".action = focus-column-right;
          "Mod+Ctrl+H".action = move-column-left;
          "Mod+Ctrl+J".action = move-window-down;
          "Mod+Ctrl+K".action = move-window-up;
          "Mod+Ctrl+L".action = move-column-right;
          "Mod+Ctrl+Left".action = move-column-left;
          "Mod+Ctrl+Down".action = move-window-down;
          "Mod+Ctrl+Up".action = move-window-up;
          "Mod+Ctrl+Right".action = move-column-right;
          "Mod+R".action = switch-preset-column-width;
          "Mod+Shift+R".action = switch-preset-window-height;
          "Mod+V".action = toggle-window-floating;
          "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;
          "Print".action.spawn = ["niri" "msg" "action" "screenshot"];
          "Mod+Shift+S".action.spawn = ["niri" "msg" "action" "screenshot-screen"];
          "Mod+Escape" = {
            allow-inhibiting = false;
            action = toggle-keyboard-shortcuts-inhibit;
          };
          "Mod+Shift+E".action = quit;
          "Mod+Shift+P".action = power-off-monitors;
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
          "Mod+WheelScrollDown".action = focus-workspace-down;
          "Mod+WheelScrollUp".action = focus-workspace-up;
        };

        window-rules = [
          {
            matches = [
              {
                app-id = "firefox";
                title = "Picture-in-Picture";
              }
            ];
            open-floating = true;
          }
        ];
      };
    };
  };
}
