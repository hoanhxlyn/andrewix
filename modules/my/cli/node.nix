{
  den.aspects.my.cli.node = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        nodejs_22
        pnpm
      ];
      programs.bun.enable = true;
    };
  };
}
