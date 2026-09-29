# Git

- Commit messages follow Conventional Commits: terse, imperative mood, "why over what", no AI attribution; body only
  when the why is non-obvious. Frequently uses the `caveman-commit` skill. Confidence: 0.8
- Once a drafted message is picked, a chained bare imperative ("commit then push it") authorizes the whole sequence in
  one shot — stage the touched paths, commit with the approved draft verbatim, then `git push` — with no re-confirmation
  of the message, the file list, or the destination. Pushes go straight to the tracked branch (`main`), no feature
  branch or PR step. Close out with a compact evidence line: `<short-sha> → origin/<branch>` + file count and +/−
  diffstat, plus confirmation the working tree is clean and in sync. Re-confirmed by a later bare "commit them and push" (message not restated): the agent `git reset`, staged exactly the touched paths, committed the approved subject verbatim, and pushed. Confidence: 0.75
- Wants the commit message drafted for review _before_ committing, and pushes back when it's too detailed: when offered
  several drafts (split-by-concern with bodies vs. one combined message), replies with the bare fragment "1 liner" to
  take the shortest. Default to a single conventional-commit subject line (~50 chars) with no body; only add a body if
  they ask. Don't propose multi-paragraph bodies or commit-splitting plans unprompted — if a body seems warranted,
  append one short subject-only fallback line so the terse option is already there. Confidence: 0.85
- Never wants `.commandcode/taste` changes to be their own commit and never wants "taste" mentioned in any commit
  message or body: instead, sneak the taste-file changes into the same commit as the related code/config change. So
  when grouping a staged diff into themed chunk commits, fold the taste edits into the chunk they document rather than
  giving them a `docs(taste)` subject. Confidence: 0.85
- When the index holds several unrelated changes, asks for the drafts as "1 liner, chunks theme": one *separate*
  single-subject-line conventional-commit message per themed chunk (grouped by file/topic — e.g. one for the herdr/tui
  edit, one for the i18n fix, one for the flake.lock bump), not a single combined message covering all of
  them. Expects the chunk boundaries derived from the staged diff (`git diff --cached`, grouped by path) and stated
  alongside each subject. Stops at the draft stage — that ask is only for the messages, so provide the per-chunk
  one-liners and stop; the actual staging/commit/push comes as a separate bare imperative ("commit them and push"),
  which then delegates the whole sequence to the agent. Confidence: 0.65
