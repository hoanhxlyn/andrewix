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
    # win32yank.exe on the Windows side (`scoop install win32yank`); options.lua
    # picks up the path from this variable.
    homeManager = {lib, ...}: let
      win32yank = "/mnt/c/Users/${host.windowsName}/scoop/root/apps/win32yank/current/win32yank.exe";
    in {
      home.sessionVariables = lib.mkIf host.wsl.enable {
        WIN32YANK = win32yank;
      };
    };
  };
}
