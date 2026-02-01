{ pkgs, fontFamily, ... }@inputs:
{
  i18n = {
    inputMethod.enable = true;
    inputMethod.type = "fcitx5";
    inputMethod.fcitx5 = {
      addons = with pkgs; [
        kdePackages.fcitx5-unikey
        fcitx5-gtk
      ];
      waylandFrontend = true;
      ignoreUserConfig = false;
      settings = {
        addons = {
          unikey.globalSection = {
            InputMethod = "0";
            OutputCharset = "0";
            SpellCheck = "False";
          };
          classicui.globalSection = {
            Font = "${fontFamily} 11";
            MenuFont = "${fontFamily} 11";
          };
        };
        globalOptions = { };
        inputMethod = {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "keyboard-us";
          };
          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "unikey";
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
