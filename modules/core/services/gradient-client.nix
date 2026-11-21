{
  # Substitute from the homelab's Gradient cache over the tailnet. MagicDNS
  # resolves the bare name through /etc/resolv.conf (100.100.100.100) without
  # systemd-resolved; timeout/fallback keep a dead cache from stalling pulls.
  # The key belongs to GRADIENT_CACHE_SIGNING_KEY.
  core.services.gradient-client.nixos = {
    nix.settings = {
      substituters = ["http://andrewix:1998/cache/andrewix"];
      # NOTE: server derives the name from serveUrl + cache, so it tracks
      # `http://andrewix:1998` — a moved cache needs this renamed too.
      trusted-public-keys = ["andrewix-1998-andrewix:rRaDERFJTlZDBSBQ1yElSatGbEu9TDhOBMCM1/o3PZA="];
      connect-timeout = 5;
      fallback = true;
    };
  };
}
