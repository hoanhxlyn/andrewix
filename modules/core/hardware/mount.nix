{
  core.hardware.mount = {
    # Removable-media stack: udisks2 alone never mounts anything, udiskie does it
    # on plug-in and notifies. Paths land in /run/media/andrew/<label>.
    nixos.services.udisks2.enable = true;
    homeManager.services.udiskie = {
      enable = true;
      automount = true;
      notify = true;
    };
  };
}
