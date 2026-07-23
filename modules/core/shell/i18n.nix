{
  inputs,
  self,
  ...
}: {
  flake-file.inputs.fcitx5-lotus = {
    url = "github:LotusInputMethod/fcitx5-lotus";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  core.i18n = {
    nixos = {
      pkgs,
      host,
      ...
    }: {
      imports = [
        inputs.fcitx5-lotus.nixosModules.fcitx5-lotus
      ];
      # lotus (not bamboo): sends real backspace+retype keystrokes via its uinput
      # server instead of relying on the terminal's IME preedit protocol, so it
      # types correctly in Rio, which doesn't render fcitx5 preedit text inline.
      services.fcitx5-lotus = {
        enable = !host.wsl.enable;
        users = ["andrew"];
      };
      i18n = {
        # fcitx5 needs a Wayland compositor, which WSL doesn't run.
        inputMethod =
          if host.wsl.enable
          then {}
          else {
            enable = true;
            type = "fcitx5";
            fcitx5 = {
              addons = with pkgs; [
                fcitx5-gtk
                kdePackages.fcitx5-qt
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
    };
    # Hybrid lotus config: seed the committed .conf files on fresh install (so the
    # repo is the default from the get-go), then never touch them again so GUI edits
    # persist. `lotus-export` snapshots the live config back into the repo on demand.
    homeManager = {
      pkgs,
      lib,
      ...
    }: let
      seed = "${self}/config/lotus/conf";
      files = "lotus.conf lotus-macro-table.conf lotus-app-rules.conf lotus-custom-keymap.conf";
      repoDir = "$HOME/andrewix/config/lotus/conf";
      lotus-export = pkgs.writeShellScriptBin "lotus-export" ''
        set -eu
        conf="$HOME/.config/fcitx5/conf"
        for f in ${files}; do
          cp "$conf/$f" "${repoDir}/$f"
        done
        echo "lotus config exported to ${repoDir}"
      '';
      # Reverse of lotus-export: pull committed config onto a machine whose
      # lotusSeed guard already ran (so a plain rebuild won't overwrite it).
      lotus-import = pkgs.writeShellScriptBin "lotus-import" ''
        set -eu
        conf="$HOME/.config/fcitx5/conf"
        mkdir -p "$conf"
        for f in ${files}; do
          cp "${repoDir}/$f" "$conf/$f"
        done
        ${lib.getExe' pkgs.fcitx5 "fcitx5-remote"} -r || true
        echo "lotus config imported from ${repoDir} (fcitx5 reloaded)"
      '';
    in {
      home.packages = [lotus-export lotus-import];
      home.activation.lotusSeed = lib.hm.dag.entryAfter ["writeBoundary"] ''
        conf="$HOME/.config/fcitx5/conf"
        if [ ! -f "$conf/lotus.conf" ]; then
          mkdir -p "$conf"
          for f in ${files}; do
            install -m600 "${seed}/$f" "$conf/$f"
          done
        fi
      '';
    };
  };
}
