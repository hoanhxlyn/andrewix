{self, ...}: {
  den.aspects.my.shell.homeManager = {pkgs, ...}: {
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
          set -gx SOPS_AGE_KEY_FILE "$HOME/.config/sops-nix/keys.txt"
          set -gx CONTEXT7_API_KEY (cat ~/.config/sops-nix/secrets/CONTEXT7_API_KEY 2>/dev/null; or echo "")
          set -gx TAVILY_API_KEY (cat ~/.config/sops-nix/secrets/TAVILY_API_KEY 2>/dev/null; or echo "")
          set -gx BRAVE_API_KEY (cat ~/.config/sops-nix/secrets/BRAVE_API_KEY 2>/dev/null; or echo "")
          set -u EDITOR nvim
          set -gx DOCKER_HOST unix://$XDG_RUNTIME_DIR/podman/podman.sock
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
