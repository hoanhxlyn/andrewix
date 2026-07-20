{__findFile, ...}: {
  core.cli.tui = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [sqlit-tui bruno];
      programs.dbeaver.enable = true;
      # xdg.configFile."YouTube Music/config.json".force = true;
      # xdg.configFile."YouTube Music/config.json".source = "${self}/config/youtube-music/config.json";
    };
  };
}
