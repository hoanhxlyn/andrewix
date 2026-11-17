{
  # Substitute from the homelab's Gradient cache over the tailnet. Addressed by
  # tailnet IP: MagicDNS needs systemd-resolved, which this repo does not run.
  # The public key belongs to GRADIENT_CACHE_SIGNING_KEY.
  core.services.gradient-client.nixos = {
    nix.settings = {
      substituters = ["http://100.126.121.93:1998/cache/andrewix"];
      trusted-public-keys = ["andrewix-andrewix:rRaDERFJTlZDBSBQ1yElSatGbEu9TDhOBMCM1/o3PZA="];
    };
  };
}
