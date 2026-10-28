#!/usr/bin/env python3
"""Flatten option groups with fewer than four children into dotted attribute paths.

The rule (see AGENTS.md, "Attribute nesting"):

    x = { a = 1; b = 2; };        ->  x.a = 1; x.b = 2;     # 1-3 children
    x = { a = 1; b = 2; c = 3; d = 4; };                    # >=4 children, unchanged

Only binding values are rewritten, never function arguments. These keep their shape:
the `core`/`den`/`flake-file` skeletons, an aspect's `nixos`/`homeManager` body, `let`
bindings (Nix has no dotted names there), `rec` sets, sets with `inherit`, dynamic
`${...}` names, and bindings whose own syntax carries a comment (between name and
value). Comments inside a group ride along with the binding they precede or trail.

Runs over git-tracked *.nix files, or the paths given on the command line.
    scripts/attr-style.py            # rewrite
    scripts/attr-style.py --check    # exit 1 if anything would change
"""

import re
import subprocess
import sys
from pathlib import Path

import tree_sitter_nix
from tree_sitter import Language, Parser

MIN_CHILDREN = 4

# Generated or data files: not option groups.
SKIP_FILES = {
    "flake.nix",
    "modules/hosts.nix",
    "modules/_lib/host-facts.nix",
    "modules/_lib/mk-host.nix",
    "modules/_lib/user-facts.nix",
}

LANG = Language(tree_sitter_nix.language())
PARSER = Parser(LANG)

# shortcut: tree-sitter-nix 0.1.0 rejects alejandra's trailing comma in formals
# (`{ lib, mini, }:`); blank the comma for parsing, same byte length so offsets hold.
# Upgrade once the grammar parses `{ a, }:`.
TRAILING_FORMAL_COMMA = re.compile(rb",(?=\s*\}:)")


def parse(source):
    return PARSER.parse(TRAILING_FORMAL_COMMA.sub(b" ", source))


def walk(node):
    yield node
    for child in node.children:
        yield from walk(child)


def attrpath(binding):
    return binding.child_by_field_name("attrpath")


def path_text(binding):
    return attrpath(binding).text.decode()


def static(binding):
    node = attrpath(binding)
    return node is not None and not any(n.type == "interpolation" for n in walk(node))


def in_let(binding):
    """True only for the let's own bindings (`let a.b = 1;` is not valid Nix).

    A binding inside a let-bound value, e.g. a lambda body, is unaffected.
    """
    body = binding.parent
    return (
        body is not None
        and body.type == "binding_set"
        and body.parent is not None
        and body.parent.type == "let_expression"
    )


# Framework/DSL roots: structure, not option groups. Inherited by the whole subtree,
# except inside a `nixos`/`homeManager` body, where real options start again.
SKELETON_ROOTS = ("core", "den", "flake-file")


def is_body(path):
    """An aspect's module body: exempt itself, options inside it."""
    return path in ("nixos", "homeManager")


def framework_path(path):
    return path.split(".")[0] in SKELETON_ROOTS


def own_comments(binding):
    """Comments in the binding's own syntax (between name, `=` and value): not hoistable."""
    return any(c.type == "comment" for c in binding.children)


def flattenable(binding, framework):
    path = path_text(binding)
    if framework or framework_path(path) or is_body(path):
        return False
    if not static(binding) or in_let(binding) or own_comments(binding):
        return False
    value = binding.child_by_field_name("expression")
    if value is None or value.type != "attrset_expression":
        return False
    body = next((c for c in value.children if c.type == "binding_set"), None)
    if body is None:
        return False
    children = [c for c in body.children if c.type == "binding"]
    if not 1 <= len(children) < MIN_CHILDREN:
        return False
    # Anything else in the body (inherit) cannot be spelled as a dotted path.
    if len(children) != sum(1 for c in body.children if c.type != "comment"):
        return False
    return all(static(child) and not own_comments(child) for child in children)


def render(binding, prefix, source):
    """Lines spelling `binding` flattened under `prefix`, comments carried along."""
    value = binding.child_by_field_name("expression")
    items = []
    for child in value.children:
        if child.type == "comment":
            items.append(child)
        elif child.type == "binding_set":
            items.extend(child.children)
    lines, pending, last_row = [], [], None
    for item in items:
        if item.type == "comment":
            if lines and last_row is not None and item.start_point[0] == last_row:
                lines[-1] += " " + item.text.decode()
            else:
                pending.append(item.text.decode())
            last_row = item.end_point[0]
            continue
        if item.type != "binding":
            continue
        path = f"{prefix}.{path_text(item)}"
        if flattenable(item, False):
            emitted = render(item, path, source)
        else:
            child = render_expr(item.child_by_field_name("expression"), source, False)
            emitted = [f"{path} = {child.decode()};"]
        lines += pending + emitted
        pending = []
        last_row = item.end_point[0]
    return lines + pending


def render_node(node, source, framework):
    if node.type == "binding":
        path = path_text(node)
        if flattenable(node, framework):
            return "\n".join(render(node, path, source)).encode()
        inner = framework or framework_path(path)
        return render_expr(node, source, False if is_body(path) else inner)
    return render_expr(node, source, framework)


def render_expr(node, source, framework):
    """`node` with every nested small group rewritten; all other text preserved."""
    out = []
    pos = node.start_byte
    for child in node.children:
        out.append(source[pos : child.start_byte])
        out.append(render_node(child, source, framework))
        pos = child.end_byte
    out.append(source[pos : node.end_byte])
    return b"".join(out)


def rewrite(source):
    tree = parse(source)
    if tree.root_node.has_error:
        return None
    return render_expr(tree.root_node, source, False)


def main(argv):
    check = "--check" in argv
    paths = [Path(p) for p in argv if not p.startswith("-")]
    if not paths:
        tracked = subprocess.run(
            ["git", "ls-files", "*.nix"], capture_output=True, text=True, check=True
        ).stdout.split()
        paths = [Path(p) for p in tracked if p not in SKIP_FILES]
    changed = []
    for path in paths:
        source = path.read_bytes()
        out = rewrite(source)
        if out is None:
            sys.exit(f"{path}: parse error, refusing to rewrite")
        if out != source:
            changed.append(path)
            if not check:
                path.write_bytes(out)
    for path in changed:
        print(f"{'would rewrite' if check else 'rewrote'} {path}")
    if check and changed:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
