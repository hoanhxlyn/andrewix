# Shared host settings (DE-style sections). Per-host overrides go through mkHost; hardware facts
# live in facts.nix.
{
  terminal = {
    padding = 2;
    mux = "herdr";
  };
  locale = {
    lang = "en_US.UTF-8";
    # numbers, money, paper, address, name, phone, measurement, identification
    formats = "vi_VN.UTF-8";
    time = "en_US.UTF-8";
  };
  # Default applications
  defaults = {
    browser = "zen";
    terminal = "kitty";
    shell = "fish";
  };
  profiles.andrew = {};
  login = "ly";
  input = {
    keyboard = {
      layout = "us";
      repeatDelay = 250; # ms before repeat starts
      repeatRate = 50; # keys per second
    };
    touchpad = {
      tap = true;
      naturalScroll = true;
      disableWhileTyping = true;
    };
    mouse.accelProfile = "flat"; # flat | adaptive
  };
  accessibility = {
    cursorSize = 24;
    hideCursorWhenTyping = true;
    animations = {
      enable = true;
      slowdown = 1.5; # >1 = slower
    };
  };
  # Look & feel (pure data; packages stay in modules/core/services/sync/stylix.nix).
  appearance = {
    scheme = "gruvbox-dark-medium"; # base16-schemes name
    polarity = "dark"; # light | dark
    font.size = 12; # pt; terminal/applications/desktop derive from it
    opacity = 1.0; # 1.0 = opaque; <1 enables blur/transparent bg
    wallpaper = {
      # local (config/background/<path>) | gruvbox (AngelJumbo/gruvbox-wallpapers, <path> in repo)
      # | remote ({url, hash} instead of path)
      source = "gruvbox";
      path = "wallpapers/anime/anime_skull.png";
      scaling = "center"; # fill | center | stretch | fit
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
  };
}
