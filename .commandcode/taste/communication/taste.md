# Communication

- Prefers responses in Vietnamese; explicitly asks to "nói tiếng việt". Confidence: 0.85
- Prefers terse, no-fluff responses — repeatedly activates the `caveman` skill and asks to keep instructions short
  ("Keep the instruction short", "tóm gọn lại"). Confidence: 0.8
- Wants the purpose/meaning explained when handed commands or config, not just the raw artifact (asks "what does this
  do?", "I copied the command but don't understand anything"). Confidence: 0.7
- Approves with a bare one-word reply ("yeah", "fine") even when the agent offered an either/or question, meaning "go
  ahead with the option you recommended — don't ask again". Consequence: put the recommended option first, restate the
  chosen interpretation in one line before acting, then proceed without seeking further confirmation. Confidence: 0.6
- Audits the agent's adherence to stated repo conventions after the fact ("I told you to follow @Justfile command didn't
  i") — expects a one-line admission naming the exact rule broken plus an immediate redo through the correct path, with
  no defense or explanation of why the raw command was equivalent. Read such a correction as a standing rule for the
  rest of the session, not a one-off. On a _repeat_ violation the user doesn't restate the rule at all — they issue a
  memory check ("what i say ? run just command"), which means: recall the earlier instruction yourself, acknowledge it
  in ≤5 words ("Understood — Justfile only."), and re-run via the sanctioned recipe; treating it as a new question or
  asking which command to use is the wrong move. Confidence: 0.85
- Fact-checks the agent's _technical explanations_ (not just its sourcing) against observed runtime behavior: attaches a
  screenshot of the running tool alongside "You said `X = false` doesn't do Y, but [image]" when the agent's claim
  contradicts what they see. Read this as a demand for an immediate, explicit retraction that names the wrong claim ("my
  earlier claim was wrong") followed by the corrected mechanism — no defense, no hedging, no "it depends" — and close
  with the actual option that would produce the behavior they want. Evidence screenshots are accepted as ground truth
  over the agent's own reasoning. Confidence: 0.75
- Asks bare term-definition questions mid-thread ("what is popupmenu") about an option just discussed, expecting the
  answer to lead with the disambiguation — what the term does NOT mean / which confusable thing it is not (e.g. cmdline
  `wildmenu` vs the insert-mode LSP completion popup) — then the config keys with their defaults, and finally the
  concrete effect of _their_ current value, tied to file:line and to whether it makes a nearby option dead config.
  Confidence: 0.6
- Explicitly invites pushback on their own understanding ("feel free to correct me if i am wrong") and asks confirmatory
  questions about their mental model of a config ("X is the place to ACTUALLY set Y, yes?", "these lines should be
  enough yes? but i don't see it") — expects a direct yes/no verdict grounded in file:line proof, plus caveats listing
  where the model breaks (e.g. the upstream framework simply has no support for what they assumed the option enables).
  Same pattern for their own choices: volunteers that they don't know if something is "the right way" and wants a
  verdict plus the officially-recommended alternative. Confidence: 0.8
- Is fluent in Nix/config semantics but NOT in shell primitives: after a line-by-line walkthrough of an agent-authored
  `.fish` script, still asks bare "what is `test -z`" about individual builtins/flags inside it. Consequence: when
  handing them a shell/fish script, don't assume any token is self-explanatory — gloss operators and flags (`-z`/`-n`,
  `-x`, `-e`, `and`, `</dev/null`) inline in comments as well as in prose. Answer such definition questions in the shape
  they accepted: one-line semantics + origin of the letter, the opposite operator, a 2-line truth-table example, and the
  cross-shell gotcha (bash needs `"$x"` quoted so an unset var doesn't collapse to a bare `[ -z ]`; fish expands `$x` to
  one arg or nothing, so quoting is less critical). Confidence: 0.6
- Port/translation requests are one line: source snippet pasted inline in a fenced block, then "transform it to <target>
  in @path" — the `@path` names the _destination_ file to write, not something to explain. Expects a silent, complete
  port preserving every guard/condition 1:1 in idiomatic target syntax (no dropped presence checks), with no questions
  and no commentary on the original. The next turn then chains that artifact into the config with a bare deictic
  reference to it ("our created fish.shell") — meaning _its_ path/contents are already known, so wire it up in place
  without restating or re-confirming them. Confidence: 0.65
- The same inline anchor also fixes _placement_ in non-port requests ("Add herdr and set it inside
  @modules/core/shell/cli/tui.nix / Change prefix to `alt-q`"): one terse line bundling add + tweak, with the named file
  treated as the binding destination. Land the change exactly there — don't relocate it to a module the agent judges a
  better fit (at most flag the mismatch in a single line), and act on the bundled tweaks in the same pass. Confidence:
  0.7
