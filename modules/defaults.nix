{
  __findFile,
  lib,
  den,
  ...
}: {
  den = {
    default = {
      includes = [
        <den/define-user>
        <den/primary-user>
        <den/hostname>
        <den/define-user>
        (<den/user-shell> "fish")
        <den/mutual-provider>
        (den._.import-tree._.host ../hosts)
        den._.self'
        den._.inputs'
        <my/nix-settings>
        <my/state-version>
      ];
      nixos = {
        home-manager.backupFileExtension = "bak";
      };
    };
    schema.user.classes = lib.mkDefault ["homeManager"];
  };
}
