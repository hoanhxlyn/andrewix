{__findFile, ...}: {
  core.agents = {
    includes = [
      (<den/batteries/unfree> ["claude-code"])
    ];
    homeManager = {
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
            };
            deepwiki.url = "https://mcp.deepwiki.com/mcp";
          };
        };
        opencode = {
          enable = true;
          enableMcpIntegration = true;
          settings = {
            autoupdate = false;
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
        };
      };
    };
  };
}
