# Base settings shared by all hosts: UI, profiles (users), default browser.
{
  terminal = {
    fontSize = 12;
    padding = 2;
    opacity = 1.0;
    name = "kitty";
    shell = "fish";
    mux = "herdr";
  };
  toast = {
    width = 400;
    border = {
      radius = 12;
      size = 2;
    };
    layer = "top";
    position = "bottom-right";
    timeout = 3000;
    history = 10;
    offset = {
      x = 2;
      y = 5;
    };
    padding = {
      x = 5;
      y = 8;
    };
  };
  defaultBrowser = "zen";
  profiles.andrew = {};
  login = "ly";
  backgroundImage = {gruvbox = "wallpapers/anime/anime_skull.png";};
}
