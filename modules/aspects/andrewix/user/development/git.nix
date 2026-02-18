{lib, ...}: {
  programs = {
    git = {
      enable = lib.mkDefault true;
      settings = {
        user.email = "hoanhxlyn@gmail.com";
        user.name = "Andrew Nguyen";
      };
    };
    gh = {
      enable = lib.mkDefault true;
      gitCredentialHelper.enable = true;
      settings = {
        editor = "nvim";
      };
    };
    lazygit = {
      enable = lib.mkDefault true;
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
      enable = lib.mkDefault true;
      git.enable = true;
      git.diffToolMode = true;
    };
  };
}
