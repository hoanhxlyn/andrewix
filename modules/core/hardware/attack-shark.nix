{self, ...}: {
  core.hardware.attack-shark = {
    nixos = {pkgs, ...}: {
      # Config interface of the 2.4G dongle (1d57:fa60) and of the wired mouse (1d57:2125):
      # without the uaccess tag the GUI cannot open /dev/hidraw*. 70-* so the tag is set
      # before systemd's 73-seat-late.rules hands the ACL out (99-local.rules is too late).
      services.udev.packages = [
        (pkgs.writeTextFile {
          name = "attack-shark-udev-rules";
          destination = "/etc/udev/rules.d/70-attack-shark.rules";
          text = ''
            SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1d57", TAG+="uaccess"
          '';
        })
      ];
    };
    homeManager = {
      pkgs,
      lib,
      ...
    }: let
      shark = pkgs.callPackage "${self}/modules/_lib/sharkx11.nix" {};
    in {
      home.packages = [shark];
      # Same idea as solaarDpi: two stages (default 1400, button toggles 1600) back on every login,
      # including the disabled stages 3..8 the GUI may have left enabled. static_dpi keeps the LED
      # on and shows which stage is active, instead of the "off" the GUI leaves behind.
      home.activation.attackSharkDpi = lib.hm.dag.entryAfter ["writeBoundary"] ''
        ${shark}/bin/x11ctl dpi --stages 1400,1600 --active 1 --colors '#4cd964,#ff0000' >/dev/null 2>&1 || true
        ${shark}/bin/x11ctl light --mode static_dpi --brightness 3 >/dev/null 2>&1 || true
        # Firmware default sleeps after 1 min, which swallows the first move; GUI resets it too.
        ${shark}/bin/x11ctl power --sleep 15 --deep-sleep 60 >/dev/null 2>&1 || true
      '';
      home.file.".local/share/applications/attack-shark.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=ATTACK SHARK X11SE
        Comment=DPI stages, polling, buttons, lighting and battery
        Exec=${shark}/bin/x11gui
        Icon=input-mouse
        Categories=Utility;Settings;
      '';
    };
  };
}
