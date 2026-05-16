{__findFile, ...}: {
  den.aspects.my.vpn.proton = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.proton-vpn
        pkgs.proton-vpn-cli
        pkgs.wireguard-tools
      ];
    };
  };
}
