{
  core.hardware.mount = {
    nixos.services.udisks2.enable = true;
    homeManager.services.udiskie = {
      enable = true;
      automount = true;
      notify = true;
    };
  };
}
