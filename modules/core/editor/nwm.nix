{
  inputs,
  self,
  ...
}: {
  flake-file.inputs = {
    nwm = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mini-nvim = {
      url = "github:nvim-mini/mini.nvim";
      flake = false;
    };
  };

  core.editor.nwm = {
    nixos = _: {
      imports = [
        (import "${self}/modules/core/editor/_nwm/wrapper.nix" {inherit inputs self;})
      ];
    };
  };
}
