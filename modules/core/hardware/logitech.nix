{
  core.hardware.logitech = {
    nixos = {
      hardware.logitech.wireless.enable = true;
      programs.solaar.enable = true;
      programs.solaar.userService.enable = true;
      programs.solaar.userService.window = "hide";
    };
    homeManager = {
      lib,
      host,
      ...
    }: {
      home.activation.solaarDpi = lib.hm.dag.entryAfter ["writeBoundary"] ''
        cfg="$HOME/.config/solaar/config.yaml"
        systemctl --user stop solaar.service 2>/dev/null || true
        if [ -s "$cfg" ]; then
          sed -i -E 's/^  dpi: .*/  dpi: ${toString host.input.mouse.defaultDpi}/; s/^  onboard_profiles: .*/  onboard_profiles: 0/' "$cfg"
        fi
        systemctl --user start solaar.service 2>/dev/null || true
      '';
    };
  };
}
