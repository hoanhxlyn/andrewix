{__findFile, ...}: {
  core.shell = {host, ...}: {
    includes = [
      (<den/batteries/user-shell> host.terminal.shell)
      <core.shell.fish>
      <core.cli.fastfetch>
      <core.cli.essentials>
      <core.cli.tui>
      <core.cli.omp>
      <core.cli.yazi>
      <core.mux>
    ];
  };
}
