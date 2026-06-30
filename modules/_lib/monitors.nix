# Monitor layout helper.
# Turns a simple per-monitor description into the positioned/scaled layout the
# WM consumes: the primary output is shifted right by the total scaled width of
# all non-primary outputs sitting to its left.
monitors: let
  rightOffset =
    builtins.foldl'
    (acc: name: let
      m = monitors.${name};
      s = m.scale or 1;
    in
      if !(m.is-primary or false)
      then acc + (builtins.floor (m.resolution.width / s))
      else acc)
    0
    (builtins.attrNames monitors);
in
  builtins.mapAttrs (_: m: {
    mode = {
      inherit (m.resolution) width height;
      refresh = m.refresh-rate;
    };
    scale = m.scale or 1;
    position = {
      x =
        if (m.is-primary or false)
        then rightOffset
        else 0;
      y = 0;
    };
  })
  monitors
