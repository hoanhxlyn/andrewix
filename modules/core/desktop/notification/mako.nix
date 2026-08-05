{
  core.desktop.notification.mako = {host, ...}: {
    homeManager = {pkgs, ...}: let
      dndToggle = pkgs.writeShellScriptBin "dnd-toggle" ''
        STATE_FILE="$XDG_RUNTIME_DIR/dnd-state"
        if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "1" ]; then
          echo "0" > "$STATE_FILE"
          makoctl mode -s default
          notify-send "DND" "Notifications enabled" -i stock_bell
        else
          echo "1" > "$STATE_FILE"
          makoctl mode -s do-not-disturb
          notify-send "DND" "Do Not Disturb enabled" -i notification-disabled
        fi
      '';
    in {
      gtk.iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus-Dark";
      };

      home.packages = [dndToggle];

      services.mako = {
        enable = true;
        settings = {
          actions = true;
          anchor = host.toast.position;
          width = host.toast.width;
          border-radius = host.toast.border.radius;
          border-size = host.toast.border.size;
          padding = let
            x = builtins.mul host.terminal.padding host.toast.padding.x;
            y = builtins.mul host.terminal.padding host.toast.padding.y;
          in "${toString x},${toString y}";
          # icons
          max-icon-size = builtins.mul host.terminal.fontSize 2;
          icon-border-radius = 6;
          icons = true;
          icon-path = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark";
          layer = host.toast.layer;
          markup = true;
          default-timeout = host.toast.timeout;
          sort = "-time";
          outer-margin = let
            x = builtins.mul host.terminal.padding host.toast.offset.x;
            y = builtins.mul host.terminal.padding host.toast.offset.y;
          in "${toString x},${toString y}";
          max-history = host.toast.history;
          # wezterm's OSC 777 notifications send expire_timeout=0 (never expire);
          # ignore it so default-timeout applies instead of hanging forever
          "app-name=wezterm" = {
            ignore-timeout = true;
            default-timeout = 3000;
          };
        };
      };
    };
  };
}
