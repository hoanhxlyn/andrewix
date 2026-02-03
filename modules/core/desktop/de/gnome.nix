{
  core.desktop.de.gnome = {host, ...}: {
    homeManager = {
      dconf.settings = {
        "org/gnome/desktop/peripherals/touchpad" = {
          natural-scroll = host.input.touchpad.naturalScroll;
          tap-to-click = host.input.touchpad.tap;
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
          experimental-features = ["scale-monitor-framebuffer" "kms-modifiers"];
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
        gnome.gnome-keyring.enable = lib.mkForce false;
        displayManager.gdm.enable = true;
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
        gnomeExtensions.kimpanel
        gnome-tweaks
      ];
    };
  };
}
