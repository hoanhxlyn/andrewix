{
  pkgs,
  self,
  ...
}: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      fastfetch -c examples/13.jsonc
      # API keys should be set via environment variables or secrets management
      # Example: set -gx TAVILY_API_KEY (cat ~/.secrets/tavily_api_key)
      # Example: set -gx CONTEXT_7_API_KEY (cat ~/.secrets/context7_api_key)
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
  programs.oh-my-posh = {
    enable = true;
    configFile = "${self}/andrew.omp.json";
  };
}
