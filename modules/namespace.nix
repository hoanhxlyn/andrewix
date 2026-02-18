{
  inputs,
  den,
  ...
}: {
  # Create the andrewix namespace for shared aspects
  imports = [
    (inputs.den.namespace "andrewix" true)
  ];

  # Enable den angle brackets syntax
  _module.args.__findFile = den.lib.__findFile;
}
