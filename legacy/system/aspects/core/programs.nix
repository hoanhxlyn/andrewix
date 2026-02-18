{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    fuse
    usbutils
    pciutils
    wl-clipboard
    wl-clip-persist
    cliphist
    nh
    ast-grep
    pnpm
    nodePackages.nodejs
    bun
  ];
  programs = {
    fish.enable = true;
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 2d --keep 5";
      flake = "/home/${username}/andrewix";
    };
  };
}
