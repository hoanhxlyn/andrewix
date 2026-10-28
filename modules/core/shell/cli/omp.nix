{self, ...}: {
  core.cli.omp = {
    homeManager = {
      programs.oh-my-posh.enable = true;
      programs.oh-my-posh.configFile = "${self}/config/omp/andrew.omp.json";
    };
  };
}
