{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    brave
    alacritty
  ];
  programs.firefox.enable = true;
}
