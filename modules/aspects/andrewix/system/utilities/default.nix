{
  __findFile ? __findFile,
  den,
  ...
}: {
  andrewix.system.utilities = den.lib.parametric {
    includes = [
      <andrewix/system/utilities/power-management>
    ];
  };
}
