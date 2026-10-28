{__findFile, ...}: {
  core.agents = {
    includes = [
      <core.agents.opencode>
      <core.agents.commandcode>
      <core.agents.claude>
    ];
    homeManager = {
      programs.mcp.enable = true;
      programs.mcp.servers = {
        context7.enabled = true;
        context7.url = "https://mcp.context7.com/mcp";
        context7.headers.CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}";
        deepwiki.url = "https://mcp.deepwiki.com/mcp";
        # exa.enabled = true;
        # exa.url = "https://mcp.exa.ai/mcp";
        # exa.headers."x-api-key" = "{env:EXA_API_KEY}";
      };
      programs.antigravity-cli.enable = false;
      programs.antigravity-cli.enableMcpIntegration = true;
    };
  };
}
