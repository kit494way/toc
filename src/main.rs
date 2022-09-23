use clap::{arg, command};
use comrak::{
    format_commonmark,
    nodes::{AstNode, NodeValue},
    parse_document, Arena, ComrakOptions,
};
use std::io::prelude::*;

fn main() {
    let matches = command!()
        .arg(arg!([file]))
        .arg(arg!(--vimgrep).action(clap::ArgAction::SetTrue))
        .get_matches();

    let mut doc = String::new();
    let mut filepath = "<stdin>";
    match matches.value_of("file") {
        Some(f) => {
            doc = std::fs::read_to_string(f).unwrap_or_else(|e| {
                eprintln!("Failed to read file='{}': {}", f, e);
                std::process::exit(1);
            });
            filepath = f;
        }
        None => {
            std::io::stdin()
                .lock()
                .read_to_string(&mut doc)
                .unwrap_or_else(|e| {
                    eprintln!("Failed to read stdin: {}", e);
                    std::process::exit(1);
                });
        }
    };

    let arena = Arena::new();
    let root = parse_document(&arena, doc.as_str(), &ComrakOptions::default());

    let children = root.children();

    let toc: Vec<String> = if matches.get_flag("vimgrep") {
        children
            .filter_map(|node| format_heading_vimgrep(node, filepath))
            .collect()
    } else {
        children.filter_map(&format_heading).collect()
    };

    println!("{}", toc.join("\n"));
}

fn format_heading<'a>(node: &'a AstNode<'a>) -> Option<String> {
    match node.data.borrow().value {
        NodeValue::Heading(_) => {
            let mut out = Vec::new();
            format_commonmark(node, &ComrakOptions::default(), &mut out).unwrap();
            Some(String::from_utf8(out).unwrap().trim().to_string())
        }
        _ => None,
    }
}

fn format_heading_vimgrep<'a>(node: &'a AstNode<'a>, filename: &str) -> Option<String> {
    format_heading(node).map(|s| format!("{}:{}:1:{}", filename, node.data.borrow().start_line, s))
}
