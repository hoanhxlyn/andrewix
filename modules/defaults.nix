{__findFile ? __findFile, ...}: {
  den.default.includes = [
    <den/define-user>
    <den/primary-user>
    <my/nix-settings>
    <my/state-version>
    (<den/user-shell> "fish")
    ({host, ...}: {
      ${host.class}.networking.hostName = host.hostName;
    })
  ];
}
