{
  inputs,
  self,
  ...
}: {
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  core.services.sync.sops.homeManager = {config, ...}: let
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
        CLAUDE_CODE_OAUTH_TOKEN.path = secrets "CLAUDE_CODE_OAUTH_TOKEN";
        EXA_API_KEY.path = secrets "EXA_API_KEY";
        RCLONE_DRIVE_CLIENT_ID.path = secrets "RCLONE_DRIVE_CLIENT_ID";
        RCLONE_DRIVE_CLIENT_SECRET.path = secrets "RCLONE_DRIVE_CLIENT_SECRET";
      };
      templates.rclone-env = {
        mode = "0600";
        path = "${config.home.homeDirectory}/.config/sops-nix/rclone-env";
        content = ''
          RCLONE_DRIVE_CLIENT_ID=${config.sops.placeholder.RCLONE_DRIVE_CLIENT_ID}
          RCLONE_DRIVE_CLIENT_SECRET=${config.sops.placeholder.RCLONE_DRIVE_CLIENT_SECRET}
        '';
      };
    };
  };
}
