{
  lib,
  L,
}: {
  enable = true;
  formatOnSave = true;
  inlayHints.enable = true;
  lspconfig.enable = true;
  mappings = {
    codeAction = L "ca";
    nextDiagnostic = "]d";
    previousDiagnostic = "[d";
    listDocumentSymbols = null; # use global <leader>lS mini picker instead of native
    renameSymbol = L "cr";
    signatureHelp = "<c-/>";
  };
  presets = {
    tailwindcss-language-server.enable = true;
    typescript-go.enable = true;
    vscode-css-language-server.enable = true;
  };
  servers = {
    typescript-go.filetypes = [
      "typescript"
      "javascript"
      "typescriptreact"
      "javascriptreact"
    ];

    tailwindcss-languages-server.settings.tailwindCSS.classFunctions = [
      "cva"
      "cx"
      "tv"
    ];
    nil.settings = {
      nil.nix.flake.autoArchive = true;
    };
    vscode-css-language-server.settings.css.lint.unknownAtRules = "ignore";
    jsonls = {
      filetypes = ["json" "jsonc" "bak"];
      settings.json = {
        format.enable = false;
        schemas = lib.generators.mkLuaInline ''
          require("schemastore").json.schemas({
            extra = {
              {
                description = "Shadcn JSON schema",
                fileMatch = { "components.json" },
                name = "components.json",
                url = "https://ui.shadcn.com/schema.json",
              },
              {
                description = "Lua_ls JSON schema",
                fileMatch = { ".luarc.json" },
                name = ".luarc.json",
                url = "https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json",
              },
            },
          })
        '';
      };
    };
    yamlls.settings.yaml = {
      schemaStore = {
        enable = false;
        url = "";
      };
      schemas = lib.generators.mkLuaInline ''require("schemastore").yaml.schemas()'';
    };
  };
}
