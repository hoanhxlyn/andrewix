{__findFile, ...}: {
  core.agents = {
    includes = [
      <core.agents.opencode>
      <core.agents.commandcode>
      <core.agents.claude>
    ];
    homeManager = {config, ...}: {
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
              enabled = false;
              command = "bunx";
              args = ["@brave/brave-search-mcp-server"];
              env.BRAVE_API_KEY.file = config.sops.secrets.BRAVE_API_KEY.path;
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
