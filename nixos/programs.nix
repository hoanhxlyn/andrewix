{ pkgs, username, ... }@inputs:
{
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    alacritty
    fuse
    usbutils
    pciutils
    wl-clipboard
    wl-clip-persist
    cliphist
    nh
    ast-grep
    brave
    pnpm
    bun
    caprine
    gnomeExtensions.kimpanel
  ];

  programs.fish.enable = true;
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 2d --keep 5";
    flake = "/home/${username}/dotconfigs";
  };
  programs.firefox.enable = true;
}
