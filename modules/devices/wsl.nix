{__findFile, ...}: {
  den.aspects = {
    wsl.includes = [
      <core.git>
      <core.agents>
      <my/editor/nvf>
      <my/shell>
      <my/cli/essentials>
    ];

    andrew-home-wsl.provides.to-users.includes = [<wsl>];
    andrew-work-wsl.provides.to-users.includes = [<wsl>];
  };
}
