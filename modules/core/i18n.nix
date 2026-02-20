{
  lib,
  inputs,
  ...
}: {
  flake-file.inputs.fcitx5-vmk-nix = {
    url = lib.mkDefault "github:hoanhxlyn/fcitx5-vmk-nix";
    inputs.nixpkgs.follows = lib.mkDefault "nixpkgs";
  };

  core.i18n.nixos = {pkgs, ...}: {
    i18n = {
      inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5 = {
          addons = with pkgs; [
            inputs.fcitx5-vmk-nix.packages.${pkgs.system}.fcitx5-vmk
            fcitx5-gtk
            kdePackages.fcitx5-qt
          ];
          waylandFrontend = true;
          ignoreUserConfig = false;
          settings = {
            addons = {
              vmk.globalSection = {
                Mode = "vmkpre";
                InputMethod = "Telex";
                OutputCharset = "Unicode";
                Gemini = "True";
                ChromeX11 = "True";
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
              "Groups/0/Items/1".Name = "vmk";
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
  };
}
