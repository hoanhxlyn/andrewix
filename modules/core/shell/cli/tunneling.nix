{
  core.cli.tunneling = {
    homeManager = {
      config,
      pkgs,
      ...
    }: {
      home.packages = with pkgs; [ngrok];
      sops.secrets.NGROK_AUTHTOKEN = {};
      sops.templates."ngrok.yml".path = "${config.xdg.configHome}/ngrok/ngrok.yml";
      sops.templates."ngrok.yml".mode = "0600";
      sops.templates."ngrok.yml".content = ''
        version: "3"
        agent:
          authtoken: ${config.sops.placeholder.NGROK_AUTHTOKEN}
          console_ui_color: transparent
      '';
    };
  };
}
