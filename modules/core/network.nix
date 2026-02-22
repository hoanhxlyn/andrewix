let
  dns = ["1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4"];
in {
  core.network.nixos = {
    networking = {
      nameservers = dns;
      networkmanager.enable = true;
    };
  };
}
