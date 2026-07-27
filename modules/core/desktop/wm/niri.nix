{
  inputs,
  __findFile,
  ...
}: {
  flake-file.inputs.niri.url = "github:epireyn/niri-flake";

  core.desktop.wm.niri = {host, ...}: let
    niriOverlay = _final: prev: {
      niri-unstable = inputs.niri.packages.${prev.system}.niri-unstable;
    };
  in {
    includes = [
      <core/desktop/statusbar/ironbar>
      <core/desktop/waycal>
      <core/desktop/menu-launcher/fuzzel>
      <core/desktop/notification/mako>
      <core/desktop/wm/sway>
    ];

    nixos = {pkgs, ...}: {
      nixpkgs.overlays = [niriOverlay];
      nix.settings = {
        substituters = ["https://niri-epireyn.cachix.org"];
        trusted-public-keys = ["niri-epireyn.cachix.org-1:tlVyFN7CtsDT+ZcLPS+ekFWeT1X6X4OqvWqbBMyIzFA="];
      };
      environment.systemPackages = with pkgs; [
        acpilight
        slurp
        grim
        xwayland-satellite
        networkmanagerapplet
        blueman
      ];
      programs.niri = {
        enable = true;
        useNautilus = false;
        package = pkgs.niri-unstable.overrideAttrs (old: {
          patches = (old.patches or []) ++ [./niri-session-import-env.patch];
        });
      };
      security.polkit.enable = true;
      services.playerctld.enable = true;
    };

    homeManager = {pkgs, ...} @ homeConfig: let
      inherit (homeConfig) lib;
      action = homeConfig.config.lib.niri.actions;
      # noctalia = cmd: ["noctalia-shell" "ipc" "call"] ++ (lib.splitString " " cmd);
      terminalName = host.terminal.name;
      browserBin =
        {
          zen = "zen-beta";
          helium = "helium";
          firefox = "firefox";
        }.${
          host.defaultBrowser
        };
      # Generated binds (shrinks repetitive entries)
      arrowFocus = builtins.listToAttrs (map (dir: {
        name = "Mod+${dir}";
        value = {
          hotkey-overlay.hidden = true;
          action =
            {
              Left = action.focus-column-left;
              Down = action.focus-window-or-workspace-down;
              Up = action.focus-window-or-workspace-up;
              Right = action.focus-column-right;
            }.${
              dir
            };
        };
      }) ["Left" "Down" "Up" "Right"]);
      arrowMonitor = builtins.listToAttrs (map (dir: {
        name = "Mod+Shift+${dir}";
        value = {
          hotkey-overlay.hidden = true;
          action =
            {
              Left = action.focus-monitor-left;
              Right = action.focus-monitor-right;
            }.${
              dir
            };
        };
      }) ["Left" "Right"]);
      wsFocus = builtins.listToAttrs (map (n: {
        name = "Mod+${toString n}";
        value = {
          hotkey-overlay.hidden = true;
          action.focus-workspace = n;
        };
      }) [1 2 3 4 5]);
      wsMove = builtins.listToAttrs (map (n: {
        name = "Mod+Ctrl+${toString n}";
        value = {
          hotkey-overlay.hidden = true;
          action.move-column-to-workspace = n;
        };
      }) [1 2 3 4 5]);
      arrowMove = builtins.listToAttrs (map (dir: {
        name = "Mod+Ctrl+${dir}";
        value = {
          hotkey-overlay.hidden = true;
          action =
            {
              Left = action.move-column-left;
              Down = action.move-window-down-or-to-workspace-down;
              Up = action.move-window-up-or-to-workspace-up;
              Right = action.move-column-right;
            }.${
              dir
            };
        };
      }) ["Left" "Down" "Up" "Right"]);
    in {
      nixpkgs.overlays = [niriOverlay];
      imports = [
        inputs.niri.homeModules.niri
      ];

      programs.niri.package = pkgs.niri-unstable.overrideAttrs (old: {
        patches = (old.patches or []) ++ [./niri-session-import-env.patch];
      });

      programs.niri.settings = {
        input = {
          keyboard = {
            repeat-rate = 50;
            repeat-delay = 250;
            track-layout = "global";
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
          workspace-auto-back-and-forth = true;
        };

        cursor.hide-when-typing = true;

        animations = {
          enable = true;
          slowdown = 1.5;
        };

        outputs = host.monitors or {};

        layout = {
          gaps = 10;
          center-focused-column = "never";
          default-column-width = {proportion = 0.7;};
          preset-column-widths = [
            {proportion = 0.7;}
            {proportion = 0.5;}
            {proportion = 0.3;}
          ];
          focus-ring = {
            enable = true;
            width = 3;
          };
          border = {
            enable = false;
            width = 3;
          };
        };
        prefer-no-csd = true;

        spawn-at-startup = [
          {command = ["swaybg" "-i" homeConfig.config.stylix.image];}
          {command = ["wl-paste" "--type" "text" "--watch" "cliphist" "store"];}
          {command = ["wl-paste" "--type" "image" "--watch" "cliphist" "store"];}
          {command = ["solaar" "--window=hide"];}
        ];

        hotkey-overlay = {
          skip-at-startup = true;
          hide-not-bound = true;
        };

        screenshot-path = "~/Pictures/Screenshots/Screenshot_%Y-%m-%d_%H-%M-%S.png";

        environment.QT_QPA_PLATFORM = "wayland;xcb";
        environment.GTK_USE_PORTAL = "1";

        binds = with action;
          lib.mkMerge [
            {
              # App launchers
              "Mod+Space" = {
                hotkey-overlay.title = "Launcher";
                action.spawn = ["fuzzel"];
              };
              "Mod+T" = {
                hotkey-overlay.title = "Terminal";
                action.spawn = [terminalName];
              };
              "Mod+E" = {
                hotkey-overlay.title = "Yazi Files";
                action.spawn = [terminalName "-e" "yazi"];
              };
              "Mod+B" = {
                hotkey-overlay.title = "Browser";
                action.spawn = [browserBin];
              };
              "Mod+C" = {
                hotkey-overlay.title = "Calendar";
                action.spawn = ["waycal"];
              };
              "Mod+N" = {
                hotkey-overlay.title = "Network";
                action.spawn = ["nm-connection-editor"];
              };
              "Mod+Ctrl+B" = {
                hotkey-overlay.title = "Bluetooth";
                action.spawn = ["blueman-manager"];
              };
              "Mod+Y" = {
                hotkey-overlay.title = "Clipboard";
                action.spawn = ["fuzzel-clipboard"];
              };
              "Mod+Ctrl+Space" = {
                hotkey-overlay.title = "Hub";
                action.spawn = ["fuzzel-hub"];
              };
              "Mod+A" = {
                hotkey-overlay.title = "Audio";
                action.spawn = ["fuzzel-audio"];
              };
              "Mod+Ctrl+E" = {
                hotkey-overlay.title = "Emoji";
                action.spawn = ["fuzzel-emoji"];
              };
              "Mod+Ctrl+X" = {
                hotkey-overlay.title = "Power";
                action.spawn = ["fuzzel-power"];
              };
              "Mod+Ctrl+D" = {
                hotkey-overlay.title = "Dismiss Notification";
                action.spawn = ["makoctl" "dismiss"];
              };
              "Mod+Ctrl+N" = {
                hotkey-overlay.title = "Toggle DND";
                action.spawn = ["dnd-toggle"];
              };
              # Window management
              "Mod+Q" = {
                hotkey-overlay.title = "Close window";
                action = close-window;
              };
              "Mod+F" = {
                hotkey-overlay.title = "Maximize column";
                action = maximize-column;
              };
              "Mod+W" = {
                hotkey-overlay.title = "Toggle column tabbed";
                action = toggle-column-tabbed-display;
              };
              "Mod+Slash".action = show-hotkey-overlay;
              "Mod+O" = {
                repeat = false;
                hotkey-overlay.title = "Overview";
                action = toggle-overview;
              };
              "Mod+H".action = focus-column-left;
              "Mod+J".action = focus-window-or-workspace-down;
              "Mod+K".action = focus-window-or-workspace-up;
              "Mod+L".action = focus-column-right;
              "Shift+Alt+H".action = move-column-to-monitor-left;
              "Shift+Alt+L".action = move-column-to-monitor-right;
              "Mod+Comma".action = consume-or-expel-window-left;
              "Mod+Period".action = consume-or-expel-window-right;
              "Mod+R".action = switch-preset-column-width;
              "Mod+Shift+R".action = switch-preset-window-height;
              "Mod+Ctrl+R".action = reset-window-height;
              "Mod+Ctrl+F".action = expand-column-to-available-width;
              "Mod+Ctrl+C".action = center-visible-columns;
              "Mod+V" = {
                hotkey-overlay.title = "Toggle floating";
                action = toggle-window-floating;
              };
              "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;

              "Shift+Alt+Left".action = move-column-to-monitor-left;
              "Shift+Alt+Right".action = move-column-to-monitor-right;

              # Move column (Ctrl + hjkl)
              "Mod+Shift+H".action = focus-monitor-left;
              "Mod+Shift+L".action = focus-monitor-right;
              "Mod+Alt+H".action = move-column-to-monitor-left;
              "Mod+Ctrl+H".action = move-column-left;
              "Mod+Ctrl+J".action = move-window-down-or-to-workspace-down;
              "Mod+Ctrl+K".action = move-window-up-or-to-workspace-up;
              "Mod+Ctrl+L".action = move-column-right;
              "Mod+Alt+L".action = move-column-to-monitor-left;

              # Column resize (hidden — fine tuning)
              "Mod+Minus" = {
                hotkey-overlay.hidden = true;
                action.set-column-width = "-10%";
              };
              "Mod+Equal" = {
                hotkey-overlay.hidden = true;
                action.set-column-width = "+10%";
              };
              "Mod+Shift+Minus" = {
                hotkey-overlay.hidden = true;
                action.set-window-height = "-10%";
              };
              "Mod+Shift+Equal" = {
                hotkey-overlay.hidden = true;
                action.set-window-height = "+10%";
              };

              # Screenshots
              "Print".action.spawn = ["niri" "msg" "action" "screenshot"];
              "Mod+S" = {
                hotkey-overlay.title = "Screenshot";
                action.spawn = ["niri" "msg" "action" "screenshot"];
              };
              "Mod+Ctrl+S" = {
                hotkey-overlay.title = "Screenshot screen";
                action.spawn = ["niri" "msg" "action" "screenshot-screen"];
              };

              # Audio
              "XF86AudioRaiseVolume" = {
                allow-when-locked = true;
                action.spawn = ["wpctl" "set-volume" "--limit" "1.0" "@DEFAULT_AUDIO_SINK@" "5%+"];
              };
              "XF86AudioLowerVolume" = {
                allow-when-locked = true;
                action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"];
              };
              "XF86AudioMute" = {
                allow-when-locked = true;
                action.spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];
              };
              "XF86AudioMicMute" = {
                allow-when-locked = true;
                action.spawn = ["wpctl" "set-mute" "@DEFAULT_SOURCE@" "toggle"];
              };
              "Mod+M" = {
                hotkey-overlay.title = "Mute";
                allow-when-locked = true;
                action.spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];
              };
              "Mod+Page_Up" = {
                hotkey-overlay.title = "Volume up";
                allow-when-locked = true;
                action.spawn = ["wpctl" "set-volume" "--limit" "1.0" "@DEFAULT_AUDIO_SINK@" "5%+"];
              };
              "Mod+Page_Down" = {
                hotkey-overlay.title = "Volume down";
                allow-when-locked = true;
                action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"];
              };

              # Media
              "XF86AudioPlay" = {
                allow-when-locked = true;
                action.spawn = ["playerctl" "play-pause"];
              };
              "XF86AudioStop" = {
                allow-when-locked = true;
                action.spawn = ["playerctl" "stop"];
              };
              "XF86AudioPrev" = {
                allow-when-locked = true;
                action.spawn = ["playerctl" "previous"];
              };
              "XF86AudioNext" = {
                allow-when-locked = true;
                action.spawn = ["playerctl" "next"];
              };

              # Brightness
              "XF86MonBrightnessUp" = {
                allow-when-locked = true;
                action.spawn = ["xbacklight" "-inc" "5"];
              };
              "XF86MonBrightnessDown" = {
                allow-when-locked = true;
                action.spawn = ["xbacklight" "-dec" "5"];
              };
            }
            arrowFocus
            arrowMonitor
            wsFocus
            wsMove
            arrowMove
            (lib.mkIf (host.isLaptop or false) {
              "Mod+G" = {
                hotkey-overlay.title = "Battery";
                action.spawn = ["fuzzel-battery"];
              };
            })
          ];
        layer-rules = [
          {
            matches = [
              {
                namespace = "^ironbar$";
              }
            ];
            background-effect.blur = true;
          }
        ];
        window-rules = [
          # Floatting windows
          {
            matches = [
              {
                app-id = "firefox";
                title = "Picture-in-Picture";
              }
              {
                app-id = "zen*";
                title = "Picture-in-Picture";
              }
              {
                app-id = "helium";
                title = "Picture-in-Picture";
              }
              {app-id = "^.blueman-manager-wrapped$";}
            ];
            open-floating = true;
          }
          # Terminals
          {
            matches = [
              {app-id = "^Alacritty$";}
              {app-id = "^com\\.mitchellh\\.ghostty$";}
              {app-id = "kitty*";}
              {app-id = "rio*";}
              {app-id = "^org\\.wezfurlong\\.wezterm$";}
            ];
            background-effect.blur = true;
            draw-border-with-background = false;
            default-column-width = {proportion = 0.7;};
          }
          # Applications
          {
            matches = [
              {app-id = "^cursor$";}
              {app-id = "^helium$";}
              {app-id = "^zen$";}
              {app-id = "^libreoffice";} # tile normally, don't self-maximize
            ];
            open-maximized = false;
            default-column-width = {proportion = 1.0;};
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
