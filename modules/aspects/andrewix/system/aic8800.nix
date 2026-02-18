{den, ...}: {
  andrewix.system.aic8800 = den.lib.parametric {
    config = {
      hardware.aic8800.enable = true;
    };
  };
}
