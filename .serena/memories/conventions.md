# Conventions

- Files kebab-case.nix, options camelCase.
- Namespace core.<name> for aspects shared by NixOS+HM. Module files: bare attrset {core.x = ...;} when no args needed; take ONLY module args actually used ({config, ...} etc.).
- Composition: den.aspects.<name>.includes = [ <core/editor/nvf> ]; angle brackets, NEVER imports.
- Big aspect split: _<name>/*.nix sub-configs path-imported from the aspect file via "${self}" (underscore dirs are not aspects). _lib, _nvf, _nwm likewise.
- Nest attribute groups only at >=4 bound children; 1-3 children use dotted paths (services.pipewire.enable = true;). Skeletons (core/den/flake-file), fn bodies, let bindings, host data exempt. Enforced by just attr.
- Booleans prefixed enable/disable. Defaults overridden with lib.mkDefault.
- Comments rare, marker-tagged only: TODO:, BUG:, NOTE:, README:. Never FIXME/HACK/XXX/shortcut. No glosses restating the line (units, ranges, value lists are fine when the line cannot show them).
- No dead code, no options/features nobody asked for (lazy-yagni policy, ponytail).
- config/<tool>/ holds raw app configs; one subfolder per tool, symlinked into ~/.config via home.file.
- sops secrets: declare under modules/core/services/sync/sops.nix sops.secrets; sops-nix env plumbing pattern: see OPENCODE_WEB_ENV / CONTEXT7_API_KEY (sops.nix + fish.nix export).
