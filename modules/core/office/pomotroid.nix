{self, ...}: {
  core.office.pomotroid.homeManager = {pkgs, ...}: {
    home.packages = [
      (pkgs.callPackage "${self}/packages/pomotroid" {})
    ];
  };
}
