{
  core.network.nixos = {
    networking.networkmanager = {
      enable = true;
      appendNameservers = ["1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4"];
    };
  };
}
