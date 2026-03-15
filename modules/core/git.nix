{
  core.git = {settings, ...}: {
    homeManager = {pkgs, ...}: {
      programs = {
        gh = {
          enable = true;
          gitCredentialHelper = {
            enable = true;
            hosts = [
              "https://github.com"
              "https://gist.github.com"
            ];
          };
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

            # Explicitly use 'gh' for GitHub/Gist hosts
            "credential \"https://github.com\"".helper = "!${pkgs.gh}/bin/gh auth git-credential";
            "credential \"https://gist.github.com\"".helper = "!${pkgs.gh}/bin/gh auth git-credential";
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
      home.packages = [pkgs.git-credential-manager];
    };
  };
}
