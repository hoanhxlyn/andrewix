{den, ...}: {
  andrewix.system.hostname.andrew-laptop = den.lib.parametric {
    config = {
      networking.hostName = "andrew-laptop";
      hardware.aic8800.enable = true;
    };
  };
}
