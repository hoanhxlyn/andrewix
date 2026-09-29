{
  core.i18n = {
    nixos = {
      pkgs,
      lib,
      host,
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
              addons = with pkgs; [
                fcitx5-lotus
                # fcitx5-gtk
                # kdePackages.fcitx5-qt
              ];
              waylandFrontend = true;
              ignoreUserConfig = false;
              settings = {
                globalOptions = {
                  "Hotkey/TriggerKeys" = {
                    "0" = "Control+Shift_L";
                  };
                  "Hotkey/AltTriggerKeys" = {};
                  Behavior = {
                    ShareInputState = "All";
                    ResetStateWhenFocusIn = "No";
                    ShowInputMethodInformation = "False";
                  };
                };
                inputMethod = {
                  "Groups/0" = {
                    Name = "Default";
                    "Default Layout" = "us";
                    DefaultIM = "keyboard-us";
                  };
                  "Groups/0/Items/0".Name = "keyboard-us";
                  "Groups/0/Items/1".Name = "lotus";
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
      # Mirrors github:LotusInputMethod/fcitx5-lotus nix/modules/nixos/fcitx5-lotus/default.nix
      # by hand: consuming the nixpkgs package, no flake input. The server unit runs as
      # `uinput_proxy`, so that sysuser and the package's udev rule (which setfacl's
      # /dev/uinput rw for it) are both required, not just systemd.packages.
      users.users.uinput_proxy = lib.mkIf (!host.wsl.enable) {
        isSystemUser = true;
        group = "input";
      };
      services.udev.packages = lib.mkIf (!host.wsl.enable) [pkgs.fcitx5-lotus];
      systemd.packages = lib.mkIf (!host.wsl.enable) [pkgs.fcitx5-lotus];
      systemd.targets.multi-user.wants = lib.mkIf (!host.wsl.enable) [
        "fcitx5-lotus-server@andrew.service"
      ];
    };
  };
}
