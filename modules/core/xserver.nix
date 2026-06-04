{
  core.xserver.nixos = {pkgs, ...}: {
    services.xserver = {
      enable = true;
      autoRepeatDelay = 200;
      autoRepeatInterval = 35;
      xkb = {
        layout = "us";
        variant = "";
      };
      excludePackages = with pkgs; [xterm];
    };
  };
}
