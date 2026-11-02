{inputs, ...}: {
  flake-file.inputs.shark-nix = {
    url = "github:hoanhxlyn/shark-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  core.hardware.attack-shark = {
    # Product-scoped hidraw uaccess rules for the receiver and both cable modes, plus the systemd
    # tag that starts sharkx11-apply whenever the mouse appears.
    nixos.imports = [inputs.shark-nix.nixosModules.default];

    homeManager = {
      imports = [inputs.shark-nix.homeManagerModules.default];

      # Two stages (1400 default, button toggles 1600) back on every login and plug, including the
      # disabled stages 3..8 the GUI may have left enabled. static_dpi keeps the LED on and shows
      # which stage is active, instead of the "off" the GUI leaves behind. The firmware default
      # sleeps after 1 min, which swallows the first move.
      programs.sharkx11 = {
        enable = true;
        dpi.stages = [
          {
            dpi = 1400;
            color = "#4cd964";
          }
          {
            dpi = 1600;
            color = "#ff0000";
          }
        ];
        dpi.activeStage = 1;
        lighting.mode = "static_dpi";
        lighting.brightness = 3;
        power.sleep = 15;
        power.deepSleep = 60;
      };
    };
  };
}
