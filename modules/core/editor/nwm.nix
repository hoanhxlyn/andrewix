{
  __findFile,
  inputs,
  self,
  ...
}: {
  flake-file.inputs.nwm = {
    url = "github:BirdeeHub/nix-wrapper-modules";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake-file.inputs.mini-nvim = {
    url = "github:nvim-mini/mini.nvim";
    flake = false;
  };
  core.editor.nwm = {host, ...}: {
    includes = [
      (<den.batteries.unfree> [
        "scope.nvim"
      ])
    ];
    nixos = {
      imports = [
        (import "${self}/modules/core/editor/_nwm/wrapper.nix" {inherit inputs self;})
      ];
    };
    # WSL has no Wayland compositor, so nvim's clipboard bridge goes through
    # win32yank.exe on the Windows side (installed on the Windows side); options.lua
    # picks up the path from this variable.
    homeManager = {lib, ...}: let
      win32yank = host.windows.tools.win32yank;
    in {
      home.sessionVariables = lib.mkIf host.wsl.enable {
        WIN32YANK = win32yank;
      };
    };
  };
}
