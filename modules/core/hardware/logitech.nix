{
  core.hardware.logitech = {
    nixos = {
      hardware.logitech.wireless.enable = true;
      programs.solaar.enable = true;
      programs.solaar.userService.enable = true;
      programs.solaar.userService.window = "hide";
    };
    homeManager = {lib, ...}: {
      # G703 stores 800 DPI in onboard Profile 1, which Solaar cannot rewrite. Keep the profile off and
      # reset DPI to 1200 on every rebuild; runtime changes persist between rebuilds.
      home.activation.solaarDpi = lib.hm.dag.entryAfter ["writeBoundary"] ''
        cfg="$HOME/.config/solaar/config.yaml"
        systemctl --user stop solaar.service 2>/dev/null || true
        if [ -s "$cfg" ]; then
          sed -i -E 's/^  dpi: .*/  dpi: 1200/; s/^  onboard_profiles: .*/  onboard_profiles: 0/' "$cfg"
        fi
        systemctl --user start solaar.service 2>/dev/null || true
      '';
    };
  };
}
