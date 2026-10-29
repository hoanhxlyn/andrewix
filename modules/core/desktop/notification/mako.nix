{
  core.desktop.notification.mako = {host, ...}: {
    homeManager = {pkgs, ...}: let
      # mako's complete anchor set; any other value makes mako refuse to start.
      anchors = [
        "top-right"
        "top-center"
        "top-left"
        "bottom-right"
        "bottom-center"
        "bottom-left"
        "center-right"
        "center-left"
        "center"
      ];
      dndToggle = pkgs.writeShellScriptBin "dnd-toggle" ''
        STATE_FILE="$XDG_RUNTIME_DIR/dnd-state"
        if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "1" ]; then
          echo "0" > "$STATE_FILE"
          makoctl mode -s default
          notify-send -u critical "DND" "Notifications enabled" -i stock_bell
        else
          echo "1" > "$STATE_FILE"
          makoctl mode -s do-not-disturb
          notify-send -u critical "DND" "Do Not Disturb enabled" -i notification-disabled
        fi
        # waybar's dnd module runs once per signal, not on an interval
        pkill --signal RTMIN+10 waybar || true
      '';
    in
      assert builtins.elem host.appearance.toast.position anchors
      || builtins.throw "appearance.toast.position must be a mako anchor, got \"${host.appearance.toast.position}\""; {
        home.packages = [dndToggle];

        services.mako.enable = true;
        services.mako.settings = {
          actions = true;
          anchor = host.appearance.toast.position;
          width = host.appearance.toast.width;
          border-radius = host.appearance.toast.border.radius;
          border-size = host.appearance.toast.border.size;
          padding = let
            x = builtins.mul host.terminal.padding host.appearance.toast.padding.x;
            y = builtins.mul host.terminal.padding host.appearance.toast.padding.y;
          in "${toString x},${toString y}";
          # icons
          max-icon-size = builtins.mul host.appearance.font.size 2;
          icon-border-radius = 6;
          icons = true;
          icon-path = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark";
          layer = host.appearance.toast.layer;
          markup = true;
          default-timeout = host.appearance.toast.timeout;
          sort = "-time";
          outer-margin = let
            x = builtins.mul host.terminal.padding host.appearance.toast.offset.x;
            y = builtins.mul host.terminal.padding host.appearance.toast.offset.y;
          in "${toString x},${toString y}";
          max-history = host.appearance.toast.history;
          # wezterm's OSC 777 notifications send expire_timeout=0 (never expire);
          # ignore it so default-timeout applies instead of hanging forever
          "app-name=wezterm".ignore-timeout = true;
          "app-name=wezterm".default-timeout = 3000;
          # a mode is only a label; dnd-toggle gets no silencing without criteria
          "mode=do-not-disturb".invisible = true;
          # hardware warnings (battery, MSI) still punch through
          "mode=do-not-disturb urgency=critical".invisible = false;
        };
      };
  };
}
