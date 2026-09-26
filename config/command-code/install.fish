# Installs Command Code globally with bun when it isn't already present.
set -l cmdc (command -v cmdc)
if test -z "$cmdc"
    if test -x "$HOME/.bun/bin/cmdc"
        set cmdc "$HOME/.bun/bin/cmdc"
    else
        bun add -g command-code@latest
        set cmdc "$HOME/.bun/bin/cmdc"
    end
end

# Post-install: seed the caveman skill, skipped when already there so activation stays idempotent.
if test -x "$cmdc"
    and not test -e "$HOME/.commandcode/skills/caveman"
    $cmdc skills add JuliusBrussee/caveman --global </dev/null
end
