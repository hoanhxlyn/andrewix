{
  pkgs,
  fontFamily,
  ...
}: {
  environment.variables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };
  i18n = {
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [
          # kdePackages.fcitx5-unikey
          fcitx5-bamboo
          fcitx5-gtk
          kdePackages.fcitx5-qt
        ];
        waylandFrontend = true;
        ignoreUserConfig = false;
        settings = {
          addons = {
            bamboo.globalSection = {
              InputMethod = "Telex";
              OutputCharset = "Unicode";
              SpellCheck = "False";
              Macro = "False";
              ModernStyle = "True";
              FreeMarking = "True";
              DisplayUnderline = "False";
              AutoNonVnRestore = "True";
              CapitalizeMacro = "True";
            };
            classicui.globalSection = {
              Font = "${fontFamily} 11";
              MenuFont = "${fontFamily} 11";
            };
          };
          globalOptions = {
            Hotkey = {
              "TriggerKeys" = "Control+Shift_L";
              "AltTriggerKeys" = "";
            };
          };
          inputMethod = {
            "Groups/0" = {
              Name = "Default";
              "Default Layout" = "us";
              DefaultIM = "keyboard-us";
            };
            "Groups/0/Items/0".Name = "keyboard-us";
            # "Groups/0/Items/1".Name = "unikey";
            "Groups/0/Items/1".Name = "bamboo";
          };
        };
      };
    };
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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
  };
}
