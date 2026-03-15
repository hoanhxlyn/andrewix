{__findFile, ...}: {
  andrew.vpn.provides.proton = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.protonvpn-gui
        pkgs.wireguard-tools
      ];
    };
  };
}
