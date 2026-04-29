{__findFile, ...}: {
  den.aspects.my._.vpn._.proton = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.proton-vpn
        pkgs.wireguard-tools
      ];
    };
  };
}
