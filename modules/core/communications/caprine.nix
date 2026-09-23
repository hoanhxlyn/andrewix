{
  core.communications.caprine.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.caprine];
  };
}
