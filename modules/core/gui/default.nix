{__findFile, ...}: {
  core.gui = {
    includes = [
      <core.gui.discord>
      <core.gui.caprine>
    ];
    homeManager = {
      programs.dbeaver.enable = true;
    };
  };
}
