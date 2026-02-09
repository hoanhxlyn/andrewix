{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.aspects.desktop.enable {
    services = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      xserver = {
        enable = true;
        autoRepeatDelay = 200;
        autoRepeatInterval = 35;
        xkb = {
          layout = "us";
          variant = "";
        };
        desktopManager.xterm.enable = false;
      };
      printing.enable = false;
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
    };

    # Exclude default Gnome applications
    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      epiphany # web
      yelp # help
      rhythmbox # music
      gnome-contacts
      gnome-maps
    ];
  };
}
