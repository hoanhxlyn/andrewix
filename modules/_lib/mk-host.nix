# Host builder: composes shared settings with per-host data and the
# workstation/homelab/wsl variant. Returns the `host` attrset consumed across
# modules/core/**.
#
# Hardware facts (chassis, gpu, bootLoader, storage, ...) pass through
# untouched; den types and defaults them via `den.schema.host`
# (modules/schema.nix), and their names are checked here against the same
# definition (host-facts.nix).
{lib, ...}: let
  settings = import ../_settings.nix;
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
  knownFacts = builtins.attrNames (import ./host-facts.nix {
    inherit lib;
    config = null;
  });
  own = [
    "is-workstation"
    "is-homelab"
    "profiles"
    "monitors"
    "windowsName"
    "windows"
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
    is-homelab ? false,
    profiles ? null,
    monitors ? {},
    windowsName ? null,
    windows ? {},
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
        then {
          inherit windowsName;
          windows = let
            cfg = lib.recursiveUpdate settings.windows windows;
            root = "${cfg.mountRoot}/${cfg.drive}";
            home = "${root}/Users/${windowsName}";
          in {
            inherit root home;
            tools = builtins.mapAttrs (_: rel: "${home}/${rel}") cfg.tools;
          };
        }
        else {}
      );
    homelab = {homelab.enable = true;};
    # a host overrides only the keys it names (e.g. profiles.andrew.git.email)
    effectiveProfiles = lib.recursiveUpdate settings.profiles (
      if profiles == null
      then {}
      else profiles
    );
    withSettings =
      (builtins.removeAttrs settings ["profiles" "windows"])
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
    assert lib.assertMsg (is-homelab || is-workstation || windowsName != null) "mkHost: WSL host needs windowsName";
    assert lib.assertMsg (!(is-homelab || is-workstation) || windowsName == null) "mkHost: windowsName is WSL-only";
      lib.recursiveUpdate withSettings (
        facts
        // (
          if is-homelab
          then homelab
          else if is-workstation
          then workstation
          else wsl
        )
      )
