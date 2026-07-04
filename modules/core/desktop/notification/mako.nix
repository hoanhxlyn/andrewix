{
  core.notification.mako = {host, ...}: {
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
        pkill -SIGRTMIN+10 waybar
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
          anchor = "top-center";
          width = 400;
          border-radius = 12;
          border-size = 2;
          padding = "10,15";
          # icons
          max-icon-size = builtins.mul host.terminal.fontSize 2;
          icon-border-radius = 6;
          icons = true;
          icon-path = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark";
          layer = "top";
          markup = true;
          default-timeout = 3000;
          sort = "-time";
          margin = host.terminal.padding;
          max-history = 10;
          on-button-left = "invoke-default-action";
          on-button-right = "dismiss";
        };
      };
    };
  };
}
