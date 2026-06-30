{inputs, ...}: {
  flake-file.inputs.helium = {
    url = "github:oxcl/nix-flake-helium-browser";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  core.browsers.helium = {
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
          "ShowHomeButton" = true;
          "ExtensionInstallForcelist" = [
            # Pre-install extensions
            "oboonakemofpalcgghocfoadofidjkkk"
            "fmkadmapgofadopljbjfkapdkoienihi"
          ];
        };
      };
    };
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.activation.heliumPreferences = lib.hm.dag.entryAfter ["writeBoundary"] ''
        PREFS="$HOME/.config/net.imput.helium/Default/Preferences"
        if [ -f "$PREFS" ]; then
          TMP=$(mktemp)
          ${pkgs.jq}/bin/jq '. * {
            "helium": {
              "browser": {
                "centered_location_bar": true,
                "layout": 2,
                "minimal_location_bar": true,
                "new_tab_next_to_active": true,
                "vertical_right_aligned": false,
                "zen_mode": true,
                "zen_mode_sidebar_pinned": true,
                "zen_mode_top_chrome_pinned": true
              }
            },
            "browser": {
              "show_home_button": true,
              "theme": { "is_grayscale2": true }
            }
          }' "$PREFS" > "$TMP" && mv "$TMP" "$PREFS"
        fi
      '';
    };
  };
}
