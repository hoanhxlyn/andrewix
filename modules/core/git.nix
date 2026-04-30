{
  core.git = {
    includes = [
      ({host, ...}:
        if host.wsl.enable
        then {
          homeManager.programs.gh = {
            enable = true;
            gitCredentialHelper.enable = true;
          };
        }
        else {
          nixos = {pkgs, ...}: {
            environment.systemPackages = [pkgs.git-credential-manager];
          };
          homeManager = {pkgs, ...}: {
            programs = {
              gh.enable = false;
              difftastic = {
                enable = true;
                git.enable = true;
                git.diffToolMode = true;
              };
              git.settings.credential.credentialStore = "secretservice";
            };
          };
        })
    ];
    homeManager = {pkgs, ...}: {
      programs = {
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
      };
    };
  };
}
