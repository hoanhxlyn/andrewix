# Host builder: composes base settings with per-host data and the
# workstation/wsl variant. Returns the `host` attrset consumed across
# modules/core/**.
{lib}: let
  base = import ./base.nix;
  layoutMonitors = import ./monitors.nix;
in
  {
    is-workstation ? true,
    profiles ? null,
    isLaptop ? false,
    monitors ? {},
    windowsName ? null,
  }: let
    workstation = {
      inherit isLaptop;
      rclone.path = "/mnt/gdrive";
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
      (builtins.removeAttrs base ["profiles"]) // {users = effectiveProfiles;};
  in
    lib.recursiveUpdate baseWithUsers (
      if is-workstation
      then workstation
      else wsl
    )
