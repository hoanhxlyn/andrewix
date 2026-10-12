{inputs, ...}: {
  flake-file.inputs.opencode = {
    url = "github:sst/opencode/v2";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake-file.inputs.nwm = {
    url = "github:BirdeeHub/nix-wrapper-modules";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  core.agents.opencode.homeManager = {
    pkgs,
    osConfig,
    lib,
    config,
    ...
  }: let
    isWsl = osConfig.wsl.enable or false;
    opencodePkgs = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    imports = lib.optionals (!isWsl) [
      (inputs.nwm.lib.getInstallModule {
        name = "opencode-desktop";
        value = {wlib, ...}: {
          imports = [wlib.modules.makeWrapper];
          config.binName = "opencode-desktop";
        };
      })
    ];

    # ponytail: nix build stamps CLI with OPENCODE_CHANNEL=prod so it writes
    # service-prod.json, while packaged desktop only reads service.json;
    # drop the symlink + --no-sandbox when upstream aligns the channels.
    wrappers.opencode-desktop = lib.mkIf (!isWsl) {
      enable = true;
      package = opencodePkgs.opencode-desktop;
      flags."--no-sandbox" = true;
    };

    home.packages = lib.optionals (!isWsl) [
      config.wrappers.opencode-desktop.wrapper
    ];

    home.activation.opencodeDesktopServiceLink = lib.mkIf (!isWsl) (lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p "$HOME/.local/state/opencode"
      ln -sf service-prod.json "$HOME/.local/state/opencode/service.json"
    '');

    programs.opencode = {
      enable = true;
      package =
        if isWsl
        then null
        else opencodePkgs.opencode;
      enableMcpIntegration = true;
      web.enable = !isWsl;
      settings = {
        update = "disable";
        plugins = [
          "@dietrichgebert/ponytail"
        ];
        formatter = {
          nixfmt = {
            disabled = true;
          };
          alejandra = {
            command = [
              "alejandra"
              "$FILE"
            ];
            extensions = [".nix"];
          };
        };
        permissions = [
          {
            action = "shell";
            resource = "*";
            effect = "ask";
          }
          {
            action = "shell";
            resource = "git *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "bun *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "bunx *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "npm *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "grep *";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "rg *";
            effect = "allow";
          }
          {
            action = "edit";
            resource = "*";
            effect = "ask";
          }
          {
            action = "external_directory";
            resource = "~/Projects/*";
            effect = "allow";
          }
          {
            action = "external_directory";
            resource = "~/.config/*";
            effect = "allow";
          }
          {
            action = "external_directory";
            resource = "~/.cache/*";
            effect = "allow";
          }
          {
            action = "external_directory";
            resource = "~/.local/*";
            effect = "allow";
          }
          {
            action = "external_directory";
            resource = "/nix/store/*";
            effect = "allow";
          }
        ];
      };
    };
  };
}
