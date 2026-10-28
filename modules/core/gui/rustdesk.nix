{__findFile, ...}: {
  core.gui.rustdesk = {
    # libsciter: unfree proprietary UI toolkit that rustdesk links against
    includes = [(<den.batteries.unfree> ["libsciter"])];
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.rustdesk];
    };
  };
}
