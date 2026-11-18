{
  # Substitute from the homelab's Gradient cache over the tailnet. MagicDNS
  # resolves the bare name through /etc/resolv.conf (100.100.100.100) without
  # systemd-resolved; timeout/fallback keep a dead cache from stalling pulls.
  # The key belongs to GRADIENT_CACHE_SIGNING_KEY.
  core.services.gradient-client.nixos = {
    nix.settings = {
      substituters = ["http://andrewix:1998/cache/andrewix"];
      trusted-public-keys = ["andrewix-andrewix:rRaDERFJTlZDBSBQ1yElSatGbEu9TDhOBMCM1/o3PZA="];
      connect-timeout = 5;
      fallback = true;
    };
  };
}
