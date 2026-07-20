{inputs, ...}: {
  flake-file.inputs = {
    yamb-yazi = {
      url = "github:h-hg/yamb.yazi";
      flake = false;
    };
    omp-yazi = {
      url = "github:saumyajyoti/omp.yazi";
      flake = false;
    };
  };
  core.cli.yazi = {
    homeManager = {pkgs, ...}: let
      plug = pkgs.yaziPlugins;
      yamb = plug.mkYaziPlugin {
        pname = "yamb.yazi";
        version = "0-unstable-2026-07-18";
        src = inputs.yamb-yazi;
      };
      omp = plug.mkYaziPlugin {
        pname = "omp.yazi";
        version = "0-unstable-2026-02-17";
        src = inputs.omp-yazi;
      };
    in {
      home.packages = [pkgs.ueberzugpp];
      programs.yazi = {
        enable = true;
        settings.mgr.show_hidden = true;
        plugins = {
          "full-border" = plug.full-border;
          "smart-enter" = plug.smart-enter;
          "lazygit" = plug.lazygit;
          "git" = plug.git;
          "compress" = plug.compress;
          "yamb" = yamb;
          "omp" = omp;
        };
        initLua = ''
          require("full-border"):setup()
          require("git"):setup()
          require("yamb"):setup({})
          require("omp"):setup()
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
          {
            on = ["g" "i"];
            run = "plugin lazygit";
            desc = "Open lazygit";
          }
          {
            on = ["c" "a" "a"];
            run = "plugin compress";
            desc = "Archive selected files";
          }
          {
            on = ["m" "a"];
            run = "plugin yamb -- save";
            desc = "Save bookmark";
          }
          {
            on = ["m" "g"];
            run = "plugin yamb -- jump_by_key";
            desc = "Jump bookmark by key";
          }
          {
            on = ["m" "G"];
            run = "plugin yamb -- jump_by_fzf";
            desc = "Jump bookmark by fzf";
          }
          {
            on = ["m" "d"];
            run = "plugin yamb -- delete_by_key";
            desc = "Delete bookmark by key";
          }
          {
            on = ["m" "A"];
            run = "plugin yamb -- delete_all";
            desc = "Delete all bookmarks";
          }
          {
            on = ["m" "r"];
            run = "plugin yamb -- rename_by_key";
            desc = "Rename bookmark by key";
          }
          {
            on = ["<C-f>"];
            run = "seek 5";
            desc = "Scroll preview down";
          }
          {
            on = ["<C-b>"];
            run = "seek -5";
            desc = "Scroll preview up";
          }
        ];
      };
    };
  };
}
