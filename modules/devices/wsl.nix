{__findFile, ...}: {
  den.aspects.andrew-wsl = {
    provides.to-users.includes = [
      <core.git>
      <core.agents>
      <my/editor/neovix>
      <my/shell>
      <my/cli/essentials>
    ];
  };
}
