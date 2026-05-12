{__findFile, ...}: {
  den.aspects.my.vpn.proton = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.proton-vpn
        pkgs.wireguard-tools
      ];
    };
  };
}
