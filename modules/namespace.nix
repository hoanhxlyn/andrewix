{
  inputs,
  den,
  ...
}: {
  imports = [
    (inputs.den.namespace "core" true)
  ];

  _module.args.__findFile = den.lib.__findFile;
}
