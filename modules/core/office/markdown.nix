{__findFile, ...}: {
  core.office.markdown = {
    includes = [
      (<den/batteries/unfree> ["obsidian"])
    ];
    homeManager = {
      programs.obsidian.enable = true;
      programs.obsidian.defaultSettings.appearance.nativeMenus = true;
      programs.obsidian.defaultSettings.app.readableLineLength = false;
      programs.obsidian.defaultSettings.app.strictLineBreaks = true;
    };
  };
}
