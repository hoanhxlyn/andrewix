{
  andrew.communications.provides.discord.nixos = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.discord
    ];
  };
}
