{__findFile ? __findFile, ...}: {
  andrew.terminals = terminal:
    <den.lib.parametric> {
      includes = [
        (<andrew.alacritty> terminal)
        (<andrew.wezterm> terminal)
      ];
    };
}
