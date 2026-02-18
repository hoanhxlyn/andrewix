{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    caprine
    gnomeExtensions.kimpanel
  ];
}
