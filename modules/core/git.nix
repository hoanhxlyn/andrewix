{
  core.git = {settings, ...}: {
    homeManager.programs = {
      gh = {
        enable = true;
        gitCredentialHelper.enable = true;
      };
      difftastic = {
        enable = true;
        git.enable = true;
        git.diffToolMode = true;
      };
      git = {
        enable = true;
        inherit settings;
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
    };
  };
}
