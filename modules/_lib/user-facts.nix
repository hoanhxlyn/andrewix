# User fact options: what a profile (settings.profiles.<name>) may carry.
# Imported by modules/schema.nix; aspects read them as `user.<fact>`.
{lib}: let
  inherit (lib) mkOption types;
in {
  # No default: a user without git identity fails at eval instead of committing as nobody.
  git = mkOption {
    type = types.submodule {
      options = {
        name = mkOption {type = types.str;};
        email = mkOption {type = types.str;};
      };
    };
  };
  # Shown as the browser profile name; separate from the git author name.
  displayName = mkOption {type = types.str;};
}
