# Base settings shared by all hosts: UI, profiles (users), default browser.
{
  terminal = {
    fontSize = 12;
    padding = 2;
    opacity = 0.8;
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
    url = "https://images6.alphacoders.com/114/1140278.png";
    sha256 = "1vh4yw3wrhkc8y9fjvhrmydpy4fqyv2wzyyzr3qfby92if6drasi";
  };
}
