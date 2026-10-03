# Workflow

- Verify/research before implementing: search the web and docs (web search, context7, Tavily) and confirm package
  availability (e.g. `nps -e`) before writing config. Confidence: 0.75
- When asking how a third-party module/flake option behaves, explicitly directs the agent to "research" it first —
  expects answers grounded in the upstream source actually resolved on the machine (flake.lock → nix store / cache), not
  from memory or docs summaries. Confidence: 0.7
- Audits the agent's sourcing after the fact — asks outright "did you use MCP tool to read the docs?" and expects a
  transparent accounting of which tools/MCP servers were called, what they returned, and where they fell short versus
  raw source inspection. Confidence: 0.6
- Bare yes/no provenance probe on config _key names_ the agent just wrote — "Have you checked with herdr about the
  correct `custom.<key>` ?" — fired after the edit already landed. Docs are NOT accepted as the authority for exact
  option spelling, because they track the latest release while their flake pins an older one (here 0.9.1) and key sets
  drift between snapshots. Expected move: admit the gap in one line ("No — I took those names from doc excerpts"), then
  resolve names against the _installed_ artifact — run the pinned binary's own config dump (`--default-config`) via the
  flake's `legacyPackages`/store path, and if possible feed the agent's exact key set back to the tool to see whether it
  complains. Answer the probe with a verdict ("all N keys exist in 0.9.1's default config"), never with a citation of the
  docs page. Confidence: 0.8
- Points the agent at the exact config involved by pasting `@path` mentions — narrowed to a line range (`:L44-L55`) or a
  single line (`:L28`) — on the first line of the request, then the question on its own line below (often just "what
  does this mean"), expecting the agent to resolve the anchor to file:line context, infer the surrounding block, and
  explain that snippet's purpose without being told which file/repo to look in. Follow-up anchors often drop the
  question entirely — just the new `@path :L<n>` plus a bare deictic pointer ("this !") — which means "give me the same
  explanation for _this_ line too"; answer it (and any still-unanswered earlier anchor, e.g. the one the agent was
  mid-research on) without asking for clarification. An anchor may also sit inline mid-sentence instead of on its own
  line ("now inside @path at L:124, change it to our created X"). Caveat: the typed request outranks editor-supplied
  context — an attached anchor is a pointer, not a work order. Confidence: 0.8
- Watches the agent's tool calls and challenges a step that is unrelated to the stated ask — or a command that just sits
  there doing nothing visible — with a bare six-word-or-less query: "why are you reading X?" for an off-task read, "what
  are you doing" for an off-task/stalled action (e.g. a stray `hostname`/`git status` run between real steps). Expects a
  one-line admission of the tangent ("my mistake"), a restatement of what the real request is, and immediate return to
  it; no justification of why the detour was plausibly useful. Confidence: 0.6
- Wants research/lookup work done through MCP servers when one is available (e.g. context7 for library docs), and will
  correct the agent (repeating "I would like you to use mcp to aid you") when it instead falls back to shell/grep or
  local filesystem spelunking; expects MCP to be used alongside — not instead of — verifying against upstream source.
  Confidence: 0.85
- Names the specific research tools they expect by name rather than leaving the choice open — "use exa or deepwiki to
  research on implementing X" — i.e. for a question about a third-party repo/flake's integration details (outputs,
  cache keys, how to consume it), reach for the Exa MCP (web search + raw-source/page fetch) and the DeepWiki MCP
  (`ask_wiki_question` against the GitHub repo) as the primary instruments, in preference to grepping the local store
  or nixpkgs. Consequence: when a how-to-install/how-to-integrate ask arrives, open with Exa/DeepWiki queries against
  the named upstream repo before local source spelunking. Confidence: 0.6
- Ordering rule for research: docs lookup comes _first_, not as a fallback after local digging fails — corrects the
  agent with "I suggest you immediately use websearch or MCP to learn first!" when it burns several turns on `ls`/`find`
  over the nix store before consulting docs. Also applies to **negative capability claims** — never assert a tool lacks a
  feature (e.g. "direnv doesn't have auto-prune") without a docs lookup first; the user will catch and correct it ("tôi
  thấy direnv có prune mà"). Confidence: 0.8 Consequence: on an unfamiliar third-party option, call web search /
  context7 (resolve-library-id → query-docs) as the _first_ action, in parallel with reading the local config files;
  only then trace resolved source. The tolerance is near zero — a bare three-word "Use web search first" interrupted the agent after a single `grep`/`fetchTarball` over upstream sources — so the docs/web lookup (e.g. Exa web search, two queries fired in parallel) must precede the first shell-based source dive, and switching to it must be instant, not defended. The standard is now _habitual_, not merely correctly ordered — a third correction phrased as "i was expecting you to use MCP tools + websearch to try to research as your first instinct" means reaching for `nix eval`/`grep`/`ls /nix/store` before any web/MCP call is itself the failure, even when those local calls do eventually produce the answer. Fire the research tools (web_search + Exa + context7 resolve-library-id → query-docs) in the same first batch as reading the user's own config files. Confidence: 0.95
- Tests NixOS config changes in a VM (`#vm`) before committing. Confidence: 0.6
- Always set a max timeout on shell commands run in the session — explicitly advises "tôi khuyên bạn nên có max timeout" (I advise you to have a max timeout). Treats a bare `shell_command` call without `timeout` as a defect. Confidence: 0.8
- Tests proposed maintenance/cleanup commands interactively in the CLI first before accepting them as a Justfile recipe — "để tôi test thử qua cli trước khi ghi vào justfile". Wants to manually verify the command works and produces expected output before it becomes a permanent entry point. Confidence: 0.7
- Draws a privilege line around the agent session: runs the sudo-requiring step (NixOS rebuild/activation) themselves
  outside the session while letting the agent do the non-privileged validation loop (`just fmt`, `just lint`,
  `just build` — bare, no host arg —) and inspect build output/generated config — then reports real-world results back and expects a
  follow-up diagnosis. Extends to runtime diagnostics and cleanup/maintenance commands: when the agent needs system state (`wpctl status`,
  `wpctl get-volume`, `alsamixer`, `journalctl`, `systemctl`, etc.) or proposes cache/resource cleanup (`rm -rf ~/.cache/…`,
  `npm cache clean --force`, etc.), run them directly in the session rather than
  listing them for the user to execute — "run it yourself" / "you run it" is the explicit directive. Only sudo-requiring steps
  stay in the user's hands. Confidence: 0.85 This extends further: even when the agent is uncertain about the right
  syntax or flags, presenting a command as a code block with "try this:" or "use this syntax:" instead of executing it
  is itself the miss. The user will fire "làm đi" (just do it) or "thử xem" (try it) to redirect, and escalating
  frustration ("làm đi ????") means the agent has been suggesting without acting across multiple turns. Run the
  command, show output, iterate from there. Confidence: 0.9
- When presenting cleanup/maintenance options (cache dirs, disk usage), wants the agent to categorize items as safe to
  clean vs. worth keeping and make a recommendation — don't just dump a raw list and ask what to do. Prefers a table
  with size, purpose, and a keep/remove verdict. After receiving the categorization, a bare "yes" means execute the
  recommended cleanup immediately. Confidence: 0.7
- Interested in modern CLI tool alternatives to classic Unix utilities (e.g. `duf` over `df`, `dust` over `du`,
  `ncdu`/`gdu` for interactive disk analysis, `fd` over `find`). Proactively asks about replacements and is receptive
  to suggestions. When given a `find` command, substitutes `fd` on their own before running it. Will explicitly correct
  the agent with "Sử dụng fd" (use fd) if the agent falls back to `find` in shell commands — `fd` is the expected
  default for file searches, and falling back to `find` is itself a miss.
  Confidence: 0.85 Technical note: `fd` respects `.gitignore` by default, so files/dirs listed there (e.g. `.direnv`)
  require `--no-ignore` to appear in results. Failed silently twice before the cause was identified.
  Confidence: 0.9 The report is the verbatim tool output pasted as the whole message, carrying either no prose at all
  or at most a bare trailing imperative tacked on after it (e.g. the numbered `Activation (test) failed` block ending in
  `the following units failed: …fcitx5-lotus-server@andrew.service` followed only by "check what is going on ?"). That
  one-line imperative adds no scope and is not an invitation to ask what they want; the paste may also be truncated at
  the failing-unit line (rest of the error summary dropped), so fetching the missing detail is the agent's job. Read such
  a paste as "diagnose this now, unprompted": don't ask what they want, don't assume the failure is caused by the change just
  being discussed, and go pull the real cause yourself (`journalctl -u <unit> -b`, `systemctl show … -p Environment`).
  Never run sudo/activation commands. Confidence: 0.8
- Always run repo operations through the project's `just` recipes (`just fmt`, `just lint`, `just build`,
  `just switch <host>`, and the flake-regeneration step too; note `just build` takes NO host arg) — never the equivalent raw `nix run .#<host> -- build` /
  `nix run .#write-flake` / `nix flake` form, even when the agent already used `just` for the other steps in the same
  loop and even when the step is backgrounded. Holds the agent to this rule across the whole session and corrects a
  slipping step with a bare two-word pointer — just "follow @Justfile", no explanation — which means: the Justfile is
  the authoritative command list, go open it, pick the recipe that covers this step, and re-run without asking which
  one. Confidence: 0.9
- Wants the `caveman` Command Code skill to auto-activate globally at the start of every session, with ultra mode
  enabled. Confidence: 0.8
- When a hook or auto-load mechanism is configured but didn't fire, rejects manual activation as a workaround — "no, it
  will defeat the purpose of auto load". Expects the agent to investigate why the hook failed and fix the automation
  itself, not offer a one-off manual trigger as a substitute. Respects the intent behind configured automation: if it's
  set up to run automatically, making the user invoke it manually defeats the design. Confidence: 0.85
- Questions whether proposed maintenance/cleanup commands are truly necessary before accepting them into a script — "có thật sự cần thiết không" (is it really needed?) — and prefers removing a step that doesn't pull its weight (e.g. dropped `nix profile wipe-history` after confirming only 5 entries). Consequence: when proposing additions to existing scripts/Justfile recipes, verify the step has meaningful impact first and flag if it's borderline; don't add "just in case" commands. Confidence: 0.7
- Prefers simple, consolidated commands — objects to needing to "run many commands" for routine maintenance and expects the agent to merge cleanup into a single existing entry point (e.g. folding `/tmp` cleanup into `just clean-up`) rather than listing manual steps. Confidence: 0.7
- Stubs out the destination file by hand _before_ asking for content to be written into it (e.g. empty
  `config/command-code/install.fish`, then "transform it to ... in @path"). Expects the agent to stat/read that target
  before writing rather than assume it is absent; a terse contesting question ("uh i already created it ?") means "prove
  what's actually on disk" — respond with the verified fact (`ls -la` + byte count → "it's 0 bytes, so it's empty") and
  then proceed with the write, don't stop and ask permission. Confidence: 0.6
- Tracks the agent's elapsed effort and uncertainty, cutting off both sprawl and hedging. "why so long ?" when research
  sprawls (here: a sub-agent spelunking a 3.4 MB minified JS bundle), "What took you so long ?" fired right after a chain
  of `nix eval`/`nix build`/store-path detours that re-asked a question the already-fetched docs page answered, and
  "you are very unsure about simple thing..." when the agent waffles over a basic config fact — all three demand the same shape: a one-line admission of
  over-rotation/uncertainty — no defense, no recap, no continued speculation — then exactly ONE bounded check (a single
  grep/build/eval with `timeout` and `| head -N`, where relevant) targeting the exact yes/no question, stopping the
  instant it is confirmed. If the simplest verification is to delete or disable the suspect line and rebuild/run, the
  user may do it themselves; do not pile on more analysis, state the minimal test and likely verdict. Consequence for
  delegation: scope sub-agents with hard bounds (named file, named pattern, "don't dump the bundle", "read-only")
  instead of open-ended "investigate everything about X"; prefer a narrow grep to a broad audit when one fact decides
  the design. The reply that satisfied the later instance: own the waste in one clause ("burning rounds instead of going
  to the cheap decisive check"), compress the detours into a single sentence rather than a play-by-play, then split the
  result into `what's settled` / `what's still unverified` and close with the one command that would settle it plus an
  offer to run it. Confidence: 0.9
- Hand-edits files in the editor _while_ the agent is working on the same repo, and reacts sharply when a full-file
  `write_file` clobbers those edits ("wait you overwrite my previous change !"). Consequence: treat any file the user
  may have touched as theirs-first — re-read it (and diff working tree vs git index) immediately before writing, and
  make the smallest additive edit (`edit_file` append/replace of one block) instead of regenerating the whole file from
  the agent's own mental model. When challenged about a possible overwrite, don't argue from memory: prove the actual
  state from primary evidence (`cat` the working file, `git show :<path>` for the staged version, `git diff -- <path>`)
  and say plainly what was and wasn't lost. Reinforced by a bare imperative mid-edit — "read the file again" issued right
  after the agent's own `edit_file` landed, with no stated reason: the file had in fact been rewritten underneath
  (the den framework regenerates module files, so the agent's patch was gone and a different `theme.name = ""` stood in
  its place). Read such a re-read command as "your model of this file is stale" — re-read the whole file immediately,
  report what is actually on disk in one line, and only then compose the next edit against that content; never chain a
  second `edit_file` off the previous patch's assumed result. The same rule resurfaces as a bare contest of the agent's
  *verb* — "What do you mean create file ? edit file you mean ?" after the agent announced it would write the whole
  `tui.nix`: for any file that already exists in the repo there is no "create", so describing the action as a full write
  is itself the tell that the patch is too broad. Expected response: concede in one line ("full overwrite was the wrong
  tool"), re-read the file, report what is already in place, and emit an `edit_file` touching only the missing delta
  (here: the 8 accent tokens, leaving the 11 surface tokens the user had added untouched). Confidence: 0.9
- Pauses mid-task to demand a state audit — bare, punctuation-free orienting questions ("What is the problem and have we
  done?", "What is going on ?") fired while the agent is still working. Expects the agent to reconstruct progress from
  primary evidence (e.g. `git diff` of the working tree, live `journalctl`/`systemctl show` output) rather than from its
  own earlier narration, and to answer in a fixed shape: root cause → intended end-state → what is done → what is
  explicitly _not_ done (naming remaining defects, e.g. dead LSP stubs, unrun re-lint/re-build) → one question proposing
  the next step. On a multi-failure report, sort the failures by cause and label them ("the real blocker" vs "pre-existing,
  unrelated to your change"), each backed by the verbatim log lines and the command that produced them; and own any
  earlier mis-diagnosis plainly ("it wasn't an override at all, just a redundant pin — I should have said that"). Never a
  vague "almost there". Confidence: 0.7
- Rejects trial-and-error against the live system as a working mode, stated as a bare complaint with no log line and no
  question ("You were trying things i don;t like it.") after a run of improvised diagnostic probes (`lsmod`, `getfacl`,
  `udevadm info`, `systemctl cat`, `find /nix/store ...`). Read it as a standing session rule, not one-off feedback: stop
  poking the running machine, do repo-side verification only (`git log -S <term> -- modules hosts`, reading the module
  file), and land the fix as a declarative edit in the Nix module — never as ad-hoc `modprobe`/`setfacl`/`systemctl`
  commands run by hand. Acknowledge in ≤2 lines naming the mode being switched to ("no more system poking. One repo-side
  check, then the config edit."), and if a runtime fact is genuinely unavoidable, state the single decisive read-only
  command and why instead of chaining exploratory ones. Confidence: 0.85
- Intervenes on the agent's edits in-flight: rejects a proposed file edit (no prose, no reason given) and then asks what
  is going on — i.e. the patch landed before they understood the problem. Consequence: treat a rejected edit as
  withdrawn, not as a disagreement to argue; hold off on re-applying it, deliver the plain-language diagnosis they asked
  for, and close with an explicit offer ("I'll re-apply the edit you rejected if you want it") instead of silently
  re-writing the file. Confidence: 0.6
- Judges research effort against the manual check they could do themselves in seconds, and says so bluntly: "You were
  proving that you are not efficent, all i have to do was go to stylix homepage, search for herdr and i can findout that
  they don't !" — fired after ~20 `nix eval`/`grep`/`ls /nix/store`/fetch calls answering a yes/no "does upstream X
  support Y" question whose answer was one Ctrl-F on the project's homepage/docs target list. This is the _cost ceiling_
  that scopes the docs-first ordering rule: for a support-existence question, open with the single cheapest decisive page
  (upstream docs target/feature list, or `ls` of the pinned source's `modules/targets/`), return a one-line verdict, and
  only escalate to resolved-source tracing if that page is genuinely ambiguous. Producing the right answer via a long
  tool chain still counts as the failure; own it in ≤1 clause without re-listing the steps. Confidence: 0.85
- Demands verification be **one-shot and scoped to the exact pending edit**, stated in their own words: "i want to oneshot
  it not just running around". When they ask "is what you were about to write correct?", the accepted move is a *single*
  bounded check that exercises the literal artifact the edit will emit — render the generated config to a scratch dir, run
  the pinned tool's own validator against it (`XDG_CONFIG_HOME=$SCR $BIN config check`) — plus one negative control (inject
  a bogus key so an "ok" verdict actually means something), then land the edit in the same turn. Chaining `--help` dumps,
  store-path lookups, `nix build` detours and doc fetches to answer what one validator run answers is precisely the
  "running around" they are calling out. Sequence expectation: verify the exact values → write the file → done, with no
  further narration in between. Confidence: 0.85
- Standing instruction, restated formally as "After any edit to the Nix config in this repo, automatically run `just build`
  to validate the evaluation — do not wait to be asked": any edit to Nix config in the repo must be followed by the
  eval/build validation **proactively, in the same turn as the edit** — never end with "say the word and I'll run it" or
  any other offer to validate. Treat an unvalidated Nix change as an incomplete task; asking permission for the validation
  step is itself the miss. Confidence: 0.95
- Runs `just build` with **no arguments**: `just build` auto-detects the current host, so passing one — `just build
  $(hostname -s)`, or a literal host — is wrong even though other recipes (`just switch`) take a host. Called out
  explicitly after the agent did exactly that: "do not pass a hostname since `just build` auto-detects the current host".
  Corollary: don't burn a call on `hostname`/`uname -n` to figure out the target either; the bare recipe is the whole
  command. Confidence: 0.9
- Draws the floor of the agent's validation loop at `just build` success: a bare "don't bother, i will `just test`
  outside to see if it actual affect" ends the agent's turn there. Post-build forensic checks on generated artifacts
  (grepping/`sed`-ing the rendered `/nix/store/*herdr-config.toml`, re-running the tool's validator on the store copy) are
  NOT wanted — runtime/visual effect is verified by the user themselves via the repo's `just test` recipe. Expected
  response: stop immediately, don't run "one more" confirmation command, don't re-offer to check; the change is done.
  Confidence: 0.8
- Frames research tasks as an open-ended goal with **explicit tool autonomy** — "I want you to use any tool to find out
  how to install X on this NixOS" (stated in Vietnamese: "sử dụng bất kỳ tool gì để tìm hiểu") — i.e. they specify the
  _outcome_, never the method: no prescribed tool, no step list, no permission checkpoints. Expected behavior: pick and
  chain the discovery tools yourself (read the repo's existing config for the relevant module, consult docs/web/MCP,
  then confirm the package actually exists in the pinned nixpkgs), reporting the finding rather than asking which tool
  they want used. This grant of tool choice does NOT relax the docs-first ordering rule above. Confidence: 0.6
- Chains asks in one message with an explicit thread-closure marker — "So my previous question has been answered but now
  i want to know if X" — meaning: drop the resolved investigation (no recap, no summary of findings, no finishing
  leftover checks) and answer the new question in the same turn. It is almost always the feasibility/how-to follow-on of
  what was just ruled out (native support absent → "can a herdr theme be added along with stylix"), so reply: verdict →
  the mechanism that would do it → what it costs, rather than re-litigating why the native path failed.
  Confidence: 0.6
- Asks about a third-party option's behavior *generically*, explicitly cutting it loose from their own setup ("No
  related to my current config") and coupling it to an explicit sourcing order ("Search online for answer"): "what
  happened if i don't and what if i set `fzf.enableFishIntegration`. Will it true by default or not". Read this as a
  pure upstream question — do NOT scope the research to their config files, and do NOT answer from memory. Accepted
  shape: resolve which layer actually owns the option (here the option lives in Home Manager, not the NixOS
  `programs.fzf` module), then state the full default-resolution chain to its terminal value
  (`programs.fzf.enableFishIntegration` → `home.shell.enableFishIntegration` → `home.shell.enableShellIntegration` →
  `true`), note version-dependence (older HM hardcoded `default = true`; a branch fix landed only on master), then give
  the effect of each case separately — unset vs explicit `true` vs explicit `false` — including side effects that do
  NOT follow the flag (env vars like `FZF_DEFAULT_OPTS` still exported) and the enabling gate they hang off. So for
  "what is the default of X" questions, verify defaults against upstream source on both master and the relevant stable
  branches rather than assuming one answer holds across versions. Confidence: 0.6
- Gate file edits behind an explicit ask when the request is a stated goal/need rather than a direct work order — objects
  sharply ("you didn't even asked me first and just go straight editing ?") when a "i want tuning for decrease load for
  my laptop" style request is immediately followed by `edit_file` calls. Read such a request as intent to change
  something with a choice still open: present the plan (which file, what defaults are today, what changes) and a set of
  concrete labelled options with tradeoffs and value previews (e.g. Moderate/Light/Heavy throttle levels) via
  `ask_user_question`, and only edit after they pick. Accepted recovery when caught: own the miss in one line, disclose
  exactly what small edit already landed and offer to revert it, then ask. Scope: this gate applies to edits with real
  tradeoffs/choices (tuning levels, behavioral changes) — it does NOT relax the auto-validate rule (`just build` still
  runs unasked after any landed edit), and bare approvals ("yeah", "try it", or picking an option) still mean proceed
  without further confirmation. Confidence: 0.85
- When one broken package/feature blocks the whole build ("herdr is blocking everything !"), unblocks by surgically
  disabling just that one component — e.g. flipping `programs.herdr.enable = false` with a comment naming the upstream
  bug and the re-enable condition — and explicitly demands everything else stay untouched ("remove herdr update leave
  everything else untouch ?"), rejecting both a nixpkgs-input pin to the fixed rev and a local overlay/override. This
  is the minimal-delta unblock path: one-line opt-out of the blocker, comment why + when to revert, keep the rest of the
  system updating normally. Note this complements the blast-radius rule: the *safest* fix can be a temporary disable,
  not a workaround. Refinement from the next day ("revert herdr back to previous version"): the disable is a *stopgap*,
  not the end state — once the disabled component is missed, the wanted restore is the last *working* package, and the
  preferred restore path is a per-package pin (`package = <old rev's pkgs>.<name>`, binary-cache-backed, one line in the
  same module) while everything else stays on current nixpkgs, to be dropped once the channel carries the upstream fix
  — not simply re-enabling the still-broken package, and not pinning the whole nixpkgs input. The agent should derive
  which "previous version" that is from primary evidence (system generations + `flake.lock` git history) on its own;
  clarifying which *intent* was meant is acceptable, asking the user for the rev is not. Confidence: 0.6
- Treats the standalone `kurumeii/dotfiles_pc` repo as the upstream reference for their terminal-stack config and asks
  for its changes to be back-ported into the Nix flake with a bare imperative — "right, i want you to implement that
  repo herdr keys into mine" — giving no file list, no commit range, no key list. Expected: derive the delta set
  yourself (upstream `git log`/`git log -p --follow` on the file vs. the local module) and apply only the keys that
  actually differ rather than copying the file across; re-express environment-specific values in Nix idioms (remote's
  hardcoded `/home/linuxbrew/.linuxbrew/bin/fish` → `${lib.getExe pkgs.fish}`, widening the module's args when a helper
  like `lib` is newly needed); validate key names against the version actually installed, not the remote's; then land
  the edits and close with the repo validation loop (`just fmt && just lint && just build`) plus a per-delta summary of
  what changed and why. Confidence: 0.55

