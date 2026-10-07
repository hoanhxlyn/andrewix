{self, ...}: {
  core.agents.commandcode.homeManager = {
    pkgs,
    config,
    lib,
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
    home.file = {
      ".commandcode/mcp.json".source = jsonFormat.generate "commandcode-mcp.json" {
        mcpServers = lib.mapAttrs toCommandCodeMcp config.programs.mcp.servers;
      };
      ".commandcode/settings.json".source =
        jsonFormat.generate "commandcode-settings.json"
        (lib.importJSON "${self}/config/command-code/settings.json");
      ".commandcode/hooks/caveman.sh".source = "${self}/config/command-code/hooks/caveman.sh";
    };
  };
}
