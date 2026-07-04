{self, ...}: {
  core.cli.omp = {
    homeManager = {
      programs.oh-my-posh = {
        enable = true;
        configFile = "${self}/config/omp/andrew.omp.json";
      };
    };
  };
}
