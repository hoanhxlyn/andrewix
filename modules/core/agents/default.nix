{
  __findFile,
  self,
  ...
}: {
  core.agents = {
    includes = [
      <core.agents.opencode>
      <core.agents.commandcode>
      <core.agents.claude>
    ];
    homeManager = {
      config,
      pkgs,
      lib,
      ...
    }: {
      programs.mcp.enable = true;
      programs.mcp.servers = {
        context7.enabled = true;
        context7.url = "https://mcp.context7.com/mcp";
        context7.headers.CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}";
        deepwiki.url = "https://mcp.deepwiki.com/mcp";
        serena.enabled = true;
        serena.command = "${config.home.homeDirectory}/.local/bin/serena";
        serena.args = [
          "start-mcp-server"
          "--context"
          "ide"
          "--project-from-cwd"
          "--open-web-dashboard"
          "false"
        ];
      };
      programs.antigravity-cli.enable = false;
      programs.antigravity-cli.enableMcpIntegration = true;

      home.activation.uvTools = let
        uv = lib.getExe' pkgs.uv "uv";
      in
        lib.hm.dag.entryAfter ["writeBoundary"] ''
          # NOTE: `uv tool install` ignores a package's requires-python and picks the newest
          # managed interpreter, so PyO3-based deps (pyo3 caps at 3.14) fail to build on 3.15.
          for tool in $(cat "${self}/config/uv/plugins.txt"); do
            ${uv} tool list | grep -q "^$tool " || ${uv} tool install --python '>=3.11,<3.15' "$tool"
          done
        '';
    };
  };
}
