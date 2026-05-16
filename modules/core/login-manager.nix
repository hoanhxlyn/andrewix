{
  core.login-manager = session-name: {
    nixos.services.displayManager = {
      gdm.enable = true;
      defaultSession =
        if session-name != null
        then session-name
        else "gnome";
    };
  };
}
