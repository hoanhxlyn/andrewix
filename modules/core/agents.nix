{
  core.agents.homeManager = {pkgs, ...}: {
    programs = {
      uv.enable = true;
      mcp = {
        enable = true;
        servers = {
          context7 = {
            command = "pnpm";
            args = [
              "dlx"
              "@upstash/context7-mcp"
            ];
            env = {
              "CONTEXT7_API_KEY" = "{env:CONTEXT_7_API_KEY}";
            };
          };
          tavily = {
            command = "pnpm";
            args = [
              "dlx"
              "tavily-mcp@latest"
            ];
            env = {
              TAVILY_API_KEY = "{env:TAVILY_API_KEY}";
            };
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
          permission = {
            list = "deny";
            grep = "deny";
            glob = "deny";
          };
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
    };
  };
}
