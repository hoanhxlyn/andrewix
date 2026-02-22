{__findFile, ...}: {
  andrew.communications.provides.discord = {
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
    homeManager = {pkgs, ...}: {
      programs.discord = {
        enable = true;
        settings.SKIP_HOST_UPDATE = true;
      };
    };
  };
}
