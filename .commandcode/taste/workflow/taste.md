# Workflow

- Verify/research before implementing: search the web and docs (web search, context7, Tavily) and confirm package
  availability (e.g. `nps -e`) before writing config. Confidence: 0.75
- When asking how a third-party module/flake option behaves, explicitly directs the agent to "research" it first —
  expects answers grounded in the upstream source actually resolved on the machine (flake.lock → nix store / cache), not
  from memory or docs summaries. Confidence: 0.7
- Audits the agent's sourcing after the fact — asks outright "did you use MCP tool to read the docs?" and expects a
  transparent accounting of which tools/MCP servers were called, what they returned, and where they fell short versus
  raw source inspection. Confidence: 0.6
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
- Ordering rule for research: docs lookup comes _first_, not as a fallback after local digging fails — corrects the
  agent with "I suggest you immediately use websearch or MCP to learn first!" when it burns several turns on `ls`/`find`
  over the nix store before consulting docs. Consequence: on an unfamiliar third-party option, call web search /
  context7 (resolve-library-id → query-docs) as the _first_ action, in parallel with reading the local config files;
  only then trace resolved source. Confidence: 0.8
- Tests NixOS config changes in a VM (`#vm`) before committing. Confidence: 0.6
- Draws a privilege line around the agent session: runs the sudo-requiring step (NixOS rebuild/activation) themselves
  outside the session while letting the agent do the non-privileged validation loop (`just fmt`, `just lint`,
  `just build <host>`) and inspect build output/generated config — then reports real-world results back and expects a
  follow-up diagnosis. Never run sudo/activation commands. Confidence: 0.7
- Always run repo operations through the project's `just` recipes (`just fmt`, `just lint`, `just build <host>`,
  `just switch <host>`, and the flake-regeneration step too) — never the equivalent raw `nix run .#<host> -- build` /
  `nix run .#write-flake` / `nix flake` form, even when the agent already used `just` for the other steps in the same
  loop and even when the step is backgrounded. Holds the agent to this rule across the whole session and corrects a
  slipping step with a bare two-word pointer — just "follow @Justfile", no explanation — which means: the Justfile is
  the authoritative command list, go open it, pick the recipe that covers this step, and re-run without asking which
  one. Confidence: 0.9
- Wants the `caveman` Command Code skill to auto-activate globally at the start of every session, with ultra mode
  enabled. Confidence: 0.8
- Stubs out the destination file by hand _before_ asking for content to be written into it (e.g. empty
  `config/command-code/install.fish`, then "transform it to ... in @path"). Expects the agent to stat/read that target
  before writing rather than assume it is absent; a terse contesting question ("uh i already created it ?") means "prove
  what's actually on disk" — respond with the verified fact (`ls -la` + byte count → "it's 0 bytes, so it's empty") and
  then proceed with the write, don't stop and ask permission. Confidence: 0.6
- Tracks the agent's elapsed effort and uncertainty, cutting off both sprawl and hedging. "why so long ?" when research
  sprawls (here: a sub-agent spelunking a 3.4 MB minified JS bundle) and "you are very unsure about simple thing..."
  when the agent waffles over a basic config fact both demand the same shape: a one-line admission of
  over-rotation/uncertainty — no defense, no recap, no continued speculation — then exactly ONE bounded check (a single
  grep/build/eval with `timeout` and `| head -N`, where relevant) targeting the exact yes/no question, stopping the
  instant it is confirmed. If the simplest verification is to delete or disable the suspect line and rebuild/run, the
  user may do it themselves; do not pile on more analysis, state the minimal test and likely verdict. Consequence for
  delegation: scope sub-agents with hard bounds (named file, named pattern, "don't dump the bundle", "read-only")
  instead of open-ended "investigate everything about X"; prefer a narrow grep to a broad audit when one fact decides
  the design. Confidence: 0.85
- Hand-edits files in the editor _while_ the agent is working on the same repo, and reacts sharply when a full-file
  `write_file` clobbers those edits ("wait you overwrite my previous change !"). Consequence: treat any file the user
  may have touched as theirs-first — re-read it (and diff working tree vs git index) immediately before writing, and
  make the smallest additive edit (`edit_file` append/replace of one block) instead of regenerating the whole file from
  the agent's own mental model. When challenged about a possible overwrite, don't argue from memory: prove the actual
  state from primary evidence (`cat` the working file, `git show :<path>` for the staged version, `git diff -- <path>`)
  and say plainly what was and wasn't lost. Confidence: 0.75
- Pauses mid-task to demand a state audit ("What is the problem and have we done?") — expects the agent to reconstruct
  progress from primary evidence (e.g. `git diff` of the working tree) rather than from its own earlier narration, and
  to answer in a fixed shape: root cause → intended end-state → what is done → what is explicitly _not_ done (naming
  remaining defects, e.g. dead LSP stubs, unrun re-lint/re-build) → one question proposing the next step. Never a vague
  "almost there". Confidence: 0.65
