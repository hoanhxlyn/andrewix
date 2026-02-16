{
  config,
  lib,
  ...
}: let
  cfg = config.modules.development.git;
in {
  options.modules.development.git = {
    enable = lib.mkEnableOption "git and related tools";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      git = {
        enable = true;
        settings = {
          user.email = "hoanhxlyn@gmail.com";
          user.name = "Andrew Nguyen";
        };
      };
      gh = {
        enable = true;
        gitCredentialHelper.enable = true;
        settings = {
          editor = "nvim";
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
      difftastic = {
        enable = true;
        git.enable = true;
        git.diffToolMode = true;
      };
    };
  };
}
