{
  config,
  lib,
  ...
}: {
  imports = [
    ./power-management.nix
  ];

  config = lib.mkIf (!config.aspects.utilities.enable) {
    # Disable all utilities if not enabled
  };
}
