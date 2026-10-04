{__findFile, ...}: {
  core.services.includes = [
    <core.services.sync.rclone>
    <core.services.sync.keepassxc>
    <core.services.sync.sops>
    <core.services.sync.stylix>
    <core.services.vpn.proton>
    <core.services.vm.podman>
  ];
}
