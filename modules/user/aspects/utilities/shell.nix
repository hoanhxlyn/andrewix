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
