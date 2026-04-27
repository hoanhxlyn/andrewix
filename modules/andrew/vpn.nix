{__findFile, ...}: {
  den.aspects.andrew._.vpn._.proton = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.proton-vpn
        pkgs.wireguard-tools
      ];
    };
  };
}
