{
  core.services.tailscale.nixos = {config, ...}: {
    services.tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets.TAILSCALE_AUTH_KEY.path;
      # Let tailnet peers reach each other directly on the LAN, not via DERP.
      openFirewall = true;
    };
  };
}
