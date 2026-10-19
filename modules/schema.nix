# Typed host and user facts. Defaults and validation come from the option definitions in
# _lib/host-facts.nix and _lib/user-facts.nix; aspects read them as `host.<fact>` / `user.<fact>`,
# never by hostname.
{lib, ...}: {
  # Relative imports on purpose: this module is evaluated while the flake
  # outputs are computed, so touching `self` here is infinite recursion.
  den.schema.host = {config, ...}: {
    options = import ./_lib/host-facts.nix {inherit lib config;};
  };
  den.schema.user = {
    options = import ./_lib/user-facts.nix {inherit lib;};
  };
}
