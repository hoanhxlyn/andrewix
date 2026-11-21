# Conventions

- Files kebab-case.nix, options camelCase.
- Namespace core.<name> for aspects shared by NixOS + HM. Module files: bare attrset {core.x = ...;} when no args are needed; take ONLY the module args actually used ({config, ...}).
- Composition: den.aspects.<name>.includes = [ <core/editor/nvf> ]; angle brackets, NEVER imports.
- Big aspect split: _<name>/*.nix sub-configs path-imported from the aspect file via "${self}" (underscore dirs are not aspects). Same for _lib, _nvf, _nwm.
- Nest option groups only at >=4 bound children; 1-3 children use dotted paths (services.pipewire.enable = true;). Skeletons (core/den/flake-file), nixos/homeManager function bodies, let bindings and host data are exempt. Enforced by just attr.
- Booleans prefixed enable/disable. Defaults overridden with lib.mkDefault.
- Comments rare and marker-tagged: TODO: (actionable, name the upstream trigger), BUG:, NOTE: (why a workaround exists), README: (link). Never FIXME/HACK/XXX/WORKAROUND/shortcut/ponytail — just comments rejects them. No glosses restating the line (units, ranges and value lists are fine when the line cannot show them).
- No dead code, no options/features nobody asked for (lazy-yagni policy, ponytail).
- config/<tool>/ holds raw app configs; one subfolder per tool, symlinked into ~/.config via home.file.
- sops secrets: declare under modules/core/services/sync/sops.nix sops.secrets; env plumbing pattern: OPENCODE_WEB_ENV / CONTEXT7_API_KEY (sops.nix + fish.nix export).
- web/ has its own conventions (TS, styling, tests) — `mem:web/core`.
