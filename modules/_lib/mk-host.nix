# Host builder: composes shared settings with per-host data and the
# workstation/wsl variant. Returns the `host` attrset consumed across
# modules/core/**.
#
# Hardware facts (formFactor, gpu, bootLoader, storage, ...) pass through
# untouched; den types and defaults them via `den.schema.host`
# (modules/schema.nix), and their names are checked here against the same
# definition (facts.nix).
{
  lib,
  self,
}: let
  settings = import "${self}/modules/_settings.nix";
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
  # attrNames never forces the option values, so `config` is not needed here.
  knownFacts = builtins.attrNames (import ./facts.nix {
    inherit lib;
    config = null;
  });
  own = [
    "is-workstation"
    "profiles"
    "monitors"
    "windowsName"
    "login"
    "defaults"
    "input"
    "accessibility"
    "appearance"
    "terminal"
    "locale"
  ];
in
  {
    is-workstation ? true,
    profiles ? null,
    monitors ? {},
    windowsName ? null,
    login ? settings.login,
    defaults ? {},
    input ? {},
    accessibility ? {},
    appearance ? {},
    terminal ? {},
    locale ? {},
    ...
  } @ args: let
    facts = builtins.removeAttrs args own;
    unknown = builtins.filter (k: !(builtins.elem k knownFacts)) (builtins.attrNames facts);
    workstation = {
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
      then settings.profiles
      else profiles;
    withSettings =
      (builtins.removeAttrs settings ["profiles"])
      // {
        users = effectiveProfiles;
        inherit login;
        # sections merge key by key: a host overrides only the keys it names
        defaults = lib.recursiveUpdate settings.defaults defaults;
        input = lib.recursiveUpdate settings.input input;
        accessibility = lib.recursiveUpdate settings.accessibility accessibility;
        appearance = lib.recursiveUpdate settings.appearance appearance;
        terminal = lib.recursiveUpdate settings.terminal terminal;
        locale = lib.recursiveUpdate settings.locale locale;
      };
  in
    assert lib.assertMsg (unknown == []) "mkHost: unknown host fact(s): ${toString unknown}";
    assert lib.assertMsg (is-workstation || windowsName != null) "mkHost: WSL host needs windowsName";
    assert lib.assertMsg (!is-workstation || windowsName == null) "mkHost: windowsName is WSL-only";
      lib.recursiveUpdate withSettings (
        facts
        // (
          if is-workstation
          then workstation
          else wsl
        )
      )
