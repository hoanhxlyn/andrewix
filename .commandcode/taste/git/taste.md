# Git

- Commit messages follow Conventional Commits: terse, imperative mood, "why over what", no AI attribution; body only
  when the why is non-obvious. Frequently uses the `caveman-commit` skill. Confidence: 0.8
- Once a drafted message is picked, a chained bare imperative ("commit then push it") authorizes the whole sequence in
  one shot — stage the touched paths, commit with the approved draft verbatim, then `git push` — with no re-confirmation
  of the message, the file list, or the destination. Pushes go straight to the tracked branch (`main`), no feature
  branch or PR step. Close out with a compact evidence line: `<short-sha> → origin/<branch>` + file count and +/−
  diffstat, plus confirmation the working tree is clean and in sync. Confidence: 0.65
- Wants the commit message drafted for review _before_ committing, and pushes back when it's too detailed: when offered
  several drafts (split-by-concern with bodies vs. one combined message), replies with the bare fragment "1 liner" to
  take the shortest. Default to a single conventional-commit subject line (~50 chars) with no body; only add a body if
  they ask. Don't propose multi-paragraph bodies or commit-splitting plans unprompted — if a body seems warranted,
  append one short subject-only fallback line so the terse option is already there. Confidence: 0.85
