{inputs, ...}: {
  flake-file.inputs.opencode = {
    url = "github:sst/opencode/v2";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  core.agents.opencode.homeManager = {
    pkgs,
    osConfig,
    ...
  }: {
    home.packages =
      if (osConfig.wsl.enable or false)
      then []
      else [inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.opencode-desktop];

    programs.opencode = {
      enable = true;
      package =
        if (osConfig.wsl.enable or false)
        then null
        else inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
      enableMcpIntegration = true;
      web.enable = !(osConfig.wsl.enable or false);
      settings = {
        update = "disable";
        plugins = [
          "@dietrichgebert/ponytail"
        ];
        formatter = {
          nixfmt = {
            disabled = true;
          };
          alejandra = {
            command = [
              "alejandra"
              "$FILE"
            ];
            extensions = [".nix"];
          };
        };
        permissions = [
          {
            action = "shell";
            resource = "*";
            effect = "ask";
          }
          {
            action = "shell";
            resource = "git *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "bun *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "bunx *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "npm *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "grep *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "rg *";
            effect = "allow";
          }
          {
            action = "edit";
            resource = "*";
            effect = "ask";
          }
          {
            action = "external_directory";
            resource = "~/Projects/*";
            effect = "allow";
          }
          {
            action = "external_directory";
            resource = "~/.config/*";
            effect = "allow";
          }
          {
            action = "external_directory";
            resource = "~/.cache/*";
            effect = "allow";
          }
          {
            action = "external_directory";
            resource = "~/.local/*";
            effect = "allow";
          }
          {
            action = "external_directory";
            resource = "/nix/store/*";
            effect = "allow";
          }
        ];
      };
    };
  };
}
