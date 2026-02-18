{
  den,
  inputs,
  ...
}: {
  andrewix.system.overlays = den.lib.parametric {
    config = {
      nixpkgs.overlays = [
        (import inputs.rust-overlay)
        (_: _: {
          inherit (inputs.fcitx5-vmk-nix.packages.x86_64-linux) fcitx5-vmk;
        })
      ];
    };
  };
}
