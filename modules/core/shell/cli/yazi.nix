{
  inputs,
  self,
  ...
}: {
  flake-file.inputs = {
    yamb-yazi = {
      url = "github:h-hg/yamb.yazi";
      flake = false;
    };
    omp-yazi = {
      url = "github:saumyajyoti/omp.yazi";
      flake = false;
    };
    compress-yazi = {
      url = "github:KKV9/compress.yazi";
      flake = false;
    };
  };
  core.cli.yazi = {host, ...}: {
    nixos = {
      pkgs,
      lib,
      ...
    }: {
      xdg.portal = {
        extraPortals = [pkgs.xdg-desktop-portal-termfilechooser];
        config.niri."org.freedesktop.impl.portal.FileChooser" = lib.mkForce ["termfilechooser"];
      };
    };

    homeManager = {pkgs, ...}: let
      plug = pkgs.yaziPlugins;
      yamb = plug.mkYaziPlugin {
        pname = "yamb.yazi";
        version = "0-unstable-2026-07-18";
        src = inputs.yamb-yazi;
        postPatch = ''
          substituteInPlace main.lua --replace-fail 'ya.hide()' 'ui.hide()'
        '';
      };
      omp = plug.mkYaziPlugin {
        pname = "omp.yazi";
        version = "0-unstable-2026-02-17";
        src = inputs.omp-yazi;
      };
      compress = plug.mkYaziPlugin {
        pname = "compress.yazi";
        version = "0-unstable-2026-03-09";
        src = inputs.compress-yazi;
      };
      yambPreview = pkgs.writeShellScript "yamb-preview" ''
        if [ -d "$1" ]; then
          ${pkgs.eza}/bin/eza -T -L 1 --color=always --icons=always "$1"
        else
          ${pkgs.bat}/bin/bat --color=always --style=numbers --line-range=:100 "$1"
        fi
      '';
    in {
      home.packages = [pkgs.ueberzugpp];
      xdg.desktopEntries.yazi = {
        name = "Yazi File Manager";
        comment = "Blazing fast terminal file manager written in Rust, based on async I/O";
        icon = "yazi";
        exec = "${host.terminal.name} -e yazi %f";
        terminal = false;
        categories = ["System" "FileManager" "FileTools" "ConsoleOnly"];
        mimeType = ["inode/directory"];
      };
      xdg.mimeApps.defaultApplications = let
        yazi = "yazi.desktop";
      in {
        "inode/directory" = yazi;
        # Types with no default handler → open in yazi (file's folder)
        "text/csv" = yazi;
        "application/zip" = yazi;
        "application/x-tar" = yazi;
        "application/gzip" = yazi;
        "application/x-7z-compressed" = yazi;
      };
      xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
        [filechooser]
        cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
        env=TERMCMD=${host.terminal.name} -e
        open_mode=suggested
        save_mode=suggested
      '';
      programs.yazi = {
        enable = true;
        settings.mgr = {
          show_hidden = true;
          sort_by = "mtime";
          sort_reverse = true;
          linemode = "size";
        };
        # csv is text/* → yazi defaults to $EDITOR; open in calc instead
        settings.opener.calc = [
          {
            run = ''libreoffice --calc "$@"'';
            orphan = true;
            desc = "LibreOffice Calc";
          }
        ];
        settings.open.prepend_rules = [
          {
            url = "*.csv";
            use = ["calc" "reveal"];
          }
        ];
        plugins = {
          inherit (plug) full-border;
          inherit (plug) smart-enter;
          inherit (plug) lazygit;
          inherit (plug) git;
          inherit compress;
          inherit yamb;
          inherit omp;
        };
        initLua = ''
          require("full-border"):setup()
          require("git"):setup()
          require("yamb"):setup({
            cli = "fzf --delimiter='\t' --with-nth='{3} │ {1} {2}' --preview='${yambPreview} {2}' --preview-window=right:50%:wrap --height=40% --layout=reverse --border=rounded",
          })
          require("omp"):setup({ config = "${self}/config/omp/andrew.omp.json" })
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
            on = ["<c-f>"];
            run = "seek 5";
            desc = "Scroll preview down";
          }
          {
            on = ["<c-b>"];
            run = "seek -5";
            desc = "Scroll preview up";
          }
        ];
      };
    };
  };
}
