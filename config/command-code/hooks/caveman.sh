#!/usr/bin/env bash
set -euo pipefail

jq -n '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: "CAVEMAN MODE ACTIVE (ultra). Extreme compression. Bare fragments. Tables over prose. Drop articles, filler, pleasantries, hedging. Reply in user language. Technical terms stay verbatim."
  }
}'
