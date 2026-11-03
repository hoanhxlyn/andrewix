{inputs, ...}: {
  flake-file.inputs.shark-nix = {
    url = "github:hoanhxlyn/shark-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  core.hardware.attack-shark = {
    nixos.imports = [inputs.shark-nix.nixosModules.default];
    homeManager = {
      imports = [inputs.shark-nix.homeManagerModules.default];
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
      };
    };
  };
}
