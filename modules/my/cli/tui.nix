{__findFile, ...}: {
  den.aspects.my.cli.tui = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.ueberzugpp];
    };
    homeManager = {pkgs, ...}: let
      plug = pkgs.yaziPlugins;
    in {
      home.packages = with pkgs; [sqlit-tui];
      programs = {
        yazi = {
          enable = true;
          shellWrapperName = "y";
          settings.mgr.show_hidden = true;
          plugins = {
            "full-border" = plug.full-border;
            "smart-enter" = plug.smart-enter;
            "lazygit" = plug.lazygit;
            "git" = plug.git;
          };
          initLua = ''
            require("full-border"):setup()
            require("git"):setup()
          '';
          keymap.mgr.prepend_keymap = [
            {
              on = ["<Enter>"];
              run = "plugin smart-enter";
              desc = "Enter dir or open file";
            }
            {
              on = ["<C-g>"];
              run = "plugin lazygit";
              desc = "Open lazygit";
            }
          ];
        };
        dbeaver.enable = true;
      };
      # xdg.configFile."YouTube Music/config.json".force = true;
      # xdg.configFile."YouTube Music/config.json".source = "${self}/config/youtube-music/config.json";
    };
  };
}
