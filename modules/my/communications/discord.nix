{__findFile, ...}: {
  den.aspects.my.communications.discord = {
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
