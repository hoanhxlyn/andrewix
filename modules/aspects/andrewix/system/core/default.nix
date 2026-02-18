{
  __findFile ? __findFile,
  den,
  ...
}: {
  andrewix.system.core = den.lib.parametric ({
    fontFamily ? "CaskaydiaCove Nerd Font",
    colorScheme ? "catppuccin-mocha",
    ...
  }: {
    includes = [
      <andrewix/system/core/boot>
      <andrewix/system/core/fonts>
      <andrewix/system/core/i18n>
      <andrewix/system/core/programs>
      (<andrewix/system/core/stylix> {inherit fontFamily colorScheme;})
    ];

    config = {
      networking.networkmanager.enable = true;
      time.timeZone = "Asia/Ho_Chi_Minh";
      security.rtkit.enable = true;
      nix = {
        settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
        settings.auto-optimise-store = true;
      };
    };
  });
}
