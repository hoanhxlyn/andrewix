{__findFile, ...}: {
  core.gui.rustdesk = {
    # libsciter: unfree proprietary UI toolkit that rustdesk links against
    includes = [(<den.batteries.unfree> ["libsciter"])];
    homeManager = {pkgs, ...}: {
      # shortcut: Flutter settings windows never render under Wayland (niri),
      # XWayland fixes them; drop the wrapper once upstream supports Wayland
      home.packages = [
        (pkgs.symlinkJoin {
          name = "rustdesk-xwayland";
          paths = [pkgs.rustdesk];
          nativeBuildInputs = [pkgs.makeWrapper];
          postBuild = ''
            wrapProgram $out/bin/rustdesk --set GDK_BACKEND x11
          '';
        })
      ];
    };
  };
}
