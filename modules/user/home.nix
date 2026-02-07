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
  gtk = {
    enable = true;
    font = {
      name = "${inputs.fontFamily}";
      size = 12;
    };
  };
}
