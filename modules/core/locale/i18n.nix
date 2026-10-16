{
  core.locale.i18n = {
    nixos = {
      pkgs,
      lib,
      host,
      user,
      ...
    }: {
      i18n.defaultLocale = "en_US.UTF-8";
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "vi_VN";
        LC_IDENTIFICATION = "vi_VN";
        LC_MEASUREMENT = "vi_VN";
        LC_MONETARY = "vi_VN";
        LC_NAME = "vi_VN";
        LC_NUMERIC = "vi_VN";
        LC_PAPER = "vi_VN";
        LC_TELEPHONE = "vi_VN";
        LC_TIME = "en_US.UTF-8";
      };
      boot.kernelModules = lib.mkIf (!host.wsl.enable) ["uinput"];
      users.users.uinput_proxy = lib.mkIf (!host.wsl.enable) {
        isSystemUser = true;
        group = "input";
      };
      services.udev.packages = lib.mkIf (!host.wsl.enable) [pkgs.fcitx5-lotus];
      systemd.packages = lib.mkIf (!host.wsl.enable) [pkgs.fcitx5-lotus];
      systemd.targets.multi-user.wants = lib.mkIf (!host.wsl.enable) [
        "fcitx5-lotus-server@${user.userName}.service"
      ];
    };
    homeManager = {pkgs, ...}: {
      # Keep stylix fonts (Font/MenuFont/TrayFont), drop its generated classicui theme
      # (Theme/UseDarkTheme/UseAccentColor) so classicui themes stay user-controlled.
      stylix.targets.fcitx5.colors.enable = false;
      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5.addons = with pkgs; [
          fcitx5-lotus
          fcitx5-gtk
          # kdePackages.fcitx5-qt
        ];
        fcitx5.waylandFrontend = true;
        fcitx5.settings = {
          addons.classicui.globalSection = {
            Theme = "plasma";
            UseDarkTheme = true;
          };
          addons.lotus.globalSection = {
            AutoNonVnRestore = false;
            EnableMacro = false;
            Mode = "Uinput (Slow)";
            W2U = "Disabled";
            SpellCheck = false;
            UseLotusIcons = true;
            ShortcutDefault = 1;
            ShortcutPreedit = 2;
            ShortcutSuperSmooth = 4;
            ShowModeSmooth = true;
            ShowModeUinput = false;
            ShowModeSuperSmooth = false;
            ShowModeMinecraft = false;
            ShowModeSurroundingText = false;
            ShowModeEmoji = false;
            ShowModeSelect = false;
            ShowModeOff = false;
          };
          # fcitx5 stores KeyLists as numbered sub-sections, not flat keys.
          globalOptions."Hotkey/TriggerKeys"."0" = "Control+Shift_L";
          globalOptions."Hotkey/AltTriggerKeys" = {};
          globalOptions.Behavior = {
            ShareInputState = "All";
            ResetStateWhenFocusIn = false;
            ShowInputMethodInformation = true;
          };
          inputMethod.GroupOrder."0" = "Default";
          inputMethod."Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "keyboard-us";
          };
          inputMethod."Groups/0/Items/0".Name = "keyboard-us";
          inputMethod."Groups/0/Items/1".Name = "lotus";
        };
      };
    };
  };
}
