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

      # Gradient's prebuilt packages (Rust server): substitute instead of
      # compiling, same pattern as niri/herdr caches. The second substituter is
      # this host's own cache, so a post-GC `just switch` here substitutes the
      # closure instead of rebuilding it.
      nix.settings.extra-substituters = [
        "https://public.gradient.ci/cache/main"
        "http://127.0.0.1:1998/cache/andrewix"
      ];
      nix.settings.extra-trusted-public-keys = [
        "public.gradient.ci-main:qmxRE+saUvhNa3jqaCMWje+feVU77TjABchZrPGf7A8="
        "andrewix-andrewix:rRaDERFJTlZDBSBQ1yElSatGbEu9TDhOBMCM1/o3PZA="
      ];

      services.gradient = {
        enable = true;
        # Tailnet-only: bare MagicDNS name resolved through the tailnet's search
        # domain, plaintext inside WireGuard, everything on 1998.
        domain = "andrewix";
        serveUrl = "http://andrewix:1998";
        useTls = false;

        # NAR store on the idle HDD; the SSD keeps only /nix/store and the DB.
        baseDir = "/data/gradient";

        secrets.jwtFile = config.sops.secrets.GRADIENT_SECRETS_JWT.path;
        secrets.cryptFile = config.sops.secrets.GRADIENT_SECRETS_CRYPT.path;

        postgres.enable = true;
        # Self-registering local worker; the module joins it to team "server",
        # which every project gets for its workers. nix-daemon caps real
        # parallelism at max-jobs (4) x cores (2) = 8, so dispatching more only
        # piles up queue and log noise.
        worker.enable = true;
        worker.build.maxConcurrent = 8;

        state = {
          users.andrew.email = "hoanhxlyn@users.noreply.github.com";
          users.andrew.superuser = true;
          users.andrew.password_file = config.sops.secrets.GRADIENT_USER_PASSWORD_HASH.path;

          projects.andrewix.created_by = "andrew";
          projects.andrewix.private_key_file = config.sops.secrets.GRADIENT_PROJECT_SSH_KEY.path;
          projects.andrewix.teams = [
            {
              team = "server";
              users = false;
              workers = true;
            }
          ];

          caches.andrewix = {
            created_by = "andrew";
            signing_key_file = config.sops.secrets.GRADIENT_CACHE_SIGNING_KEY.path;
            projects = ["andrewix"];
            # Tailnet is the access boundary, so no netrc on clients. Fall back
            # to a private cache + /etc/nix/netrc if pulls ever answer 401.
            public = true;
            # Disk guard: three built closures on the 1 TB HDD's /data.
            max_storage_gb = 700;
          };

          tasks.hosts = {
            project = "andrewix";
            created_by = "andrew";
            repository = "https://github.com/hoanhxlyn/andrewix";
            # Workstation closures only: WSL hosts have no disk layout and the
            # installer ISO is not a machine, so nothing ever substitutes them.
            wildcard =
              "nixosConfigurations.*.config.system.build.toplevel"
              + ",!nixosConfigurations.home-wsl.config.system.build.toplevel"
              + ",!nixosConfigurations.work-wsl.config.system.build.toplevel"
              + ",!nixosConfigurations.iso.config.system.build.toplevel";
            triggers = [
              {
                type = "polling";
                config.interval_secs = 300;
              }
            ];
          };
        };
      };

      # NAR store disk (`sdb`): bulk, write-once, read-rarely data has no place
      # on the 214 GB SSD. Label-based so a reinstall that leaves `sdb` alone
      # picks it up again; `nofail` keeps boot working if the disk dies.
      fileSystems."/data".device = "/dev/disk/by-label/gradient";
      fileSystems."/data".fsType = "xfs";
      fileSystems."/data".options = ["nofail"];
      systemd.tmpfiles.rules = ["d /data/gradient 0750 gradient gradient -"];

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
