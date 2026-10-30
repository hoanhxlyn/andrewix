{
  inputs,
  self,
  lib,
  ...
}: {
  flake-file.inputs.opencode = {
    url = "github:anomalyco/opencode/v2";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  core.agents.opencode.homeManager = {
    config,
    pkgs,
    osConfig,
    ...
  }: let
    isWsl = osConfig.wsl.enable or false;
    colors = config.lib.stylix.colors.withHashtag;
    opencodePkgs = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    home.file.".config/opencode/cli.json".source = "${self}/config/opencode/cli.json";
    home.file.".config/opencode/commands/gh.md".source = "${self}/config/opencode/gh.md";

    programs.opencode = {
      enable = true;
      # TODO: stylix still targets OpenCode 1's tui.json (ignored by v2 + warns);
      # drop this mkForce when stylix migrates to programs.opencode.cli
      tui = lib.mkForce {};
      package =
        if isWsl
        then null
        else opencodePkgs.opencode;
      enableMcpIntegration = true;
      web.enable = !isWsl;
      settings = {
        update = "disable";
        websearch.provider = "exa";
        plugins = ["@dietrichgebert/ponytail"];
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
        default_agent = "plan";
        # agents = {
        #   plan = {
        #     color = colors.base0E;
        #     model = "opencode-go/glm-5.3-flash";
        #   };
        #   build = {
        #     color = colors.base0B;
        #     model = "opencode-go/deepseek-v4.1-flash";
        #   };
        # };
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
