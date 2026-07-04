{__findFile, ...}: {
  core.agents = {
    includes = [
      (<den/batteries/unfree> ["claude-code" "antigravity-cli"])
    ];
    homeManager = {
      pkgs,
      config,
      ...
    }: {
      programs = {
        mcp = {
          enable = true;
          servers = {
            context7 = {
              command = "bunx";
              args = ["@upstash/context7-mcp@latest"];
            };
            tavily = {
              command = "bunx";
              args = ["tavily-mcp@latest"];
              env.TAVILY_API_KEY.file = config.sops.secrets.TAVILY_API_KEY.path;
            };
            deepwiki.url = "https://mcp.deepwiki.com/mcp";
            brave = {
              command = "bunx";
              args = ["@brave/brave-search-mcp-server"];

              env.BRAVE_API_KEY.file = config.sops.secrets.BRAVE_API_KEY.path;
            };
          };
        };
        opencode = {
          enable = true;
          enableMcpIntegration = true;
          web.enable = true;
          settings = {
            autoupdate = false;
            plugin = [
              "opencode-claude-auth@latest"
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
              external_directory = {
                "~/Projects/**" = "allow";
                "~/.config/**" = "allow";
                "~/.cache/**" = "allow";
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
          enable = true;
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
                input=$(cat)
                cwd=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.cwd // empty')
                folder=$(basename "$cwd")
                user=$(${pkgs.coreutils}/bin/whoami)

                git_branch=""
                git_status=""
                if ${pkgs.git}/bin/git -C "$cwd" rev-parse --is-inside-work-tree --no-optional-locks >/dev/null 2>&1; then
                  git_branch=$(${pkgs.git}/bin/git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
                               || ${pkgs.git}/bin/git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)

                  upstream=$(${pkgs.git}/bin/git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref "@{u}" 2>/dev/null)
                  if [ -n "$upstream" ]; then
                    ahead=$(${pkgs.git}/bin/git -C "$cwd" --no-optional-locks rev-list --count "@{u}..HEAD" 2>/dev/null || echo 0)
                    behind=$(${pkgs.git}/bin/git -C "$cwd" --no-optional-locks rev-list --count "HEAD..@{u}" 2>/dev/null || echo 0)
                    [ "$ahead"  -gt 0 ] && git_status="''${git_status} ↑''${ahead}"
                    [ "$behind" -gt 0 ] && git_status="''${git_status} ↓''${behind}"
                  fi

                  working=$(${pkgs.git}/bin/git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null | grep -c "^.[^ ]" || echo 0)
                  staging=$(${pkgs.git}/bin/git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null | grep -c "^[^ ]" || echo 0)
                  [ "$working" -gt 0 ] && git_status="''${git_status} ~''${working}"
                  [ "$staging" -gt 0 ] && git_status="''${git_status} +''${staging}"
                fi

                RED='\033[38;2;227;100;100m'
                GREEN='\033[38;2;98;237;139m'
                CYAN='\033[38;2;86;182;194m'
                PURPLE='\033[38;2;212;170;252m'
                RESET='\033[0m'

                out=""
                out="''${out}$(printf "''${RED}@%s''${RESET}" "$user")"
                out="''${out}$(printf " ''${GREEN}󱐋''${RESET}")"
                out="''${out}$(printf " ''${CYAN}%s''${RESET}" "$folder")"
                [ -n "$git_branch" ] && out="''${out}$(printf " ''${PURPLE}%s%s''${RESET}" "$git_branch" "$git_status")"

                printf '%b' "$out"
              '';
            };
          };
        };
        antigravity-cli = {
          enable = false;
          enableMcpIntegration = true;
        };
      };
    };
  };
}
