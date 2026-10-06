{inputs, self, ...}: {
  flake-file.inputs.herdr-nix.url = "github:herdrdev/herdr-nix";
  core.mux.herdr = {host, ...}: {
    nixos.nix.settings = {
      extra-substituters = ["https://herdr.cachix.org"];
      extra-trusted-public-keys = ["herdr.cachix.org-1:3nH7IStRsS0ASfdonA0DCRR2ZrSCeWitZ7Kwew0cR4I="];
    };
    homeManager = {
      pkgs,
      config,
      lib,
      ...
    }: let
      colors = config.lib.stylix.colors.withHashtag;
      herdrPkg = inputs.herdr-nix.packages.${pkgs.stdenv.hostPlatform.system}.herdr;
      herdrBin = lib.getExe herdrPkg;
    in {
      programs.herdr = {
        package = herdrPkg;
        enable = host.terminal.mux == "herdr";
        settings = {
          onboarding = false;
          terminal.new_cwd = "home";
          theme = {
            name = "terminal";
            custom = {
              panel_bg = colors.base00;
              sidebar_bg = colors.base01;
              surface0 = colors.base01;
              surface1 = colors.base02;
              surface_dim = colors.base02;
              overlay0 = colors.base03;
              overlay1 = colors.base04;
              active_row_bg = colors.base02;
              selection_bg = colors.base02;
              text = colors.base05;
              subtext0 = colors.base04;
              accent = colors.base0D;
              red = colors.base08;
              peach = colors.base09;
              yellow = colors.base0A;
              green = colors.base0B;
              teal = colors.base0C;
              blue = colors.base0D;
              mauve = colors.base0E;
            };
          };
          keys = {
            prefix = "alt+q";
            # Misc
            settings = "prefix+S";
            edit_scrollback = "prefix+[";
            copy_mode = "prefix+]";
            reload_config = "prefix+alt+r";
            # Tab and panes
            new_tab = "prefix+n";
            next_tab = "prefix+L";
            previous_tab = "prefix+H";
            focus_pane_left = "prefix+h";
            focus_pane_right = "prefix+l";
            focus_pane_down = "prefix+j";
            focus_pane_up = "prefix+k";
            split_horizontal = "prefix+s";
            split_vertical = "prefix+v";
            rename_tab = "prefix+r";
            rename_pane = "prefix+R";
            resize_mode = "prefix+z";
            resize_pane_left = "alt+Left";
            resize_pane_right = "alt+Right";
            resize_pane_down = "alt+Down";
            resize_pane_up = "alt+Up";
            close_pane = "prefix+c";
            close_tab = "prefix+C";
            zoom = "prefix+f";
            goto = "prefix+\\";
            close_workspace = "prefix+x";
            previous_workspace = "prefix+K";
            next_workspace = "prefix+J";
            switch_workspace = "prefix+shift+1..9";
            navigate_workspace_up = "k";
            navigate_workspace_down = "j";
            move_tab_previous = "prefix+<";
            move_tab_next = "prefix+>";
            command = [
              {
                key = "prefix+d";
                type = "shell";
                command = ''"${herdrBin}" tab create --cwd "$HERDR_ACTIVE_PANE_CWD" --focus'';
                description = "duplicate tab in current cwd";
              }
              {
                key = "prefix+e";
                type = "popup";
                command = "${self}/config/yazi/yazi-resume.sh";
                description = "yazi (resume last dir)";
                width = "90%";
                height = "90%";
              }
              {
                key = "prefix+E";
                type = "popup";
                command = ''${lib.getExe pkgs.fish} -c yazi'';
                description = "yazi (current dir)";
                width = "90%";
                height = "90%";
              }
              {
                key = "prefix+g";
                type = "popup";
                command = ''${lib.getExe pkgs.fish} -c lazygit'';
                description = "lazygit (current dir)";
                width = "90%";
                height = "90%";
              }
              {
                key = "prefix+/";
                type = "popup";
                command = "${lib.getExe pkgs.fish} -c btop";
                description = "Open Btop";
                width = "90%";
                height = "90%";
              }
            ];
          };
          ui = {
            sound.enabled = false;
            status_indicators = "symbols"; # symbols | dots
            toast = {
              delivery = "herdr";
              herdr.position = "top-right";
            };
            prompt_new_tab_name = false;
            hide_tab_bar_when_single_tab = false;
            confirm_close = true;
          };
        };
      };
    };
  };
}
