# Typed host facts. Defaults and validation come from the option definitions in
# _lib/facts.nix; aspects read them as `host.<fact>`, never by hostname.
{lib, ...}: {
  den.schema.host = {config, ...}: {
    # Relative import on purpose: this module is evaluated while the flake
    # outputs are computed, so touching `self` here is infinite recursion.
    options = import ./_lib/facts.nix {inherit lib config;};
  };
}
