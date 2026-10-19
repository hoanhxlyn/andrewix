{
  __findFile,
  lib,
  ...
}: {
  core.hardware = {host, ...}: let
    hasGpu = vendor: lib.any (g: g.vendor == vendor) host.gpu;
  in {
    includes =
      [
        <core.hardware.bootable>
        <core.hardware.monitors>
        <core.hardware.disko>
        <core.hardware.firmware>
        <core.hardware.logitech>
        <core.hardware.wifi>
        <core.hardware.mount>
        <core.hardware.sound>
        <core.hardware.network>
      ]
      # Selected from host facts (see modules/_lib), never from the hostname.
      ++ lib.optional host.isLaptop <core.hardware.power-manager>
      ++ lib.optional (hasGpu "intel") <core.hardware.intel-vaapi>
      ++ lib.optional (hasGpu "nvidia") <core.hardware.nvidia>;

    # Cross-fact checks the schema types cannot express; the aspects they guard
    # would otherwise silently ignore the fact.
    nixos.assertions = [
      {
        assertion = host.chargeThreshold == null || host.isLaptop;
        message = "chargeThreshold requires chassis = \"laptop\".";
      }
    ];
  };
}
