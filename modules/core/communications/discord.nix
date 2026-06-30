{__findFile, ...}: {
  core.communications.discord = {
    includes = [
      (<den.batteries.unfree> [
        "discord"
      ])
    ];
    homeManager = {
      programs.discord = {
        enable = true;
        settings.SKIP_HOST_UPDATE = true;
      };
    };
  };
}
