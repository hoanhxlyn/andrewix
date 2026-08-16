{__findFile, ...}: {
  core.communications.discord = {
    includes = [
      (<den.batteries.unfree> [
        "discord"
        "discord-unwrapped"
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
