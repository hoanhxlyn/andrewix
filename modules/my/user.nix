# this module configures my user over all my hosts.
{__findFile ? __findFile, ...}: {
  my.user = <den.lib.parametric> {
    includes = [
      <den/primary-user>
      (<den/user-shell> "fish")
      <andrew/terminals>
    ];
  };
}
