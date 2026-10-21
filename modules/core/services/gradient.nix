{inputs, ...}: {
  flake-file.inputs.gradient = {
    url = "github:wavelens/gradient";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Gradient CI + binary cache: builds every host closure on push (polling) and
  # serves the results to the tailnet on http://andrewix:1998.
  core.services.gradient = {
    nixos = {
      config,
      pkgs,
      ...
    }: {
      imports = [inputs.gradient.nixosModules.default];

      services.gradient = {
        enable = true;
        # Tailnet-only: bare MagicDNS name resolved through the tailnet's search
        # domain, plaintext inside WireGuard, everything on 1998.
        domain = "andrewix";
        serveUrl = "http://andrewix:1998";
        useTls = false;

        secrets = {
          jwtFile = config.sops.secrets.GRADIENT_SECRETS_JWT.path;
          cryptFile = config.sops.secrets.GRADIENT_SECRETS_CRYPT.path;
        };

        postgres.enable = true;
        # Self-registering local worker; the module joins it to team "server",
        # which every project gets for its workers.
        worker.enable = true;

        state = {
          users.andrew = {
            email = "hoanhxlyn@users.noreply.github.com";
            superuser = true;
            password_file = config.sops.secrets.GRADIENT_USER_PASSWORD_HASH.path;
          };

          projects.andrewix = {
            created_by = "andrew";
            private_key_file = config.sops.secrets.GRADIENT_PROJECT_SSH_KEY.path;
            teams = [
              {
                team = "server";
                users = false;
                workers = true;
              }
            ];
          };

          caches.andrewix = {
            created_by = "andrew";
            signing_key_file = config.sops.secrets.GRADIENT_CACHE_SIGNING_KEY.path;
            projects = ["andrewix"];
            # Tailnet is the access boundary, so no netrc on clients. Fall back
            # to a private cache + /etc/nix/netrc if pulls ever answer 401.
            public = true;
            # Disk guard: six host closures on the GL552VX's SSD.
            max_storage_gb = 30;
          };

          tasks.hosts = {
            project = "andrewix";
            created_by = "andrew";
            repository = "https://github.com/hoanhxlyn/andrewix";
            # Every host closure (WSL included): built once, substituted everywhere.
            wildcard = "nixosConfigurations.*.config.system.build.toplevel";
            triggers = [
              {
                type = "polling";
                config = {interval_secs = 300;};
              }
            ];
          };
        };
      };

      services.postgresql.package = pkgs.postgresql_18;

      # The module's nginx vhost fronts the UI/API/cache; serve it all on 1998
      # instead of 80, tailnet-only like sshd in the homelab aspect.
      services.nginx.virtualHosts."andrewix".listen = [
        {
          addr = "0.0.0.0";
          port = 1998;
        }
      ];
      networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [1998];
    };
  };
}
