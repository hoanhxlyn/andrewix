{
  __findFile ? __findFile,
  lib,
  ...
}: {
  den = {
    default = {
      includes = [
        <den/define-user>
        <den/primary-user>
        <my/nix-settings>
        <my/state-version>
        (<den/user-shell> "fish")
        ({host, ...}: {
          ${host.class}.networking.hostName = host.hostName;
        })
      ];

      user.classes = lib.mkDefault ["homeManager"];
    };
  };
}
