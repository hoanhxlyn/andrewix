{ config, pkgs, ... }:
let
  rust-nightly = pkgs.rust-bin.nightly.latest.default.override {
    extensions = [ "rust-src" "rust-analyzer" ];
  };
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      rust-nightly
      cargo
      ripgrep
      fd
      gcc
      unzip
      wget
      curl
      tree-sitter
      lua-language-server
    ];
  };

  # Link existing config
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nvim";
}
