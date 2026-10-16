{
  core.git.config.homeManager = {
    programs.git = {
      enable = true;
      settings = {
        user.email = "hoanhxlyn@gmail.com";
        user.name = "Andrew Nguyen";
        init.defaultBranch = "main";
        fetch.prune = true;
        fetch.pruneTags = true;
        core.editor = "nvim";
      };
    };
  };
}
