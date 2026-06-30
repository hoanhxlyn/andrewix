{__findFile, ...}: {
  den.aspects = {
    wsl.includes = [
      <core.git>
      <core.agents>
      <core/editor/nvf>
      <core/shell>
    ];

    andrew-home-wsl.provides.to-users.includes = [<wsl>];
    andrew-work-wsl.provides.to-users.includes = [<wsl>];
  };
}
