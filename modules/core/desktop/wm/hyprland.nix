{__findFile, ...}: {
  core.desktop.wm.hyprland = {host, ...}: {
    includes = [
      <core.desktop.statusbar.waybar>
      <core.desktop.notification.mako>
      <core.desktop.menu-launcher.fuzzel>
      <core.desktop.misc>
      <core.desktop.screenshot>
    ];

    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        acpilight
        wl-screenrec
        networkmanagerapplet
      ];
      programs.hyprland.enable = true;
      security.polkit.enable = true;
      # niri's module enabled this too; without it libsecret apps lose their keyring
      services.gnome.gnome-keyring.enable = true;
      services.playerctld.enable = true;
    };

    homeManager = {lib, ...}: let
      inherit (host) input;
      terminal = host.defaults.terminal;
      browser =
        {
          zen = "zen-beta";
          helium = "helium";
          firefox = "firefox";
        }.${
          host.defaults.browser
        };
      isLaptop = host.isLaptop or false;
      # mkHost already laid the monitors out left -> right in logical pixels, the
      # same numbers niri gets; the Lua API takes them as one table per output.
      monitorLine = conn: m: {
        output = conn;
        mode = "${toString m.mode.width}x${toString m.mode.height}@${toString m.mode.refresh}";
        position = "${toString m.position.x}x${toString m.position.y}";
        inherit (m) scale;
      };
      # Hyprland's Lua API: a bind is (keys, hl.dsp.* call, flags). The keys are
      # "SUPER + X" strings and the dispatcher is evaluated when the config loads.
      super = key: "SUPER + ${key}";
      bind = keys: dsp: {_args = [keys (lib.generators.mkLuaInline dsp)];};
      bindMouse = keys: dsp: {_args = [keys (lib.generators.mkLuaInline dsp) {mouse = true;}];};
      bindLocked = keys: dsp: {_args = [keys (lib.generators.mkLuaInline dsp) {locked = true;}];};
      # niri focused workspaces with Mod+<n> and moved columns with Mod+Ctrl+<n>
      workspaces = builtins.concatLists (map (n: [
        (bind (super (toString n)) "hl.dsp.focus({ workspace = ${toString n} })")
        (bind (super "CTRL + ${toString n}") "hl.dsp.window.move({ workspace = ${toString n} })")
      ]) [1 2 3 4 5]);
    in {
      wayland.windowManager.hyprland = {
        enable = true;
        settings = {
          monitor = builtins.attrValues (builtins.mapAttrs monitorLine (host.monitors or {}));

          config = {
            general = {
              gaps_in = 5;
              gaps_out = 10;
              border_size = 3;
              layout = "dwindle";
            };
            decoration.rounding = 3;
            animations.enabled = host.accessibility.animations.enable;

            input = {
              kb_layout = input.keyboard.layout;
              repeat_rate = input.keyboard.repeatRate;
              repeat_delay = input.keyboard.repeatDelay;
              accel_profile = input.mouse.accelProfile;
              follow_mouse = 0;
              touchpad = {
                natural_scroll = input.touchpad.naturalScroll;
                tap_to_click = input.touchpad.tap;
                disable_while_typing = input.touchpad.disableWhileTyping;
              };
            };

            misc = {
              disable_hyprland_logo = true;
              force_default_wallpaper = 0;
            };
          };

          bind =
            [
              # App launchers
              (bind (super "space") ''hl.dsp.exec_cmd("fuzzel")'')
              (bind (super "T") ''hl.dsp.exec_cmd("${terminal}")'')
              (bind (super "B") ''hl.dsp.exec_cmd("${browser}")'')
              (bind (super "C") ''hl.dsp.exec_cmd("waycal")'')
              (bind (super "N") ''hl.dsp.exec_cmd("nm-connection-editor")'')
              (bind (super "CTRL + B") ''hl.dsp.exec_cmd("${terminal} -e bluetui")'')
              (bind (super "Y") ''hl.dsp.exec_cmd("fuzzel-clipboard")'')
              (bind (super "CTRL + space") ''hl.dsp.exec_cmd("fuzzel-hub")'')
              (bind (super "A") ''hl.dsp.exec_cmd("fuzzel-audio")'')
              (bind (super "E") ''hl.dsp.exec_cmd("fuzzel-emoji")'')
              (bind (super "X") ''hl.dsp.exec_cmd("fuzzel-power")'')
              (bind (super "CTRL + D") ''hl.dsp.exec_cmd("makoctl dismiss")'')
              (bind (super "CTRL + N") ''hl.dsp.exec_cmd("dnd-toggle")'')
              # Windows
              (bind (super "Q") "hl.dsp.window.close()")
              (bind (super "F") ''hl.dsp.window.fullscreen({ mode = "maximized" })'')
              (bind (super "SHIFT + F") "hl.dsp.window.fullscreen()")
              (bind (super "V") ''hl.dsp.window.float({ action = "toggle" })'')
              (bind (super "H") ''hl.dsp.focus({ direction = "left" })'')
              (bind (super "J") ''hl.dsp.focus({ direction = "down" })'')
              (bind (super "K") ''hl.dsp.focus({ direction = "up" })'')
              (bind (super "L") ''hl.dsp.focus({ direction = "right" })'')
              (bind (super "CTRL + H") ''hl.dsp.window.move({ direction = "left" })'')
              (bind (super "CTRL + J") ''hl.dsp.window.move({ direction = "down" })'')
              (bind (super "CTRL + K") ''hl.dsp.window.move({ direction = "up" })'')
              (bind (super "CTRL + L") ''hl.dsp.window.move({ direction = "right" })'')
              # Screenshots & recording
              (bind (super "S") ''hl.dsp.exec_cmd("screenshot-annotate")'')
              (bind (super "SHIFT + S") ''hl.dsp.exec_cmd("screenshot-fullscreen")'')
              (bind (super "CTRL + S") ''hl.dsp.exec_cmd("record-toggle")'')
              # Audio
              (bind (super "M") ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")'')
              (bind (super "Page_Up") ''hl.dsp.exec_cmd("soundctl up")'')
              (bind (super "Page_Down") ''hl.dsp.exec_cmd("soundctl down")'')
              # Mouse
              (bindMouse (super "mouse:272") "hl.dsp.window.drag()")
              (bindMouse (super "mouse:273") "hl.dsp.window.resize()")
              # Media keys, allowed on the lock screen and repeating like niri's
              # allow-when-locked
              (bindLocked "XF86AudioRaiseVolume" ''hl.dsp.exec_cmd("soundctl up")'')
              (bindLocked "XF86AudioLowerVolume" ''hl.dsp.exec_cmd("soundctl down")'')
              (bindLocked "XF86AudioMute" ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")'')
              (bindLocked "XF86AudioMicMute" ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle")'')
              (bindLocked "XF86AudioPlay" ''hl.dsp.exec_cmd("playerctl play-pause")'')
              (bindLocked "XF86AudioStop" ''hl.dsp.exec_cmd("playerctl stop")'')
              (bindLocked "XF86AudioPrev" ''hl.dsp.exec_cmd("playerctl previous")'')
              (bindLocked "XF86AudioNext" ''hl.dsp.exec_cmd("playerctl next")'')
              (bindLocked "XF86MonBrightnessUp" ''hl.dsp.exec_cmd("xbacklight -inc 5")'')
              (bindLocked "XF86MonBrightnessDown" ''hl.dsp.exec_cmd("xbacklight -dec 5")'')
            ]
            ++ workspaces
            ++ lib.optionals isLaptop [
              (bind (super "G") ''hl.dsp.exec_cmd("fuzzel-battery")'')
              (bindLocked "switch:on:Lid Switch" ''hl.dsp.dpms({ action = "off" })'')
            ];
        };
      };
    };
  };
}
