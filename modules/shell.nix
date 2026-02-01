{ pkgs, ... }@inputs:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      			set fish_greeting
      			fastfetch -c examples/13.jsonc
            set -gx TAVILY_API_KEY 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
            set -gx CONTEXT_7_API_KEY ctx7sk-59f29886-91a0-408f-86a2-0c32e0e43f21
            set -u EDITOR nvim
      			'';
    shellAliases = {
      rev = "nh os switch";
      clean = "nh clean all";
      update = "nix flake update";
      ll = "eza --long --icons";
      ls = "eza --all";
      cd = "z";
      cat = "bat";
      grep = "rg";
      man = "tldr";
    };
    plugins = [
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
      {
        name = "git";
        src = pkgs.fishPlugins.plugin-git.src;
      }
    ];
  };
  programs.oh-my-posh = {
    enable = true;
    configFile = "${inputs.self}/andrew.omp.json";
  };
}
