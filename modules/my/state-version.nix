let
  version = "26.05";
in {
  my.state-version = {
    nixos.system.stateVersion = version;
    homeManager.home.stateVersion = version;
  };
}
