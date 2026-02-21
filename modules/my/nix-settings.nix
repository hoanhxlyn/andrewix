let
  my.nix-settings = {
    nixos = nix-settings;
  };

  nix-settings = {
    nix = {
      optimise.automatic = true;
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users = [
          "root"
          "@wheel"
        ];
      };
    };
  };
in {
  inherit my;
}
