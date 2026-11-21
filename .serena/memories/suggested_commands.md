# Commands

Every project task goes through the Justfile (dev shell provides just, alejandra, statix, deadnix, gh). `just l` lists all recipes.

- just fmt — attr-style rewrite, then alejandra. Run BEFORE commit.
- just lint — statix + deadnix + comment-marker check.
- just attr [--check] — dotted-path flattening; --check fails instead of rewriting.
- just comments — the comment-marker check alone.
- just build [host] — eval-safe build, no sudo (host defaults to `hostname -s`). Run before test.
- just test [host] — needs sudo, checks against the running system.
- just switch [host] / just boot [host] — apply now / at next boot.
- just vm [host] — build + run test VM, host store mounted, disk untouched.
- just iso — build the installer ISO.
- just update — fzf multi-select flake inputs + nix flake update (no commit).
- just rollback — pick a system generation via fzf.
- just list-gen — nix profile history of system generations.
- just gc — wipe system/profile gens older than 3d + nix store gc (sudo).
- just search <pkg> — nps in fzf; just schemes — base16 scheme picker.
- just homelab — ssh to the homelab once the tailnet is up.
- git add any NEW .nix file before just build (flakes ignore untracked files).
- web/ uses bun, not nix: `mem:web/core`.
