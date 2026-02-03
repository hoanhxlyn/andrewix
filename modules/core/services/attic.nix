{
  core.services.attic = {
    nixos = {config, ...}: {
      services.atticd = {
        enable = true;
        # Env file for the server; the sops key matches the name atticserver
        # requires. Defaults cover sqlite + local storage in /var/lib/atticd
        # (StateDirectory).
        environmentFile = config.sops.templates."atticd.env".path;
        settings = {
          listen = "[::]:8080";
          jwt = {};
        };
      };

      # Symmetric HS256 instead of the RS256 private key (see core.services.sync.sops).
      sops.templates."atticd.env".content = ''
        ATTIC_SERVER_TOKEN_HS256_SECRET_BASE64=${config.sops.placeholder.ATTIC_SERVER_TOKEN_HS256_SECRET_BASE64}
      '';

      networking.firewall.allowedTCPPorts = [8080];
    };
  };
}
