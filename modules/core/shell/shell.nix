{__findFile, ...}: {
  core.shell = {
    includes = [
      <core/cli/fastfetch>
      <core/cli/essentials>
      <core/cli/tui>
      <core/cli/omp>
      <core/cli/yazi>
    ];
    homeManager = {pkgs, ...}: {
      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting
          fastfetch
          set -gx SOPS_AGE_KEY_FILE "$HOME/.config/sops-nix/keys.txt"
          set -gx CONTEXT7_API_KEY (cat ~/.config/sops-nix/secrets/CONTEXT7_API_KEY 2>/dev/null; or echo "")
          set -gx BRAVE_API_KEY (cat ~/.config/sops-nix/secrets/BRAVE_API_KEY 2>/dev/null; or echo "")
          set -gx CLAUDE_CODE_OAUTH_TOKEN (cat ~/.config/sops-nix/secrets/CLAUDE_TOKEN 2>/dev/null)
          set -gx EXA_API_KEY (cat ~/.config/sops-nix/secrets/EXA_API_KEY 2>/dev/null)
          set -gx EDITOR nvim
          set -gx RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/ripgreprc"
          # set -gx DOCKER_HOST unix://$XDG_RUNTIME_DIR/podman/podman.sock
          fish_add_path ~/.bun/bin
          fish_add_path ~/.local/bin
        '';
        functions.fish_user_key_bindings.body = "fish_vi_key_bindings default";
        shellAliases = {
          ll = "eza --long --icons";
          ls = "eza --all";
          cd = "z";
          cat = "bat";
          grep = "rg";
        };
        plugins = with pkgs.fishPlugins; [
          {
            name = "fzf-fish";
            inherit (fzf-fish) src;
          }
          {
            name = "done";
            inherit (done) src;
          }
          {
            name = "git";
            inherit (plugin-git) src;
          }
        ];
        completions.opencode = "complete -c opencode -f -a \"(opencode --get-yargs-completions (commandline -opc) 2>/dev/null)\"";
      };

      home.sessionVariables = {
        EDITOR = "nvim";
      };
    };
  };
}
