# Monitor layout helper.
# Turns a simple per-monitor description into the positioned/scaled layout the
# WM consumes: only the primary output gets an explicit position (left anchor);
# non-primary outputs are left unconfigured so niri auto-places them to the right.
monitors:
builtins.mapAttrs (_: m: let
  extraKeys = builtins.removeAttrs m ["resolution" "refresh-rate" "is-primary" "scale"];
  base = {
    mode = {
      inherit (m.resolution) width height;
      refresh = m.refresh-rate;
    };
    scale = m.scale or 1;
  };
  position =
    if m.is-primary or false
    then {
      position = {
        x = 1;
        y = 0;
      };
    }
    else {};
in
  base // position // extraKeys)
monitors
