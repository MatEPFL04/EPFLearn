//
//  PropositionalLogic.swift
//  EPFLearn
//
//  Moteur de logique propositionnelle : tokeniseur, parseur (descente récursive),
//  évaluateur, + un clavier SwiftUI réutilisable. Utilisé par TruthTableView et CNFView.
//
//  Opérateurs acceptés (symbole ou saisie ASCII au clavier) :
//    ¬  ~  !         négation
//    ∧  &  *  .      conjonction
//    ∨  |  +         disjonction
//    →  ->  =>       implication
//    ↔  <->  <=>     équivalence
//  Variables : une lettre chacune (p, q, r, s, …).
//

import SwiftUI

// MARK: - Arbre syntaxique

indirect enum Expr {
    case variable(String)
    case not(Expr)
    case and(Expr, Expr)
    case or(Expr, Expr)
    case imp(Expr, Expr)
    case iff(Expr, Expr)

    func eval(_ env: [String: Bool]) -> Bool {
        switch self {
        case .variable(let v):   return env[v] ?? false
        case .not(let e):        return !e.eval(env)
        case .and(let a, let b): return a.eval(env) && b.eval(env)
        case .or(let a, let b):  return a.eval(env) || b.eval(env)
        case .imp(let a, let b): return !a.eval(env) || b.eval(env)
        case .iff(let a, let b): return a.eval(env) == b.eval(env)
        }
    }

    var variables: Set<String> {
        switch self {
        case .variable(let v): return [v]
        case .not(let e):      return e.variables
        case .and(let a, let b), .or(let a, let b),
             .imp(let a, let b), .iff(let a, let b):
            return a.variables.union(b.variables)
        }
    }
}

// MARK: - Tokeniseur

private enum Tok: Equatable {
    case v(String), not, and, or, imp, iff, lparen, rparen
}

private func tokenize(_ s: String) -> [Tok]? {
    var toks: [Tok] = []
    let chars = Array(s)
    var i = 0

    func match(_ str: String) -> Bool {
        let arr = Array(str)
        if i + arr.count <= chars.count && Array(chars[i ..< i + arr.count]) == arr {
            i += arr.count
            return true
        }
        return false
    }

    while i < chars.count {
        let c = chars[i]
        if c == " " || c == "\t" { i += 1; continue }
        if match("<->") || match("<=>") { toks.append(.iff); continue }
        if match("->")  || match("=>")  { toks.append(.imp); continue }
        switch c {
        case "¬", "~", "!":      toks.append(.not);    i += 1
        case "∧", "&", "*", ".": toks.append(.and);    i += 1
        case "∨", "|", "+":      toks.append(.or);     i += 1
        case "→":                toks.append(.imp);    i += 1
        case "↔":                toks.append(.iff);    i += 1
        case "(", "[":           toks.append(.lparen); i += 1
        case ")", "]":           toks.append(.rparen); i += 1
        default:
            if c.isLetter { toks.append(.v(String(c))); i += 1 }
            else { return nil }
        }
    }
    return toks
}

// MARK: - Parseur (précédence : ¬ > ∧ > ∨ > → > ↔)

private struct Parser {
    let toks: [Tok]
    var pos = 0
    var peek: Tok? { pos < toks.count ? toks[pos] : nil }

    mutating func parse() -> Expr? {
        guard let e = parseIff(), pos == toks.count else { return nil }
        return e
    }
    mutating func parseIff() -> Expr? {
        guard var left = parseImp() else { return nil }
        while peek == .iff { pos += 1; guard let r = parseImp() else { return nil }; left = .iff(left, r) }
        return left
    }
    mutating func parseImp() -> Expr? {                    // → associe à droite
        guard let left = parseOr() else { return nil }
        if peek == .imp { pos += 1; guard let r = parseImp() else { return nil }; return .imp(left, r) }
        return left
    }
    mutating func parseOr() -> Expr? {
        guard var left = parseAnd() else { return nil }
        while peek == .or { pos += 1; guard let r = parseAnd() else { return nil }; left = .or(left, r) }
        return left
    }
    mutating func parseAnd() -> Expr? {
        guard var left = parseNot() else { return nil }
        while peek == .and { pos += 1; guard let r = parseNot() else { return nil }; left = .and(left, r) }
        return left
    }
    mutating func parseNot() -> Expr? {
        if peek == .not { pos += 1; guard let e = parseNot() else { return nil }; return .not(e) }
        return parseAtom()
    }
    mutating func parseAtom() -> Expr? {
        guard let t = peek else { return nil }
        switch t {
        case .v(let name):
            pos += 1
            return .variable(name)
        case .lparen:
            pos += 1
            guard let e = parseIff(), peek == .rparen else { return nil }
            pos += 1
            return e
        default:
            return nil
        }
    }
}

// MARK: - Formule

struct Formula {
    let source: String
    let expr: Expr?

    init(_ s: String) {
        source = s
        if let toks = tokenize(s), !toks.isEmpty {
            var p = Parser(toks: toks)
            expr = p.parse()
        } else {
            expr = nil
        }
    }

    var isValid: Bool { expr != nil }
    var variables: [String] { (expr?.variables ?? []).sorted() }
    func evaluate(_ env: [String: Bool]) -> Bool { expr?.eval(env) ?? false }
}

// MARK: - Helpers

enum Sym {
    static let not = "¬", and = "∧", or = "∨", imp = "→", iff = "↔"
}

enum PropLogic {
    /// Toutes les affectations pour n variables - vrai d'abord (V,V ; V,F ; F,V ; F,F).
    static func rows(_ n: Int) -> [[Bool]] {
        let total = 1 << n
        return (0..<total).reversed().map { mask in
            (0..<n).map { i in (mask >> (n - 1 - i)) & 1 == 1 }
        }
    }
    static func env(_ vars: [String], _ row: [Bool]) -> [String: Bool] {
        Dictionary(uniqueKeysWithValues: zip(vars, row))
    }

    static let presets: [String] = [
        "p ∨ ¬p",
        "p ∧ ¬p",
        "(p → q) ↔ (¬q → ¬p)",
        "((p → q) ∧ p) → q",
        "¬(p ∧ q) ↔ (¬p ∨ ¬q)",
        "p → q",
        "p ↔ q",
        "(p ∨ q) ∧ ¬r",
        "(p ∧ q) ∨ (¬p ∧ r)"
    ]
}

// MARK: - Clavier de saisie réutilisable

struct FormulaKeypad: View {
    @Binding var text: String

    private let keys: [(label: String, insert: String)] = [
        ("p", "p"), ("q", "q"), ("r", "r"), ("s", "s"),
        ("¬", "¬"), ("∧", " ∧ "), ("∨", " ∨ "),
        ("→", " → "), ("↔", " ↔ "), ("(", "("), (")", ")")
    ]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 6)

    var body: some View {
        VStack(spacing: 8) {
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(keys, id: \.label) { key in
                    Button {
                        text.append(key.insert)
                    } label: {
                        Text(key.label)
                            .font(.system(size: 17, design: .monospaced))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(Color.blue.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
            HStack {
                Button {
                    if !text.isEmpty { text.removeLast() }
                } label: {
                    Label("Delete", systemImage: "delete.left")
                }
                Spacer()
                Button("Clear all") { text = "" }
                    .foregroundStyle(.red)
            }
            .font(.footnote)
        }
    }
}
