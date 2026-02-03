{
  __findFile,
  lib,
  ...
}: {
  core.hardware = {host, ...}: {
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
      ++ lib.optional (lib.elem "intel" host.gpu) <core.hardware.intel-vaapi>
      ++ lib.optional (lib.elem "nvidia" host.gpu) <core.hardware.nvidia>;

    # Cross-fact checks the schema types cannot express; the aspects they guard
    # would otherwise silently ignore the fact.
    nixos.assertions = [
      {
        assertion = host.nvidiaPrime == null || lib.elem "nvidia" host.gpu;
        message = "nvidiaPrime is set but gpu does not contain \"nvidia\".";
      }
      {
        assertion = host.chargeThreshold == null || host.isLaptop;
        message = "chargeThreshold requires formFactor = \"laptop\".";
      }
    ];
  };
}
