{den, ...}: {
  andrewix.system.hostname.andrew-pc = den.lib.parametric {
    config = {
      networking.hostName = "andrew-pc";
      hardware.aic8800.enable = true;
    };
  };
}
