{
  core.i18n = {host, ...}: {
    nixos = {
      pkgs,
      lib,
      user,
      ...
    }: {
      i18n = {
        inputMethod =
          if host.wsl.enable
          then {}
          else {
            enable = true;
            type = "fcitx5";
            fcitx5 = {
              addons = with pkgs; [fcitx5-lotus];
              waylandFrontend = true;
              ignoreUserConfig = false;
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
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = [pkgs.fcitx5-mellow-themes];
      i18n.inputMethod = lib.mkIf (!host.wsl.enable) {
        enable = true;
        type = "fcitx5";
        fcitx5 = {
          addons = [pkgs.fcitx5-lotus];
          waylandFrontend = true;
          # niri starts fcitx5 (modules/core/desktop/wm/niri.nix)
          systemd.enable = false;
          settings = {
            addons.classicui.globalSection = {
              Theme = "mellow-graphite-dark";
              UseDarkTheme = true;
            };
            globalOptions = {
              "Hotkey/TriggerKeys" = {
                "0" = "Control+Shift_L";
              };
              "Hotkey/AltTriggerKeys" = {};
              Behavior = {
                ShareInputState = "All";
                ResetStateWhenFocusIn = "No";
                ShowInputMethodInformation = "True";
              };
            };
            inputMethod = {
              "Groups/0" = {
                Name = "Default";
                "Default Layout" = "us";
                DefaultIM = "lotus";
              };
              "Groups/0/Items/0".Name = "keyboard-us";
              "Groups/0/Items/1".Name = "lotus";
            };
            addons.lotus.globalSection = {
              AutoNonVnRestore = false;
              EnableMacro = false;
              Mode = "Uinput (Slow)";
              ModeOrder = "Smooth,Uinput,Minecraft,SurroundingText,Preedit,Emoji,Off,SuperSmooth,Default";
              W2U = "Disabled";
              SpellCheck = false;
              UseLotusIcons = true;
              ShortcutDefault = 1;
              ShortcutPreedit = 2;
              ShortcutSuperSmooth = 4;
              ShowModeSmooth = false;
              ShowModeUinput = false;
              ShowModeSuperSmooth = false;
              ShowModeMinecraft = false;
              ShowModeSurroundingText = false;
              ShowModeEmoji = false;
              ShowModeOff = false;
            };
          };
        };
      };
    };
  };
}
