{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.development.neovim;
  neovim-config = ./neovim/config;
in {
  options.modules.development.neovim = {
    enable = lib.mkEnableOption "neovim";
  };

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      vimdiffAlias = true;

      plugins = with pkgs.vimPlugins; [
        (nvim-treesitter.withPlugins (p: [
          p.lua
          p.vim
          p.vimdoc
          p.bash
          p.diff
          p.html
          p.css
          p.powershell
          p.javascript
          p.typescript
          p.tsx
          p.regex
          p.jsdoc
          p.json
          p.query
          p.git_rebase
          p.gitcommit
          p.git_config
          p.markdown
          p.markdown_inline
          p.toml
          p.xml
          p.yaml
          p.fish
          p.kdl
          p.nix
        ]))
        nvim-treesitter-textobjects
        nvim-treesitter-context
      ];

      extraPackages = with pkgs; [
        # Tools
        mermaid-cli
        ghostscript
        tectonic
        imagemagick
        tree-sitter
        alejandra
        stylua
        biome
        shfmt
        yamlfix
        prettierd
        markdownlint-cli2
        eslint
        taplo
        kdlfmt
        cspell
        # LSPs
        vtsls
        lua-language-server
        tailwindcss-language-server
        vscode-langservers-extracted
        yaml-language-server
        nil
        # Debuggers
        vscode-js-debug
      ];
    };

    home.packages = [pkgs.fish];

    xdg.configFile.nvim = {
      source = neovim-config;
      recursive = true;
    };
  };
}
