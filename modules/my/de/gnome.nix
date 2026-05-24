{__findFile, ...}: {
  den.aspects.my.de.gnome = {
    includes = [
      (<core.login-manager> "gnome")
    ];
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
          experimental-features = ["scale-monitor-framebuffer"];
        };
      };
    };
    nixos = {
      pkgs,
      lib,
      ...
    }: {
      services = {
        desktopManager.gnome.enable = true;
        xserver.excludePackages = with pkgs; [xterm];
        gnome.gnome-keyring.enable = lib.mkForce false;
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
      environment.systemPackages = with pkgs; [
        gnomeExtensions.blur-my-shell
        gnomeExtensions.dash-to-panel
        gnomeExtensions.essential-tweaks
        gnome-tweaks
        pkgs.gnomeExtensions.kimpanel
      ];
    };
  };
}
