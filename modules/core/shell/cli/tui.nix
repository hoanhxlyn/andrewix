{
  core.cli.tui = {
    homeManager = {
      pkgs,
      config,
      ...
    }: let
      colors = config.lib.stylix.colors.withHashtag;
    in {
      home.packages = with pkgs; [bruno];
      programs = {
        dbeaver.enable = true;
        herdr = {
          enable = true;
          settings = {
            onboarding = false;
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
              edit_scrollback = "";
              # Tab and panes
              new_tab = "prefix+n";
              next_tab = "prefix+L";
              previous_tab = "prefix+H";
              focus_pane_left = "prefix+h";
              focus_pane_right = "prefix+l";
              focus_pane_down = "prefix+j";
              focus_pane_up = "prefix+k";
              split_horizontal = "prefix+v";
              split_vertical = "prefix+s";
              rename_tab = "prefix+r";
              rename_pane = "prefix+R";
              resize_mode = "";
              resize_pane_left = "alt+Left";
              resize_pane_right = "alt+Right";
              resize_pane_down = "alt+Down";
              resize_pane_up = "alt+Up";
              close_pane = "prefix+c";
              close_tab = "prefix+x";
            };
            ui = {
              sound.enabled = false;
              status_indicators = "dots"; # symbols | dots
              toast.delivery = "herdr";
            };
          };
        };
      };
      # xdg.configFile."YouTube Music/config.json".force = true;
      # xdg.configFile."YouTube Music/config.json".source = "${self}/config/youtube-music/config.json";
    };
  };
}
