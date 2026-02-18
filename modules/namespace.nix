{
  inputs,
  den,
  ...
}: {
  # Create the andrewix namespace for shared aspects
  # Create the my namespace for private aspects
  imports = [
    (inputs.den.namespace "andrewix" true)
    (inputs.den.namespace "my" false)
  ];

  # Enable den angle brackets syntax
  _module.args.__findFile = den.lib.__findFile;
}
