{
  core.hardware.network.nixos = {
    host,
    lib,
    ...
  }: {
    networking.networkmanager = {
      enable = true;
      ensureProfiles.profiles = {
        default = {
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
        # Fixed MAC for a host that needs one (e.g. a LAN with MAC allowlisting).
        work = lib.mkIf (host.ethernet.clonedMac != null) {
          connection = {
            id = "work";
            type = "ethernet";
            interface-name = "enp4s0";
            # Beats `Wired (default)`, which also matches this NIC.
            autoconnect-priority = 10;
          };
          "802-3-ethernet".cloned-mac-address = host.ethernet.clonedMac;
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
    };
    networking.firewall.checkReversePath = "loose";
  };
}
