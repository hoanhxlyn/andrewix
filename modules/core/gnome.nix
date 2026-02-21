{
  core.gnome = {
    homeManager = {
      dconf.settings = {
        "org/gnome/desktop/peripherals/touchpad" = {
          natural-scroll = true;
          tap-to-click = true;
          two-finger-scrolling-enabled = true;
        };
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
        "org/gnome/desktop/a11y/interface" = {
          show-status-shapes = false;
        };
        "org/gnome/mutter" = {
          dynamic-workspaces = true;
        };
      };
    };
    nixos = {pkgs, ...}: {
      services = {
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
        xserver.excludePackages = with pkgs; [xterm];
      };
      # Disable nixos manual
      documentation.nixos.enable = false;
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

      # systemd.services."getty@tty1".enable = false;
      # systemd.services."autovt@tty1".enable = false;
    };
  };
}
