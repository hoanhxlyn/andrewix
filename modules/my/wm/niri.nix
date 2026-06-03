{
  inputs,
  __findFile,
  ...
}: {
  flake-file.inputs.niri.url = "github:sodiboo/niri-flake";

  den.aspects.my.wm.niri = {host, ...}: {
    includes = [
      <my/statusbar/waybar>
      <my/menu-launcher/fuzzel>
      <my/notification/mako>
      <my/sway>
    ];

    nixos = {pkgs, ...}: {
      nixpkgs.overlays = [inputs.niri.overlays.niri];
      nix.settings = {
        substituters = ["https://niri.cachix.org"];
        trusted-public-keys = ["niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="];
      };
      environment.systemPackages = with pkgs; [
        nautilus
        brightnessctl
        slurp
        grim
        xwayland-satellite
        networkmanagerapplet
        (pkgs.catppuccin-sddm.override {
          flavor = "mocha";
          accent = "mauve";
        })
      ];
      programs.niri = {
        enable = true;
        package = pkgs.niri-unstable;
      };
      security.polkit.enable = true;
      services = {
        playerctld.enable = true;
        displayManager = {
          sddm = {
            enable = true;
            wayland.enable = true;
            theme = "catppuccin-mocha-mauve";
          };
          defaultSession = "niri";
        };
      };
    };

    homeManager = homeConfig: let
      action = homeConfig.config.lib.niri.actions;
      # noctalia = cmd: ["noctalia-shell" "ipc" "call"] ++ (lib.splitString " " cmd);
      terminalName = host.terminal.name;
    in {
      imports = [
        inputs.niri.homeModules.niri
      ];

      services.blueman-applet.enable = true;

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
        };

        cursor.hide-when-typing = true;

        animations = {
          enable = true;
          slowdown = 1.5;
        };

        outputs = let
          monitors = host.monitors or {};
          parseRes = res: let
            m = builtins.match "([0-9]+)x([0-9]+)" res;
          in {
            width = builtins.fromJSON (builtins.head m);
            height = builtins.fromJSON (builtins.elemAt m 1);
          };
          rightOffset =
            homeConfig.lib.foldlAttrs (acc: _: m: let
              res = parseRes m.resolution;
              scale = m.scale or 1;
            in
              if !(m.primary or false)
              then acc + (res.width / scale)
              else acc)
            0
            monitors;
        in
          homeConfig.lib.mapAttrs (_: m: let
            res = parseRes m.resolution;
          in {
            mode = {
              inherit (res) width;
              inherit (res) height;
              refresh = m."refresh-rate" or null;
            };
            inherit (m) scale;
            position = {
              x =
                if (m.primary or false)
                then rightOffset
                else 0;
              y = 0;
            };
          })
          monitors;

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
            width = 3;
          };
          border = {
            enable = false;
            width = 3;
          };
        };
        prefer-no-csd = true;

        spawn-at-startup = [
          # {command = ["noctalia-shell"];}
          {argv = ["waybar"];}
          {
            command = [
              "swaybg"
              "-m"
              "fill"
              "-i"
              "${homeConfig.config.home.homeDirectory}/Pictures/wallpapers/wallpaperflare.com_wallpaper(2).jpg"
            ];
          }
        ];

        hotkey-overlay = {
          skip-at-startup = true;
          hide-not-bound = true;
        };

        screenshot-path = "~/Pictures/Screenshots/Screenshot_%Y-%m-%d_%H-%M-%S.png";

        environment.QT_QPA_PLATFORM = "wayland";

        binds = with action; {
          # "Mod+Space".action.spawn = noctalia "launcher toggle";
          "Mod+Space".action.spawn = ["fuzzel"];
          # "Mod+S".action.spawn = noctalia "controlCenter toggle";
          # "Mod+Comma".action.spawn = noctalia "settings toggle";
          "Mod+T".action.spawn = [terminalName];
          "Mod+E".action.spawn = ["nautilus"];
          "Mod+B".action.spawn = ["zen-beta"];
          # "Mod+Shift+B".action.spawn = noctalia "bluetoothManager toggle";
          "Mod+Shift+B".action.spawn = ["blueman-manager"];
          "Mod+N".action.spawn = ["nm-connection-editor"];
          # "Mod+Y".action.spawn = noctalia "plugin:clipper toggle";
          "Mod+Y".action.spawn = ["fuzzel-clipboard"];
          "Mod+Ctrl+Space".action.spawn = ["fuzzel-hub"];
          "Mod+A".action.spawn = ["fuzzel-audio"];
          "Mod+Ctrl+E".action.spawn = ["fuzzel-emoji"];
          "Mod+Shift+X".action.spawn = ["fuzzel-power"];
          "Mod+Q".action = close-window;
          "Mod+F".action = maximize-column;
          "Mod+W".action = toggle-column-tabbed-display;
          "Mod+Slash".action = show-hotkey-overlay;
          "Mod+O" = {
            repeat = false;
            action = toggle-overview;
          };
          # "Mod+semicolon".action.spawn = noctalia "lockScreen lock";
          "Mod+semicolon".action.spawn = ["swaylock" "-f"];
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
          "Mod+J".action = focus-window-or-workspace-down;
          "Mod+K".action = focus-window-or-workspace-up;
          "Mod+L".action = focus-column-right;
          "Mod+Left".action = focus-column-left;
          "Mod+Down".action = focus-window-or-workspace-down;
          "Mod+Up".action = focus-window-or-workspace-up;
          "Mod+Right".action = focus-column-right;
          "Mod+Shift+H".action = focus-monitor-left;
          "Mod+Shift+L".action = focus-monitor-right;
          "Mod+Shift+Left".action = focus-monitor-left;
          "Mod+Shift+Right".action = focus-monitor-right;
          "Shift+Alt+Left".action = move-column-to-monitor-left;
          "Shift+Alt+Right".action = move-column-to-monitor-right;
          "Mod+Ctrl+H".action = move-column-left;
          "Mod+Ctrl+J".action = move-window-down-or-to-workspace-down;
          "Mod+Ctrl+K".action = move-window-up-or-to-workspace-up;
          "Mod+Ctrl+L".action = move-column-right;
          "Mod+Ctrl+Left".action = move-column-left;
          "Mod+Ctrl+Down".action = move-window-down-or-to-workspace-down;
          "Mod+Ctrl+Up".action = move-window-up-or-to-workspace-up;
          "Mod+Ctrl+Right".action = move-column-right;
          "Mod+Comma".action = consume-or-expel-window-left;
          "Mod+Period".action = consume-or-expel-window-right;
          "Mod+R".action = switch-preset-column-width;
          "Mod+Shift+R".action = switch-preset-window-height;
          "Mod+Ctrl+R".action = reset-window-height;
          "Mod+Ctrl+F".action = expand-column-to-available-width;
          "Mod+Ctrl+C".action = center-visible-columns;
          "Mod+V".action = toggle-window-floating;
          "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;
          "Mod+Minus".action.set-column-width = "-10%";
          "Mod+Equal".action.set-column-width = "+10%";
          "Mod+Shift+Minus".action.set-window-height = "-10%";
          "Mod+Shift+Equal".action.set-window-height = "+10%";
          "Print".action.spawn = ["niri" "msg" "action" "screenshot"];
          "Mod+S".action.spawn = ["niri" "msg" "action" "screenshot"];
          "Mod+Shift+S".action.spawn = ["niri" "msg" "action" "screenshot-screen"];
          "Mod+Escape" = {
            allow-inhibiting = false;
            action = toggle-keyboard-shortcuts-inhibit;
          };
          "Mod+Shift+E".action = quit;
          "Mod+Shift+P".action = power-off-monitors;
          "XF86AudioRaiseVolume" = {
            allow-when-locked = true;
            # action.spawn = noctalia "volume increase";
            action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"];
          };
          "XF86AudioLowerVolume" = {
            allow-when-locked = true;
            # action.spawn = noctalia "volume decrease";
            action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"];
          };
          "XF86AudioMute" = {
            allow-when-locked = true;
            # action.spawn = noctalia "volume muteOutput";
            action.spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];
          };
          "XF86AudioMicMute" = {
            allow-when-locked = true;
            # action.spawn = noctalia "volume muteInput";
            action.spawn = ["wpctl" "set-mute" "@DEFAULT_SOURCE@" "toggle"];
          };
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
          "Mod+M" = {
            allow-when-locked = true;
            action.spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];
          };
          "Mod+Page_Up" = {
            allow-when-locked = true;
            action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"];
          };
          "Mod+Page_Down" = {
            allow-when-locked = true;
            action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"];
          };
          "XF86MonBrightnessUp" = {
            allow-when-locked = true;
            # action.spawn = noctalia "brightness increase";
            action.spawn = ["brightnessctl" "set" "+5%"];
          };
          "XF86MonBrightnessDown" = {
            allow-when-locked = true;
            # action.spawn = noctalia "brightness decrease";
            action.spawn = ["brightnessctl" "set" "5%-"];
          };
        };
        layer-rules = [
          {
            matches = [
              {
                namespace = "^launcher$";
              }
            ];
            # background-effect.blur = true;
          }
        ];
        window-rules = [
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
          {
            matches = [{app-id = "^Alacritty$";}];
            # background-effect.blur = true;
          }
        ];
      };
    };
  };
}
