{__findFile, ...}: {
  core.agents = {
    includes = [
      <core.agents.opencode>
      <core.agents.commandcode>
      <core.agents.claude>
    ];
    homeManager = {
      programs = {
        mcp = {
          enable = true;
          servers = {
            context7 = {
              enabled = true;
              url = "https://mcp.context7.com/mcp";
              headers.CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}";
            };
            deepwiki.url = "https://mcp.deepwiki.com/mcp";
            exa = {
              enabled = true;
              url = "https://mcp.exa.ai/mcp";
              headers."x-api-key" = "{env:EXA_API_KEY}";
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
