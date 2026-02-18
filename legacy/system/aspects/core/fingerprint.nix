{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.aspects.fingerprint.enable {
    services.fprintd = {
      enable = true;
      # Using standard fprintd - device 04f3:0c90 not yet supported
      # Track: https://gitlab.freedesktop.org/libfprint/libfprint/-/issues
      # or wait for nixpkgs to include elanmoc2 driver
    };

    # Optional: Allow fingerprint to unlock sudo in the terminal
    security.pam.services.sudo.fprintAuth = true;
  };
}
