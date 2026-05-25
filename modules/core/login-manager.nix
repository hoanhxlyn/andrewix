{
  core.login-manager = session-name: {
    nixos.services.displayManager = {
      gdm.enable = true;
    };
  };
}
