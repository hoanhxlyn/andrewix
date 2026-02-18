{den, ...}: let
  stateVersion = "25.11";
in {
  my.state-version = den.lib.parametric {
    config = {
      system.stateVersion = stateVersion;
      home.stateVersion = stateVersion;
    };
  };
}
