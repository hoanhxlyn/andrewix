# Task completion checklist

1. just fmt (rewrites; check the diff).
2. just lint (statix + deadnix + markers); just attr --check when the dotted-path rule may trip.
3. just build <host> — ALWAYS after touching modules/; catches eval errors without sudo.
4. just test <host> when feasible (needs sudo, runs against the live system).
5. NEVER commit without fmt+lint green. New .nix files must be git added before build.

No unit tests exist for the Nix config; build/test IS the pipeline. For changes under web/, the gate is in `mem:web/core` (bun check + biome + test + build).
