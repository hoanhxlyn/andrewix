{inputs, ...}: {
  flake-file.inputs.helium = {
    url = "github:oxcl/nix-flake-helium-browser";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  den.aspects.my.browsers.helium = {
    nixos = {
      imports = [
        inputs.helium.nixosModules.default
      ];
      programs.helium = {
        enable = true;
        flags = [
          "--enable-features=TouchpadOverscrollHistoryNavigation,VerticalTabs"
          "--start-maximized"
        ];
        policies = {
          "BrowserSignin" = 0;
          "PasswordManagerEnabled" = false;
          "SyncDisabled" = true;
          "SpellcheckEnabled" = true;
          "SpellcheckLanguage" = ["en-US"];
          # "DefaultSearchProviderEnabled" = true;
          # "DefaultSearchProviderSearchURL" = "https://search.nixos.org/?q={searchTerms}";
          "ExtensionInstallForcelist" = [
            # Pre-install extensions
            "oboonakemofpalcgghocfoadofidjkkk"
            "fmkadmapgofadopljbjfkapdkoienihi"
          ];
        };
      };
    };
  };
}
