{__findFile, ...}: {
  core.desktop = {host, ...}: {
    includes = [
      <core.desktop.xserver>
      <core.desktop.login>
      <core.desktop.misc>
      (
        if host.wm == "hyprland"
        then <core.desktop.wm.hyprland>
        else <core.desktop.wm.niri>
      )
    ];
  };
}
