{
  inputs,
  den,
  ...
}: {
  imports = [
    (inputs.den.namespace "andrew" false)
    (inputs.den.namespace "my" false)
  ];

  _module.args.__findFile = den.lib.__findFile;
}
