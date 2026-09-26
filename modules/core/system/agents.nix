{
  inputs,
  self,
  ...
}: {
  core.agents = {
    # includes = [
    #   (<den/batteries/unfree> ["antigravity-cli"])
    # ];
    homeManager = {
      pkgs,
      config,
      lib,
      osConfig,
      ...
    }: let
      jsonFormat = pkgs.formats.json {};

      toCommandCodeMcp = name: server:
        lib.hm.mcp.transformMcpServer {
          inherit server;
          extraTransforms = [
            (lib.hm.mcp.wrapEnvFilesCommand {inherit pkgs name;})
            (s: let
              isRemote = (s.url or null) != null;
            in
              {
                transport =
                  if isRemote
                  then "http"
                  else "stdio";
                enabled = s.enabled != false;
              }
              // (
                if isRemote
                then {inherit (s) url headers;}
                else {inherit (s) command args env;}
              ))
          ];
        };
    in {
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
        opencode = {
          enable = false;
          package =
            if (osConfig.wsl.enable or false)
            then null
            else inputs.opencode.packages.${pkgs.system}.opencode;
          enableMcpIntegration = true;
          web.enable = !(osConfig.wsl.enable or false);
          settings = {
            autoupdate = false;
            plugin = [
              "@dietrichgebert/ponytail"
            ];
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
            permission = {
              edit = "ask";
              bask = {
                "*" = "ask";
                "git *" = "allow";
                "bun *" = "allow";
                "bunx *" = "allow";
                "npm *" = "allow";
                "grep *" = "allow";
                "rg *" = "allow";
              };
              write = "ask";
              external_directory = {
                "~/Projects/**" = "allow";
                "~/.config/**" = "allow";
                "~/.cache/**" = "allow";
                "~/.local/**" = "allow";
                "/nix/store/**" = "allow";
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
        antigravity-cli = {
          enable = false;
          enableMcpIntegration = true;
        };
      };
      home = {
        activation.installCommandCode = "${lib.getExe pkgs.fish} ${self}/config/command-code/install.fish";
        file.".commandcode/mcp.json".source = jsonFormat.generate "commandcode-mcp.json" {
          mcpServers = lib.mapAttrs toCommandCodeMcp config.programs.mcp.servers;
        };
      };
    };
  };
}
