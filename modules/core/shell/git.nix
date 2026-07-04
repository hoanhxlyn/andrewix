{
  core.git = {host, ...}: {
    homeManager = {lib, ...}: {
      programs = {
        git-credential-keepassxc.enable = !host.wsl.enable;
        difftastic = {
          enable = true;
          git.enable = true;
          git.mode = "both";
        };
        git = {
          enable = true;
          settings = {
            user.email = "hoanhxlyn@gmail.com";
            user.name = "Andrew Nguyen";
            init.defaultBranch = "main";
            core.editor = "nvim";
            credential.helper = lib.mkIf host.wsl.enable "/mnt/c/Users/${host.windowsName}/scoop/root/apps/git/current/mingw64/bin/git-credential-manager.exe";
          };
        };
        lazygit = {
          enable = true;
          settings = {
            git = {
              pagers = [
                {externalDiffCommand = "difft --color=always --display=inline";}
              ];
            };
            gui = {
              nerdFontsVersion = "3";
              showBranchCommitHash = true;
              showCommandLog = true;
              spinner = {
                frames = ["⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"];
                rate = 120;
              };
            };
          };
        };
      };
    };
  };
}
