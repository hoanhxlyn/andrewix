{__findFile, ...}: {
  den.aspects = {
    wsl.includes = [
      <core.git>
      <core.agents>
      <core/editor/nvf>
      <core/desktop/stylix>
      <core/shell>
      <core.sync.sops>
      <core.timezone>
      <core.vm.podman>
    ];

    andrew-home-wsl.provides.to-users.includes = [<wsl>];
    andrew-work-wsl.provides.to-users.includes = [<wsl>];
  };
}
