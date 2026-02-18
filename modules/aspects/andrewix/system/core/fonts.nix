{
  pkgs,
  fontFamily,
  ...
}: {
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.caskaydia-cove
    font-awesome
    inter
    noto-fonts-color-emoji
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      emoji = ["Noto Color Emoji"];
      monospace = ["${fontFamily} Fira Code Nerd Fonts"];
      sansSerif = ["Inter"];
      serif = ["Inter"];
    };
  };
}
