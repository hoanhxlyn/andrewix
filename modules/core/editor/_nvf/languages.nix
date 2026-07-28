{
  enableFormat = true;
  enableTreesitter = true;
  enableDAP = false;
  enableExtraDiagnostics = true;
  bash.enable = true;
  css.enable = true;
  css.format.type = [
    "biome"
    "prettier"
  ];
  scss.enable = true;
  scss.format.type = ["prettier"];
  html.enable = true;
  html.lsp.servers = ["superhtml"];
  jq.enable = true;
  json.enable = true;
  just.enable = true;
  lua = {
    enable = true;
    extraDiagnostics.types = ["selene"];
    lsp.lazydev.enable = true;
  };
  markdown = {
    enable = true;
    extensions.markview-nvim.enable = false;
    lsp.servers = [
      "markdown-oxide"
    ];
    format.type = [
      "prettier"
    ];
  };
  nix.enable = true;
  toml.enable = true;
  typescript = {
    enable = true;
    extensions.ts-error-translator.enable = true;
    extraDiagnostics.types = [
      "biomejs"
      "eslint_d"
    ];
    format.type = [
      "biome"
      "prettier"
    ];
    lsp.servers = ["typescript-go"];
  };
  yaml.enable = true;
  fish.enable = true;
  xml.enable = true;
}
