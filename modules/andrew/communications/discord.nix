{__findFile, ...}: {
  andrew.communications.provides.discord = {
    includes = [
      (<den/unfree> [
        "discord"
      ])
    ];
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.discord
      ];
    };
  };
}
