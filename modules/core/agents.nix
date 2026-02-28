{
  lib,
  inputs,
  ...
}: {
  flake-file.inputs.serena.url = "github:oraios/serena";

  core.agents.homeManager = {pkgs, ...}: {
    programs.uv.enable = true;
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
            "api-key" = "{env:CONTEXT_7_API_KEY}";
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
    # programs.gemini-cli = {
    #   enable = false;
    #   settings = {
    #     context = {
    #       fileName = ["AGENTS.md" "CONTEXT.md" "GEMINI.md"];
    #     };
    #     general = {
    #       preferredEditor = "neovim";
    #       vimMode = false;
    #       disableAutoUpdate = true;
    #       previewFeatures = true;
    #     };
    #     ui = {
    #       hideWindowTitle = false;
    #       hideTips = true;
    #       hideBanner = true;
    #       hideFooter = true;
    #       showMemoryUsage = false;
    #       showLineNumbers = true;
    #       showCitations = true;
    #       accessibility.disableLoadingPhrases = true;
    #       hideContextSummary = false;
    #       footer.hideCWD = true;
    #       footer.hideSandboxStatus = true;
    #       useFullWidth = true;
    #       useAlternateBuffer = true;
    #       showStatusInTitle = true;
    #       showModelInfoInChat = true;
    #     };
    #     tools = {
    #       shell.showColor = true;
    #       exclude = [
    #         "list_directory"
    #         "glob"
    #         "search_file_content"
    #         "web_fetch"
    #         "google_web_search"
    #       ];
    #     };
    #     security.auth.selectedType = "oauth-personal";
    #   };
    # };
    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;
      settings = {
        username = "😺 Andrew Nguyen";
        theme = lib.mkDefault "system";
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
            echo "🧨 Error: Server failed to start."
        else
            echo "🎉 Serena MCP Server started successfully (PID: $PID)"
        fi
      '')
    ];
  };
}
