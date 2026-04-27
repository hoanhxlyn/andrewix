{__findFile, ...}: {
  den.aspects.andrew._.communications._.discord = {
    includes = [
      (<den/unfree> [
        "discord"
      ])
    ];
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        discordo
      ];
    };
    homeManager = {
      programs.discord = {
        enable = true;
        settings.SKIP_HOST_UPDATE = true;
      };
    };
  };
}
