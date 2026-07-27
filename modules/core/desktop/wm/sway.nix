{self, ...}: {
  core.desktop.wm.sway = {host, ...}: let
    isLaptop = host.isLaptop or false;
  in {
    nixos.security.pam.services.swaylock = {};
    homeManager = {
      pkgs,
      lib,
      config,
      ...
    }: let
      blurredBackground = import "${self}/modules/_lib/blurred-image.nix" {
        inherit pkgs;
        image = config.stylix.image;
      };
      lockCmd = "${pkgs.swaylock-effects}/bin/swaylock -f";
      display = status:
        if status == "off"
        then "${pkgs.niri}/bin/niri msg action power-off-monitors"
        else ":";
      cat = "${pkgs.coreutils}/bin/cat";
      restoreBrightness = "test -f $XDG_RUNTIME_DIR/swayidle-brightness && ${pkgs.brightnessctl}/bin/brightnessctl set $(${cat} $XDG_RUNTIME_DIR/swayidle-brightness) || true";
      inherit (host) idle;
    in {
      home.packages = with pkgs; [swaybg brightnessctl];
      programs.swaylock = {
        enable = true;
        package = pkgs.swaylock-effects;
        settings = {
          indicator-idle-visible = true;
          show-failed-attempts = false;
          image = lib.mkForce "${blurredBackground}";
          fade-in = 0.5;
          clock = true;
          grace = 10;
        };
      };
      services.swayidle = {
        enable = true;
        events = {
          before-sleep = lockCmd;
          after-resume = "${display "on"}; ${restoreBrightness}";
        };
        timeouts =
          lib.optionals isLaptop [
            {
              timeout = idle.dim;
              command = "[ \"$(/run/current-system/sw/bin/tlp-stat -m 2>/dev/null)\" = \"performance/AC\" ] || { ${pkgs.brightnessctl}/bin/brightnessctl get > $XDG_RUNTIME_DIR/swayidle-brightness && ${pkgs.brightnessctl}/bin/brightnessctl set 10%; }";
              resumeCommand = "${pkgs.brightnessctl}/bin/brightnessctl set $(${cat} $XDG_RUNTIME_DIR/swayidle-brightness)";
            }
          ]
          ++ [
            {
              timeout = idle.lock;
              command = lockCmd;
            }
            {
              timeout = idle.monitorOff;
              command = display "off";
              resumeCommand = display "on";
            }
            {
              timeout = idle.suspend;
              command = "${pkgs.systemd}/bin/systemctl suspend --ignore-inhibitors";
            }
          ];
      };
    };
  };
}
