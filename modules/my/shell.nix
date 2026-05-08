{self, ...}: {
  den.aspects.my._.shell.homeManager = {pkgs, ...}: {
    programs = {
      oh-my-posh = {
        enable = true;
        configFile = "${self}/andrew.omp.json";
      };
      fastfetch.enable = true;
      eza.enable = true;
      fd.enable = true;
      fzf.enable = true;
      zoxide.enable = true;
      bat.enable = true;
      ripgrep.enable = true;
      tealdeer = {
        enable = true;
        enableAutoUpdates = true;
        settings.display = {
          compact = false;
          use_pager = true;
          show_title = true;
        };
      };
      fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting
          ${pkgs.fastfetch}/bin/fastfetch -c examples/13.jsonc
          set -gx CONTEXT7_API_KEY (secret-tool lookup Title "context7" 2>/dev/null)
          set -gx TAVILY_API_KEY (secret-tool lookup Title "tavily" 2>/dev/null)
          set -u EDITOR nvim
        '';
        shellAliases = {
          ll = "eza --long --icons";
          ls = "eza --all";
          cd = "z";
          cat = "bat";
          grep = "rg";
        };
        plugins = [
          {
            name = "fzf-fish";
            inherit (pkgs.fishPlugins.fzf-fish) src;
          }
          {
            name = "done";
            inherit (pkgs.fishPlugins.done) src;
          }
          {
            name = "git";
            inherit (pkgs.fishPlugins.plugin-git) src;
          }
        ];
      };
    };
  };
}
