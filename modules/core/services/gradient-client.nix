{
  # Substitute from the homelab's Gradient cache (http://andrewix over the
  # tailnet). The public key belongs to GRADIENT_CACHE_SIGNING_KEY.
  core.services.gradient-client.nixos = {
    nix.settings = {
      substituters = ["http://andrewix:1998/cache/andrewix"];
      trusted-public-keys = ["andrewix-andrewix:rRaDERFJTlZDBSBQ1yElSatGbEu9TDhOBMCM1/o3PZA="];
    };
  };
}
