{
  config,
  lib,
  ...
}: {
  imports = [
    ./browsers.nix
    ./communication.nix
    ./power-management.nix
  ];

  config = lib.mkIf (!config.aspects.utilities.enable) {
    # Disable all utilities if not enabled
  };
}
