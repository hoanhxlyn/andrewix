{
  __findFile,
  inputs,
  lib,
  self,
  ...
}: {
  flake-file.inputs.opencode = {
    url = lib.mkDefault "github:anomalyco/opencode";
    inputs.nixpkgs.follows = lib.mkDefault "nixpkgs";
  };

  core.agents = {
    includes = [
      (<den/batteries/unfree> ["claude-code" "antigravity-cli"])
    ];
    homeManager = {
      pkgs,
      config,
      osConfig,
      ...
    }: {
      home.packages = with pkgs; [claude-code];
      programs = {
        mcp = {
          enable = true;
          servers = {
            context7 = {
              command = "bunx";
              args = ["@upstash/context7-mcp@latest"];
            };
            exa = {
              command = "bunx";
              args = ["exa-mcp-server"];
              env.EXA_API_KEY.file = config.sops.secrets.EXA_API_KEY.path;
            };
            deepwiki.url = "https://mcp.deepwiki.com/mcp";
            brave = {
              enable = false;
              command = "bunx";
              args = ["@brave/brave-search-mcp-server"];
              env.BRAVE_API_KEY.file = config.sops.secrets.BRAVE_API_KEY.path;
            };
          };
        };
        opencode = {
          enable = true;
          package =
            if (osConfig.wsl.enable or false)
            then null
            else inputs.opencode.packages.${pkgs.system}.opencode;
          enableMcpIntegration = true;
          web.enable = !(osConfig.wsl.enable or false);
          settings = {
            autoupdate = false;
            plugin = [
              "@dietrichgebert/ponytail"
            ];
            lsp = {
              nix = {
                command = ["nil"];
                extensions = [".nix"];
              };
            };
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
            permission = {
              edit = "ask";
              bask = {
                "*" = "ask";
                "git *" = "allow";
                "bun *" = "allow";
                "bunx *" = "allow";
                "npm *" = "allow";
                "grep *" = "allow";
                "rg *" = "allow";
              };
              write = "ask";
              external_directory = {
                "~/Projects/**" = "allow";
                "~/.config/**" = "allow";
                "~/.cache/**" = "allow";
                "~/.local/**" = "allow";
                "/nix/store/**" = "allow";
              };
            };
            command = {
              commit = {
                description = "Auto generate commit message";
                template = "Generate a git convention message for changes. DO NOT commit them !";
              };
            };
          };
        };
        claude-code = {
          enable = false;
          enableMcpIntegration = true;
          commands = {
            commit = "Generate a git convention message for changes. DO NOT commit them!";
          };
          settings = {
            hooks = {
              PostToolUse = [
                {
                  matcher = "Edit|Write";
                  hooks = [
                    {
                      type = "command";
                      command = toString (pkgs.writeShellScript "claude-alejandra-hook" ''
                        input=$(cat)
                        file=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.tool_input.file_path // empty')
                        [[ "$file" == *.nix ]] && ${pkgs.alejandra}/bin/alejandra "$file" 2>/dev/null
                        exit 0
                      '');
                    }
                  ];
                }
              ];
            };
            model = "sonnet";
            effortLevel = "high";
            theme = "auto";
            attribution = {
              commit = "";
            };
            permissions = {
              allow = [
                "Bash(~/Projects/**)"
                "Read(~/Projects/**)"
                "Edit(~/Projects/**)"
                "Write(~/Projects/**)"
                "Read(~/.config/**)"
                "Edit(~/.config/**)"
                "Write(~/.config/**)"
                "Read(~/.cache/**)"
              ];
            };
            statusLine = {
              type = "command";
              command = pkgs.writeShellScript "claude-statusline" ''
                export PATH=${lib.makeBinPath [pkgs.coreutils pkgs.jq pkgs.git]}:$PATH
                exec ${pkgs.bash}/bin/bash ${self}/config/claude/statusline.sh
              '';
            };
          };
        };
        antigravity-cli = {
          enable = false;
          enableMcpIntegration = true;
        };
      };
      home.activation.installOpencode = lib.mkIf (osConfig.wsl.enable or false) ''
        if ! command -v opencode &>/dev/null; then
          ${pkgs.bun}/bin/bun add -g opencode-ai
        fi
      '';
    };
  };
}
