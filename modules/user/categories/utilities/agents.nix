{
  pkgs,
  inputs,
  ...
}: {
  programs.mcp = {
    enable = true;
    servers = {
      serena = {
        url = "http://localhost:12345/mcp";
        timeout = 2000;
      };
      context7 = {
        command = "pnpm";
        args = [
          "dlx"
          "@upstash/context7-mcp"
        ];
        env = {
          api-key = "{env:CONTEXT_7_API_KEY}";
        };
      };
      tavily = {
        command = "pnpm";
        args = [
          "dlx"
          "tavily-mcp@latest"
        ];
        environment = {
          TAVILY_API_KEY = "{env:TAVILY_API_KEY}";
        };
      };
    };
  };
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      username = "😺 Andrew Nguyen";
      theme = "system";
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
        "opencode-gemini-auth@latest"
      ];
    };
  };

  home.packages = [
    inputs.serena.packages.${pkgs.stdenv.hostPlatform.system}.serena
    (pkgs.writeShellScriptBin "start-serena" ''
      # Kill any existing instances to avoid port conflicts
      pkill -f "serena start-mcp-server"

      # Start the server
      nohup serena start-mcp-server --transport streamable-http --port 12345 --context ide > /dev/null 2>&1 &

      # Give it a second to initialize
      sleep 2

      # Verify it is actually running
      PID=$(pgrep -f "serena start-mcp-server")

      if [ -z "$PID" ]; then
          echo "❌ Error: Server failed to start."
      else
          echo "✅ Serena MCP Server started successfully (PID: $PID)"
      fi
    '')
  ];
}
