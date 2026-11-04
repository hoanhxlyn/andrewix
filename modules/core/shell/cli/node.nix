{
  core.cli.node = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        nodejs_latest
        # nodejs
        # nodejs_22
        # pnpm
      ];
      programs.bun.enable = true;
    };
  };
}
