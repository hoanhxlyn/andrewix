{
  core.git = gitCfg: {
    nixos.programs = {
      git = {
        enable = true;
        settings = gitCfg.settings;
      };
      gh = {
        enable = true;
        gitCredentialHelper.enable = true;
      };
      lazygit = {
        enable = true;
        settings = {
          git = {
            pagers = [
              {
                externalDiffCommand = "difft --color=always --display=inline";
              }
            ];
          };
          gui = {
            nerdFontsVersion = "3";
            showBranchCommitHash = true;
            showCommandLog = true;
            spinner = {
              frames = [
                "⠋"
                "⠙"
                "⠹"
                "⠸"
                "⠼"
                "⠴"
                "⠦"
                "⠧"
                "⠇"
                "⠏"
              ];
              rate = 120;
            };
          };
        };
      };
      difftastic = {
        enable = true;
        git.enable = true;
        git.diffToolMode = true;
      };
    };
  };
}
