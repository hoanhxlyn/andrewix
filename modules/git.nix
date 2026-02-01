{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.email = "babybangunny@gmail.com";
      user.name = "Andrew Nguyen";
    };
  };
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      editor = "nvim";
    };
    hosts = {
      "github.com" = {
        user = "kurumeii";
      };
    };
  };
  programs.lazygit = {
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

  programs.difftastic = {
    enable = true;
    git.enable = true;
    git.diffToolMode = true;
  };
}
