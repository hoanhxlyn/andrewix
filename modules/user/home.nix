{
  username,
  stateVersion,
  ...
} @ inputs: {
  imports = [
    ./aspects/development
    ./aspects/desktop
    ./aspects/utilities
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
