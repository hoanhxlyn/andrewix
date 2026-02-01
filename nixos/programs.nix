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
  ];

  programs.fish.enable = true;
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/user/${username}";
  };
  programs.firefox.enable = true;
}
