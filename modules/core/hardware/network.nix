{
  core.hardware.network.nixos = {
    networking.networkmanager = {
      enable = true;
      ensureProfiles.profiles.default = {
        connection = {
          id = "Wired (default)";
          type = "ethernet";
        };
        ipv4 = {
          method = "auto";
          ignore-auto-dns = true;
          dns = "8.8.8.8;8.8.4.4;1.1.1.1;1.0.0.1";
        };
        ipv6 = {
          method = "auto";
          ignore-auto-dns = true;
        };
      };
    };
    networking.firewall.checkReversePath = "loose";
  };
}
