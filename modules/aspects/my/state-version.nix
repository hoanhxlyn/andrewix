{den, ...}: {
  my.state-version = den.lib.parametric {
    config = {
      system.stateVersion = "25.11";
      home.stateVersion = "25.11";
    };
  };
}
