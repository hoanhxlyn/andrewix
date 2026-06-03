{
  den.aspects.my.vpn.proton = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        proton-vpn
        proton-vpn-cli
        wireguard-tools
      ];
    };
  };
}
