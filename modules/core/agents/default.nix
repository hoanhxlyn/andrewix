{__findFile, ...}: {
  core.agents = {
    includes = [
      <core.agents.opencode>
      <core.agents.commandcode>
      <core.agents.claude>
    ];
    homeManager = {config, ...}: let
      secrets = config.sops.secrets;
    in {
      programs = {
        mcp = {
          enable = true;
          servers = {
            context7 = {
              enabled = true;
              url = "https://mcp.context7.com/mcp";
              headers.CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}";
            };
            exa = {
              enabled = false;
              command = "bunx";
              args = ["exa-mcp-server"];
              env.EXA_API_KEY.file = secrets.EXA_API_KEY.path;
            };
            deepwiki.url = "https://mcp.deepwiki.com/mcp";
            brave = {
              enabled = false;
              command = "bunx";
              args = ["@brave/brave-search-mcp-server"];
              env.BRAVE_API_KEY.file = secrets.BRAVE_API_KEY.path;
            };
            tavily = {
              enabled = true;
              command = "bunx";
              args = ["tavily-mcp@latest"];
              env.TAVILY_API_KEY.file = secrets.TAVILY_API_KEY.path;
              env.DEFAULT_PARAMETERS = "{\"include_images\": true, \"max_results\": 10, \"search_depth\": \"advanced\"}";
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
