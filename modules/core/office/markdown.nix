{__findFile, ...}: {
  core.office.markdown = {
    includes = [
      (<den/batteries/unfree> ["obsidian"])
    ];
    homeManager = {
      programs.obsidian = {
        enable = true;
        defaultSettings = {
          appearance.nativeMenus = true;
          app.readableLineLength = false;
          app.strictLineBreaks = true;
        };
      };
    };
  };
}
