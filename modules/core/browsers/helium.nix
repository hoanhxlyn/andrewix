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
        AVATAR_SRC="$HOME/Pictures/Camera/avatar.jpg"
        AVATAR_DST="$HOME/.config/net.imput.helium/Default/Custom Avatar Picture.png"
        if [ ! -f "$PREFS" ]; then
          mkdir -p "$(dirname "$PREFS")"
          echo '{}' > "$PREFS"
        fi
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
            },
            "ntp": {
              "shortcutstype": 1
            },
            "intl": {
              "selected_languages": "en-US,en,ja"
            },
            "profile": {
              "name": "Andrew Nguyen",
              "using_default_name": false,
              "avatar_index": 26,
              "using_custom_avatar": true,
              "using_default_avatar": false,
              "using_gaia_avatar": false
            }
          }' "$PREFS" > "$TMP" && mv "$TMP" "$PREFS"
        fi
        if [ -f "$AVATAR_SRC" ]; then
          ${pkgs.imagemagick}/bin/convert "$AVATAR_SRC" "$AVATAR_DST"
        fi
      '';
    };
  };
}
