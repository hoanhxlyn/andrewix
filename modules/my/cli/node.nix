{
  den.aspects.my.cli.node = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        nodejs-slim_latest
        # nodejs_22
        # pnpm
      ];
      programs.bun.enable = true;
    };
  };
}
