{
  inputs,
  self,
  ...
}: {
  flake-file.inputs.opencode = {
    url = "github:anomalyco/opencode/v2";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  core.agents.opencode.homeManager = {
    pkgs,
    osConfig,
    ...
  }: let
    isWsl = osConfig.wsl.enable or false;
    opencodePkgs = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    # cli.json is the V2 TUI config; home-manager has no option for it.
    # Read-only while symlinked: rm the link before tweaking from the TUI.
    home.file.".config/opencode/cli.json".source = "${self}/config/opencode/cli.json";

    programs.opencode = {
      enable = true;
      package =
        if isWsl
        then null
        else opencodePkgs.opencode;
      enableMcpIntegration = true;
      web.enable = !isWsl;
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
        websearch = false;
        default_agent = "chat";
        agents = {
          plan = {
            model = "opencode-go/deepseek-v4-pro";
            request.body.temperature = 0.3;
          };
          build = {
            model = "opencode-go/deepseek-v4.1-flash#low";
            request.body.temperature = 0.3;
          };
          chat = {
            description = "Daily chatting with heads in the cloud";
            mode = "primary";
            model = "opencode-go/minimax-m3";
            request.body.temperature = 0.8;
            permissions = [
              {
                action = "edit";
                resource = "*";
                effect = "deny";
              }
              {
                action = "shell";
                resource = "*";
                effect = "deny";
              }
            ];
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
            action = "webfetch";
            resource = "*";
            effect = "deny";
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
