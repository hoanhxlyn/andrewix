{self, ...}: {
  core.agents.opencode.homeManager = {
    pkgs,
    lib,
    osConfig,
    ...
  }: let
    isWsl = osConfig.wsl.enable or false;
  in {
    home.file.".config/opencode/commands/gh.md".source = "${self}/config/opencode/gh.md";

    home.activation.opencodeCliSeed = lib.hm.dag.entryAfter ["linkGeneration"] ''
      if [ ! -e "$HOME/.config/opencode/cli.json" ]; then
        run ${pkgs.coreutils}/bin/install -Dm600 ${self}/config/opencode/cli.json \
          "$HOME/.config/opencode/cli.json"
      fi
    '';

    programs.opencode = {
      enable = !isWsl;
      # TODO: drop when nixpkgs-unstable carries NixOS/nixpkgs@c399e1b7fb (opencode: fix hash)
      package = pkgs.opencode.overrideAttrs (old: {
        node_modules = old.node_modules.overrideAttrs {
          outputHash = "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=";
        };
      });
      # TODO: stylix still targets OpenCode 1's tui.json (ignored by v2 + warns);
      # drop this mkForce when stylix migrates to programs.opencode.cli
      tui = lib.mkForce {};
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
