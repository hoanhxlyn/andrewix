{
  core.desktop.xserver = {
    nixos = {
      pkgs,
      host,
      ...
    }: {
      services.xserver = {
        enable = true;
        autoRepeatDelay = host.input.keyboard.repeatDelay;
        autoRepeatInterval = builtins.div 1000 host.input.keyboard.repeatRate;
        xkb.layout = host.input.keyboard.layout;
        xkb.variant = "";
        excludePackages = with pkgs; [xterm];
      };
    };
  };
}
