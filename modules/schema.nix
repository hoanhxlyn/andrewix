# Typed host facts. Defaults and validation come from the option definitions in
# _lib/facts.nix; aspects read them as `host.<fact>`, never by hostname.
{
  lib,
  self,
  ...
}: {
  den.schema.host = {config, ...}: {
    options = import "${self}/modules/_lib/facts.nix" {inherit lib config;};
  };
}
