{__findFile, ...}: {
  andrew.vpn.provides.proton = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.proton-vpn
        pkgs.wireguard-tools
      ];
    };
  };
}
