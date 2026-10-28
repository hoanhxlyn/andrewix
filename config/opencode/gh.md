---
description: Create a GitHub issue or PR following the repo templates
---

Create the requested GitHub issue or pull request with `gh`, following the
repo's templates:

- Issues: `.github/ISSUE_TEMPLATE/` — `feature.yml` for new aspects/tools/
  behaviour, `bug.yml` for breakage. The CLI does not expand issue forms, so
  replicate every template field as markdown headings in the body (checkboxes
  as `- [ ]` task lists) and pass the template's labels via `--add-label`.
- Pull requests: `.github/pull_request_template.md` (What / Why / Checklist),
  and verify the checklist items actually pass before checking them.

Request: $ARGUMENTS
