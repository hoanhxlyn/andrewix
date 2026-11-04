//! Flatten option groups with fewer than four children into dotted attribute paths.
//!
//! The rule (see AGENTS.md, "Attribute nesting"):
//!
//! ```text
//! x = { a = 1; b = 2; };        ->  x.a = 1; x.b = 2;     # 1-3 children
//! x = { a = 1; b = 2; c = 3; d = 4; };                    # >=4 children, unchanged
//! ```
//!
//! Only binding values are rewritten, never function arguments. These keep their shape:
//! the `core`/`den`/`flake-file` skeletons, an aspect's `nixos`/`homeManager` body, `let`
//! bindings (Nix has no dotted names there), `rec` sets, sets with `inherit`, dynamic
//! `${...}` names, and bindings whose own syntax carries a comment (between name and
//! value). Comments inside a group ride along with the binding they precede or trail.
//!
//! Runs over git-tracked *.nix files, or the paths given on the command line.
//!     attr-style            # rewrite
//!     attr-style --check    # exit 1 if anything would change

use std::process::Command;

use rnix::ast::{self, HasEntry};
use rnix::{NodeOrToken, SyntaxKind, SyntaxNode};
use rowan::ast::AstNode;

const MIN_CHILDREN: usize = 4;

/// Generated or data files: not option groups.
const SKIP_FILES: &[&str] = &[
    "flake.nix",
    "modules/hosts.nix",
    "modules/_lib/host-facts.nix",
    "modules/_lib/mk-host.nix",
    "modules/_lib/user-facts.nix",
];

/// Framework/DSL roots: structure, not option groups. Inherited by the whole subtree,
/// except inside a `nixos`/`homeManager` body, where real options start again.
const SKELETON_ROOTS: &[&str] = &["core", "den", "flake-file"];

struct Ctx {
    line_starts: Vec<usize>,
}

impl Ctx {
    fn new(source: &str) -> Self {
        let mut line_starts = vec![0];
        for (i, byte) in source.bytes().enumerate() {
            if byte == b'\n' {
                line_starts.push(i + 1);
            }
        }
        Self { line_starts }
    }

    fn line_of(&self, offset: usize) -> usize {
        self.line_starts.partition_point(|&start| start <= offset) - 1
    }
}

fn text(node: &SyntaxNode) -> String {
    node.text().to_string()
}

fn offset(size: rnix::TextSize) -> usize {
    u32::from(size) as usize
}

fn has_interpolation(node: &SyntaxNode) -> bool {
    node.descendants_with_tokens()
        .any(|element| element.kind() == SyntaxKind::TOKEN_INTERPOL_START)
}

fn own_comments(node: &SyntaxNode) -> bool {
    node.children_with_tokens()
        .any(|element| element.kind() == SyntaxKind::TOKEN_COMMENT)
}

fn in_let(node: &SyntaxNode) -> bool {
    node.parent()
        .is_some_and(|parent| parent.kind() == SyntaxKind::NODE_LET_IN)
}

fn is_body(path: &str) -> bool {
    path == "nixos" || path == "homeManager"
}

fn framework_path(path: &str) -> bool {
    SKELETON_ROOTS.contains(&path.split('.').next().unwrap_or_default())
}

fn flattenable(binding: &ast::AttrpathValue, framework: bool) -> bool {
    let Some(attrpath) = binding.attrpath() else {
        return false;
    };
    let path = text(attrpath.syntax());
    if framework || framework_path(&path) || is_body(&path) {
        return false;
    }
    if in_let(binding.syntax()) || own_comments(binding.syntax()) {
        return false;
    }
    if has_interpolation(attrpath.syntax()) {
        return false;
    }
    let Some(ast::Expr::AttrSet(set)) = binding.value() else {
        return false;
    };
    if set.rec_token().is_some() {
        return false;
    }
    let entries: Vec<ast::Entry> = set.entries().collect();
    if entries.is_empty() || entries.len() >= MIN_CHILDREN {
        return false;
    }
    // Anything else in the body (inherit) cannot be spelled as a dotted path.
    entries.iter().all(|entry| match entry {
        ast::Entry::AttrpathValue(child) => {
            child
                .attrpath()
                .is_some_and(|attrpath| !has_interpolation(attrpath.syntax()))
                && !own_comments(child.syntax())
        }
        ast::Entry::Inherit(_) => false,
    })
}

/// Lines spelling `binding` flattened under `prefix`, comments carried along.
fn render(binding: &ast::AttrpathValue, prefix: &str, ctx: &Ctx) -> Vec<String> {
    let Some(ast::Expr::AttrSet(set)) = binding.value() else {
        unreachable!("render called on a non-flattenable binding");
    };
    let mut lines: Vec<String> = Vec::new();
    let mut pending: Vec<String> = Vec::new();
    let mut last_line: Option<usize> = None;
    for item in set.syntax().children_with_tokens() {
        match item.kind() {
            SyntaxKind::TOKEN_COMMENT => {
                let token = item.as_token().expect("token");
                let range = token.text_range();
                let start = ctx.line_of(offset(range.start()));
                if !lines.is_empty() && last_line == Some(start) {
                    let line = lines.last_mut().expect("non-empty");
                    line.push(' ');
                    line.push_str(token.text());
                } else {
                    pending.push(token.text().to_string());
                }
                last_line = Some(ctx.line_of(offset(range.end())));
            }
            SyntaxKind::NODE_ATTRPATH_VALUE => {
                let child =
                    ast::AttrpathValue::cast(item.as_node().expect("node").clone()).expect("binding");
                let path = format!("{prefix}.{}", text(child.attrpath().expect("attrpath").syntax()));
                let mut emitted = if flattenable(&child, false) {
                    render(&child, &path, ctx)
                } else {
                    let value = render_children(child.value().expect("value").syntax(), false, ctx);
                    vec![format!("{path} = {value};")]
                };
                lines.append(&mut pending);
                lines.append(&mut emitted);
                last_line = Some(ctx.line_of(offset(item.text_range().end())));
            }
            _ => {}
        }
    }
    lines.append(&mut pending);
    lines
}

/// `node` with every nested small group rewritten; all other text preserved.
fn render_children(node: &SyntaxNode, framework: bool, ctx: &Ctx) -> String {
    let mut out = String::new();
    for child in node.children_with_tokens() {
        match child {
            NodeOrToken::Node(node) => out.push_str(&render_node(&node, framework, ctx)),
            NodeOrToken::Token(token) => out.push_str(token.text()),
        }
    }
    out
}

fn render_node(node: &SyntaxNode, framework: bool, ctx: &Ctx) -> String {
    if node.kind() != SyntaxKind::NODE_ATTRPATH_VALUE {
        return render_children(node, framework, ctx);
    }
    let binding = ast::AttrpathValue::cast(node.clone()).expect("binding");
    let path = text(binding.attrpath().expect("attrpath").syntax());
    if flattenable(&binding, framework) {
        return render(&binding, &path, ctx).join("\n");
    }
    let inner = framework || framework_path(&path);
    render_children(node, if is_body(&path) { false } else { inner }, ctx)
}

fn rewrite(source: &str) -> Option<String> {
    let parse = ast::Root::parse(source);
    if !parse.errors().is_empty() {
        return None;
    }
    let ctx = Ctx::new(source);
    Some(render_node(&parse.syntax(), false, &ctx))
}

fn fail(message: &str) -> ! {
    eprintln!("{message}");
    std::process::exit(1);
}

fn main() {
    let mut check = false;
    let mut paths: Vec<String> = Vec::new();
    for arg in std::env::args().skip(1) {
        if arg == "--check" {
            check = true;
        } else if !arg.starts_with('-') {
            paths.push(arg);
        }
    }
    if paths.is_empty() {
        let output = Command::new("git")
            .args(["ls-files", "*.nix"])
            .output()
            .unwrap_or_else(|error| fail(&format!("git ls-files: {error}")));
        paths = String::from_utf8_lossy(&output.stdout)
            .split_whitespace()
            .filter(|path| !SKIP_FILES.contains(path))
            .map(str::to_string)
            .collect();
    }
    let mut changed: Vec<String> = Vec::new();
    for path in &paths {
        let source = std::fs::read_to_string(path)
            .unwrap_or_else(|error| fail(&format!("{path}: {error}")));
        let Some(rewritten) = rewrite(&source) else {
            fail(&format!("{path}: parse error, refusing to rewrite"));
        };
        if rewritten != source {
            changed.push(path.clone());
            if !check {
                std::fs::write(path, rewritten)
                    .unwrap_or_else(|error| fail(&format!("{path}: {error}")));
            }
        }
    }
    for path in &changed {
        println!("{} {path}", if check { "would rewrite" } else { "rewrote" });
    }
    if check && !changed.is_empty() {
        std::process::exit(1);
    }
}

#[cfg(test)]
mod tests {
    use super::rewrite;

    fn flat(source: &str) -> String {
        rewrite(source).expect("parses")
    }

    #[test]
    fn flattens_groups_below_four() {
        let source = r#"{
  one = { a = 1; };
  two = {
    a = 1;
    b = 2;
  };
  three = { a = 1; b = 2; c = 3; };
  four = { a = 1; b = 2; c = 3; d = 4; };
}
"#;
        let expected = r#"{
  one.a = 1;
  two.a = 1;
two.b = 2;
  three.a = 1;
three.b = 2;
three.c = 3;
  four = { a = 1; b = 2; c = 3; d = 4; };
}
"#;
        assert_eq!(flat(source), expected);
    }

    #[test]
    fn flattens_nested_groups() {
        let source = r#"{
  x = {
    a = {
      b = 1;
      c = 2;
    };
    d = 3;
  };
  y = {
    a = { b = 1; c = 2; d = 3; e = 4; };
  };
}
"#;
        let expected = r#"{
  x.a.b = 1;
x.a.c = 2;
x.d = 3;
  y.a = { b = 1; c = 2; d = 3; e = 4; };
}
"#;
        assert_eq!(flat(source), expected);
    }

    #[test]
    fn keeps_rec_inherit_and_let() {
        let source = r#"{
  rec1 = rec { a = 1; b = 2; };
  inh = { inherit a; };
  mixed = { a = 1; inherit b; };
}
"#;
        assert_eq!(flat(source), source);

        let let_source = r#"let
  a = { b = 1; c = 2; };
in {
  x = { y = 1; z = 2; };
}
"#;
        let let_expected = r#"let
  a = { b = 1; c = 2; };
in {
  x.y = 1;
x.z = 2;
}
"#;
        assert_eq!(flat(let_source), let_expected);
    }

    #[test]
    fn keeps_dynamic_names() {
        let source = r#"{
  dyn = { "${n}" = 1; };
  dyn2 = { a.${n} = 1; };
  str = { "quoted" = 1; other = 2; };
}
"#;
        let expected = r#"{
  dyn = { "${n}" = 1; };
  dyn2 = { a.${n} = 1; };
  str."quoted" = 1;
str.other = 2;
}
"#;
        assert_eq!(flat(source), expected);
    }

    #[test]
    fn carries_comments_along() {
        let source = r#"{
  x = {
    a = 1; # trailing a
    # leading b
    b = 2;
  };
  own = /* why */ { a = 1; b = 2; };
  inner = { a = 1; /* mid */ b = 2; };
}
"#;
        let expected = r#"{
  x.a = 1; # trailing a
# leading b
x.b = 2;
  own = /* why */ { a = 1; b = 2; };
  inner.a = 1; /* mid */
inner.b = 2;
}
"#;
        assert_eq!(flat(source), expected);
    }

    #[test]
    fn keeps_skeleton_roots() {
        let source = r#"{
  core.foo = { a = 1; b = 2; };
  core.foo.nixos = { a = 1; b = 2; };
  den.aspects.x = { includes = []; };
  flake-file.inputs = { a = 1; b = 2; };
  plain.nixos = { a = 1; b = 2; };
}
"#;
        let expected = r#"{
  core.foo = { a = 1; b = 2; };
  core.foo.nixos = { a = 1; b = 2; };
  den.aspects.x = { includes = []; };
  flake-file.inputs = { a = 1; b = 2; };
  plain.nixos.a = 1;
plain.nixos.b = 2;
}
"#;
        assert_eq!(flat(source), expected);
    }

    #[test]
    fn parses_trailing_comma_in_formals() {
        let source = r#"{
  lib,
  mini,
}: {
  x = { a = 1; b = 2; };
}
"#;
        let expected = r#"{
  lib,
  mini,
}: {
  x.a = 1;
x.b = 2;
}
"#;
        assert_eq!(flat(source), expected);
    }

    #[test]
    fn rewrite_is_idempotent() {
        for source in [
            "{ x = { a = 1; b = 2; }; }\n",
            "{\n  x = {\n    a = {\n      b = 1;\n      c = 2;\n    };\n  };\n}\n",
            "{\n  x = {\n    a = 1; # c\n    b = 2;\n  };\n}\n",
        ] {
            let once = flat(source);
            assert_eq!(flat(&once), once);
        }
    }
}
