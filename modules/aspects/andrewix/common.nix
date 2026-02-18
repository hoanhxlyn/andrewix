{
  __findFile ? __findFile,
  den,
  ...
}: {
  andrewix.common = den.lib.parametric {
    includes = [
      <andrewix/system/unfree>
      <andrewix/system/overlays>
      <andrewix/system/core>
      <andrewix/system/desktop>
      <andrewix/system/utilities>
      <den/home-manager>
      <den/define-user>
    ];
  };
}
