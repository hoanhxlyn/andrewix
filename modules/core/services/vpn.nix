{
  core.vpn.proton = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        proton-vpn-cli
        wireguard-tools
      ];
    };
  };
}
