{
  core.agents.opencode.homeManager = {
    pkgs,
    osConfig,
    ...
  }: {
    programs.opencode = {
      enable = true;
      package =
        if (osConfig.wsl.enable or false)
        then null
        else pkgs.opencode;
      enableMcpIntegration = true;
      web.enable = !(osConfig.wsl.enable or false);
      settings = {
        autoupdate = false;
        plugin = [
          "@dietrichgebert/ponytail"
        ];
        lsp = {
          nix = {
            command = ["nil"];
            extensions = [".nix"];
          };
        };
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
        permission = {
          edit = "ask";
          bask = {
            "*" = "ask";
            "git *" = "allow";
            "bun *" = "allow";
            "bunx *" = "allow";
            "npm *" = "allow";
            "grep *" = "allow";
            "rg *" = "allow";
          };
          write = "ask";
          external_directory = {
            "~/Projects/**" = "allow";
            "~/.config/**" = "allow";
            "~/.cache/**" = "allow";
            "~/.local/**" = "allow";
            "/nix/store/**" = "allow";
          };
        };
        command = {
          commit = {
            description = "Auto generate commit message";
            template = "Generate a git convention message for changes. DO NOT commit them !";
          };
        };
      };
    };
  };
}
