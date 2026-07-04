{
  core.cli.node = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        nodejs_latest
        # nodejs_22
        # pnpm
      ];
      programs.bun.enable = true;
    };
  };
}
