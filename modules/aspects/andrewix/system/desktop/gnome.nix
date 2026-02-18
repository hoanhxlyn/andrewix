{pkgs, ...}: {
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
      excludePackages = with pkgs; [xterm];
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
    gnome-user-docs
    gnome-calculator
    simple-scan
    gnome-contacts
  ];
}
