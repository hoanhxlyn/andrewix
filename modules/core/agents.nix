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
              url = "https://mcp.context7.com/mcp";
              headers.CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}";
            };
            tavily = {
              command = "bunx";
              args = [
                "tavily-mcp@latest"
              ];
              env.TAVILY_API_KEY = "{env:TAVILY_API_KEY}";
            };
            deepwiki = {
              command = "pnpm";
              args = [
                "dlx"
                "mcp-deepwiki@latest"
              ];
            };
          };
        };
        opencode = {
          enable = true;
          enableMcpIntegration = true;
          settings = {
            username = "😺 Andrew Nguyen";
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
            plugin = [
              "opencode-agent-skills"
            ];
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
