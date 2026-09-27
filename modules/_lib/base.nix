# Base settings shared by all hosts: UI, profiles (users), default browser.
{
  terminal = {
    fontSize = 12;
    padding = 2;
    opacity = 1.0;
    name = "foot";
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
  # First-boot password (fresh installs + `just vm`); existing machines keep
  # their mutable /etc/shadow password. Change after install with: passwd
  initialPassword = "admin123";
  login = "ly";
  backgroundImage = {
    url = "https://gruvbox-wallpapers.pages.dev/wallpapers/minimalistic/gruvbox_minimal_space.png";
    sha256 = "08qg1yjahg1r9hmzzcb5fgrgq2gaxcvx3frjxfb22wsi6bzl5qys";
  };
}
