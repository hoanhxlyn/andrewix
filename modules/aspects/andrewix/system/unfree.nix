{den, ...}: {
  andrewix.system.unfree = den.lib.parametric {
    config = {
      nixpkgs.config.allowUnfree = true;
    };
  };
}
