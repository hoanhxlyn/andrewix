{
  username,
  stateVersion,
  ...
} @ inputs: {
  imports = [
    ./categories/development
    ./categories/desktop
    ./categories/utilities
  ];
  home = {
    # Do not override var here
    inherit username stateVersion;
    homeDirectory = "/home/${username}";
  };

  modules = {
    desktop = {
      yazi.enable = true;
      browsers.enable = true;
      alacritty.enable = true;
    };
    development = {
      git.enable = true;
      neovim.enable = true;
    };
  };

  gtk = {
    enable = true;
    font = {
      name = "${inputs.fontFamily}";
      size = 12;
    };
  };
}
