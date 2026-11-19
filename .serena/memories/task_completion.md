# Task completion checklist

1. just fmt (rewrites; check diff).
2. just lint (statix + deadnix + markers; just attr --check if dotted-path rules could trip).
3. just build <host> — catches eval errors without sudo. ALWAYS run after touching modules/.
4. just test <host> when feasible (needs sudo, runs against live system).
5. NEVER commit without fmt+lint green. New module files must be git added before build.
No unit tests exist; do not add them — build/test IS the pipeline.
