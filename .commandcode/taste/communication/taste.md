# Communication

- Prefers responses in Vietnamese; explicitly asks to "nói tiếng việt". Confidence: 0.85
- Prefers terse, no-fluff responses — repeatedly activates the `caveman` skill and asks to keep instructions short
  ("Keep the instruction short", "tóm gọn lại"). Confidence: 0.8
- Wants the purpose/meaning explained when handed commands or config, not just the raw artifact (asks "what does this
  do?", "I copied the command but don't understand anything"). Confidence: 0.7
- Approves with a bare reply ("yeah", "fine", "try it") even when the agent offered an either/or question, meaning "go
  ahead with the option you recommended — don't ask again". "try it" additionally means: land the edit in the file now,
  they will judge it by rebuilding/looking at the result, so don't re-explain the rationale or ask which option they
  meant. Consequence: put the recommended option first, restate the chosen interpretation in one line before acting,
  then proceed without seeking further confirmation. Confidence: 0.7
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
- The same inline anchor also fixes _placement_ in non-port requests ("Add herdr and set it inside @modules/core/shell/cli/tui.nix / Change prefix to `alt-q`"): one terse line bundling add + tweak, with the named file treated as the binding destination. Land the change exactly there — don't relocate it to a module the agent judges a better fit (at most flag the mismatch in a single line), and act on the bundled tweaks in the same pass. Confidence: 0.7
- Hedges about a simple config fact are treated as a failure mode: when the agent sounds uncertain about whether a line/override matters, the user may say so directly ("you are very unsure about simple thing, i will just delete that line and check it myself") and take over the experiment. Respond by dropping the speculation, giving a one-line verdict and/or naming the single decisive check, rather than continuing to reason aloud. Confidence: 0.75
- Reads a bare "go on" (or "continue") as "you stopped mid-investigation — resume the exact step you were on", not as a
  request for a status recap or a re-ask of what to do next. Pick up the pending tool call/fix silently. Confidence: 0.6
- The same numbering also lets them _withdraw_ an item mid-flight, with the objection stated as a bare feeling rather
  than a technical reason: "look scary, can we skip the no.2". Read a "scary"/risk-flavoured veto as final, not as a
  debate opener — do not re-argue the tradeoff, do not offer a softened version, and do not ask for another reason.
  The response they accepted was three moves in one line: confirm the skip by number ("Skipping 2."), name the file
  that is now guaranteed unmodified ("i18n.nix untouched"), and proceed with the still-selected items in the same turn.
  Confidence: 0.75
- Opens a language-syntax question with an exact source anchor plus a one-line "in <lang>, how to <X>" — e.g.
  `@modules/core/shell/cli/tui.nix :L16` then "in nix, how to make a var concat `+` with a keybinding". The `:L<line>`
  suffix scopes the ask to that line: read the file first and answer *about their snippet*, never as an abstract
  tutorial. The gap this exposes is specific — their fluency is in Nix **module/option semantics**, not Nix **expression
  syntax**, so bare `let`/`in`, `+` vs `"${}"` interpolation still have to be spelled out. Accepted answer shape: both
  equivalent idioms shown side by side using their own identifiers, plus the one gotcha that changes the outcome (a
  literal `"prefix+n"` is resolved by the tool at runtime, not by Nix). Confidence: 0.6
- Picks from a set of labelled options with a hedged interrogative — "hmm 2 might be better ?" — which is a leaning, not a
  go-ahead: it usually bundles a request to validate the pick with a challenge to some part of it they suspect is
  superfluous. Expected shape: verdict on the choice in a line or two, resolve the embedded "why do we need X" question
  (including conceding it is redundant), show the trimmed result, and only then re-ask to apply — implementing the hedged
  pick as stated is the wrong move. Confidence: 0.7
- A "why only these?" / "why X?" follow-up is not always an audit — it can be a knowledge-gap request. Confirmed by
  "i was asking you duh because i don't have knownledge about all this base16 or token shit": the user lacked the domain
  vocabulary (base16 swatches, theme "tokens") and was asking to be taught. Failure mode the user named outright: the
  agent answered with jargon-heavy rationale *and* pushed the decision back ("Which do you want?"). Accepted shape was
  (a) one-line admission of the jargon miss, (b) a plain-language definition using the tool's own words — "herdr paints
  its UI using 18 named slots; stylix has swatches base00–base17; the code says paint this slot with this swatch" — then
  (c) the agent picking the option and applying it in the same turn. Consequence: when a choice hinges on background
  knowledge the user just said they don't have, don't present it as a labelled either/or — explain in one short plain
  paragraph, decide, and edit the file. Their fluency is in Nix module/option semantics, NOT in theming/color-palette
  vocabulary; gloss those terms the first time they appear. Confidence: 0.75
- Opens a correction with "Ofc i know <fact>" to discard something the agent just re-explained or re-confirmed: the named
  fact is background they already have, so re-stating it or celebrating having discovered it is wasted output. The real ask
  is always in the clause *after* that marker ("Ofc i know stylix doesn't support herdr, **what i am trying to know** if the
  editing ... match with correct value") — read it as the sole question, answer only that, and skip any recap of the
  conceded point. Confidence: 0.75
- When the agent's diagnosis is presented as a numbered list, the user selects work items by number alone — "FIx 1 and 2" — and that bare reply is the complete work order: do exactly the numbered items and nothing else, act on them immediately in the same turn, and leave the unselected item (here: the redundant herdr pin) untouched without re-justifying or asking whether to include it. Consequence: when reporting multiple problems, always enumerate them so the user can pick; a prose blob of findings forces them to re-explain scope. Confidence: 0.8