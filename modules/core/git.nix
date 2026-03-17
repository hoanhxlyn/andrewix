{
  core.git = {settings, ...}: {
    homeManager = {pkgs, ...}: {
      programs = {
        gh = {
          enable = true;
          gitCredentialHelper.enable = false;
        };
        difftastic = {
          enable = true;
          git.enable = true;
          git.diffToolMode = true;
        };
        git = {
          enable = true;
          inherit settings;
          extraConfig = {
            # Use GCM as the default (handles GitLab, etc.)
            credential.helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
            credential.credentialStore = "secretservice";
            credential.guiOptions = "askpass";
            credential.askPass = "${pkgs.gnome-askpass-bearer}/bin/gnome-askpass-bearer";
          };
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
      home.packages = with pkgs; [
        git-credential-manager
        gnome-askpass-bearer
      ];
    };
  };
}
