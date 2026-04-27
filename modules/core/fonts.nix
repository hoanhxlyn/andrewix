{
  core.fonts.nixos = {pkgs, ...}: {
    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.caskaydia-cove
      font-awesome
      inter
      noto-fonts-color-emoji
    ];
  };
}
