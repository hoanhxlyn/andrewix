{
  core.git = {
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
        settings = {
          user.email = "hoanhxlyn@gmail.com";
          user.name = "Andrew Nguyen";
          core.editor = "nvim";
        };
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
      home.packages = [pkgs.git-credential-manager];
    };
  };
}
