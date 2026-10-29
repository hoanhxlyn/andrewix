{
  self,
  inputs,
  __findFile,
  ...
}: {
  core.agents.claude = {
    includes = [
      (<den/batteries/unfree> ["claude-code"])
    ];
    homeManager = {
      programs.claude-code = {
        enable = true;
        enableMcpIntegration = true;
        plugins.ponytail = inputs.ponytail;
        settings = {
          model = "sonnet";
          attribution.commit = "";
          # hooks = let
          #   ponytailHook = script: statusMessage: {
          #     hooks = [
          #       {
          #         type = "command";
          #         command = "${pkgs.nodejs}/bin/node ${inputs.ponytail}/hooks/${script}";
          #         timeout = 5;
          #         inherit statusMessage;
          #       }
          #     ];
          #   };
          # in {
          #   SessionStart = [
          #     (ponytailHook "ponytail-activate.js" "Loading ponytail mode..."
          #       // {matcher = "startup|resume|clear|compact";})
          #   ];
          #   SubagentStart = [(ponytailHook "ponytail-subagent.js" "Loading ponytail mode...")];
          #   UserPromptSubmit = [(ponytailHook "ponytail-mode-tracker.js" "Tracking ponytail mode...")];
          # };
          statusLine.type = "command";
          statusLine.command = "oh-my-posh claude --config ${self}/config/omp/claude.omp.json";
          statusLine.padding = 0;
        };
      };
    };
  };
}
