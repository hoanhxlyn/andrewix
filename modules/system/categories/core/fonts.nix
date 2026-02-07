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
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = ["${fontFamily}"];
    };
  };
}
