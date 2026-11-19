# Commands

All project tasks go through the Justfile (dev shell provides just, alejandra, statix, deadnix, gh).

- just fmt — attr-style rewrite + alejandra. Run BEFORE commit.
- just lint — statix + deadnix + comment-marker check.
- just attr --check — fail instead of rewrite dotted-path violations.
- just build <host> — eval-safe build WITHOUT sudo (host defaults to hostname -s). Run before test.
- just test <host> — needs sudo, check against running system.
- just switch <host> / boot <host> — apply; needs sudo.
- just vm <host> — build + run test VM, host store untouched.
- just update — write-flake + nix flake update (no commit).
- just search <pkg> — nps -e <pkg> in fzf.
- just gc / clean-up — wipe old gens + store GC (sudo; homelab GCs itself weekly).
- just list-gen — nixos-rebuild list-generations.
- git add any NEW module file before just build.
