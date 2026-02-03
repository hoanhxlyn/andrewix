{
  core.git.lazygit.homeManager = {
    programs.lazygit = {
      enable = true;
      settings = {
        git = {
          fetchAll = true;
          diffRenderers = [
            {
              type = "extDiff";
              command = "difft --color=always --display=inline";
            }
          ];
        };
        gui = {
          nerdFontsVersion = "3";
          showBranchCommitHash = true;
          showCommandLog = true;
          commitHashLength = 0;
          spinner = {
            frames = ["⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"];
            rate = 120;
          };
        };
      };
    };
  };
}
