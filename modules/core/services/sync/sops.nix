{
  inputs,
  self,
  ...
}: {
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  core.services.sync.sops = {
    # System-level secrets, for NixOS services (atticd, tailscaled).
    nixos = {user, ...}: {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];
      sops = {
        defaultSopsFile = "${self}/secrets/secrets.yaml";
        defaultSopsFormat = "yaml";
        # Same shared age key the home-manager side uses (see AGENTS.md); it
        # must be present before sops-nix runs or these services fail to start.
        age.keyFile = "/home/${user.userName}/.config/sops-nix/keys.txt";
        secrets = {
          ATTIC_SERVER_TOKEN_HS256_SECRET_BASE64 = {};
          TAILSCALE_AUTH_KEY = {};
        };
      };
    };

    homeManager = {config, ...}: let
      keyFile = "${config.home.homeDirectory}/.config/sops-nix/keys.txt";
      secrets = name: "${config.home.homeDirectory}/.config/sops-nix/secrets/${name}";
    in {
      imports = [
        inputs.sops-nix.homeManagerModules.sops
      ];
      sops = {
        defaultSopsFile = "${self}/secrets/secrets.yaml";
        defaultSopsFormat = "yaml";
        age = {
          inherit keyFile;
          generateKey = true;
        };
        secrets = {
          CONTEXT7_API_KEY.path = secrets "CONTEXT7_API_KEY";
          BRAVE_API_KEY.path = secrets "BRAVE_API_KEY";
          EXA_API_KEY.path = secrets "EXA_API_KEY";
          TAVILY_API_KEY.path = secrets "TAVILY_API_KEY";
          RCLONE_DRIVE_CLIENT_ID.path = secrets "RCLONE_DRIVE_CLIENT_ID";
          RCLONE_DRIVE_CLIENT_SECRET.path = secrets "RCLONE_DRIVE_CLIENT_SECRET";
        };
      };
    };
  };
}
