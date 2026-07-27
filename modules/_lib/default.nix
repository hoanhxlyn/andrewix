# Host builder: composes base settings with per-host data and the
# workstation/wsl variant. Returns the `host` attrset consumed across
# modules/core/**.
{lib}: let
  base = import ./base.nix;
  layoutMonitors = monitors:
    builtins.mapAttrs (_: m: let
      extraKeys = builtins.removeAttrs m ["resolution" "refresh-rate" "is-primary" "scale"];
      baseOutput = {
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
            x = 0;
            y = 0;
          };
        }
        else {};
    in
      baseOutput // position // extraKeys)
    monitors;
in
  {
    is-workstation ? true,
    profiles ? null,
    isLaptop ? false,
    monitors ? {},
    windowsName ? null,
    login ? base.login,
    backgroundImage ? base.backgroundImage,
    terminal ? base.terminal,
  }: let
    workstation = {
      inherit isLaptop;
      rclone.path = "gdrive";
      monitors = layoutMonitors monitors;
    };
    wsl =
      lib.recursiveUpdate
      {wsl.enable = true;}
      (
        if windowsName != null
        then {inherit windowsName;}
        else {}
      );
    effectiveProfiles =
      if profiles == null
      then base.profiles
      else profiles;
    baseWithUsers =
      (builtins.removeAttrs base ["profiles"])
      // {
        users = effectiveProfiles;
        inherit login backgroundImage;
        terminal = base.terminal // terminal;
      };
  in
    lib.recursiveUpdate baseWithUsers (
      if is-workstation
      then workstation
      else wsl
    )
