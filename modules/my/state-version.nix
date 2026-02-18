let
  version = "25.11";
in {
  my.state-version = {
    nixos.system.stateVersion = version;
    homeManager.home.stateVersion = version;
  };
}
