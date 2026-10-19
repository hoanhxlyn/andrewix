{
  core.git.config.homeManager = {user, ...}: {
    programs.git = {
      enable = true;
      settings = {
        user = {inherit (user.git) name email;};
        init.defaultBranch = "main";
        fetch.prune = true;
        fetch.pruneTags = true;
        core.editor = "nvim";
      };
    };
  };
}
