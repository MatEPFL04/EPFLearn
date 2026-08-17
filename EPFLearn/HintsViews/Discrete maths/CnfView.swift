

import SwiftUI

struct CNFView: View {
    enum Form: String, CaseIterable { case cnf = "CNF", dnf = "DNF" }

    @State private var mode: Form = .cnf
    @State private var selected = 0

    // p → q sits next to the four formulas it is usually compared with, so
    // "equivalent or not" is settled by reading two tables, not by recall.
    // The last two are deliberately on three variables: the table doubles in
    // height, which is the point of "one row per assignment".
    private let formulas = [
        "p ↔ q",
        "p → q",
        "¬p ∨ q",
        "¬q → ¬p",
        "¬(p ∧ ¬q)",
        "q → p",
        "¬(p ∧ q)",
        "¬p ∨ ¬q",
        "p ∨ ¬p",
        "p ∧ ¬p",
        "(p ∨ ¬q) ∧ (q ∨ ¬p)",
        "(p ∨ q) ∧ ¬r",
        "(p ∧ q) ∨ (¬p ∧ r)"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VizHeader("Propositional Logic", subtitle: "Normal forms: a shape a formula can always be rewritten into.")

                definitions

                content

                // Under the table, like every other picker in the app.
                Picker("Form", selection: $mode) {
                    ForEach(Form.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .labelsHidden()

                Picker("Formula", selection: $selected) {
                    ForEach(Array(formulas.enumerated()), id: \.offset) { i, f in
                        Text(f).tag(i)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
    }

    private var definitions: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("A literal: a variable or its negation (p, ¬p).")
            if mode == .cnf {
                Text("A clause: literals joined by ∨.")
                Text("A CNF: clauses joined by ∧, one per false row.")
            } else {
                Text("A term: literals joined by ∧.")
                Text("A DNF: terms joined by ∨, one per true row.")
            }
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
    }

    private var content: some View {
        let f = Formula(formulas[selected])
        let vs = f.variables
        let rows = PropLogic.rows(vs.count)
        let isCNF = (mode == .cnf)
        let targets = rows.filter { isCNF ? !f.evaluate(PropLogic.env(vs, $0))
                                          :  f.evaluate(PropLogic.env(vs, $0)) }
        let outerSep = isCNF ? "∧" : "∨"

        return VStack(alignment: .leading, spacing: 10) {

            Text(isCNF ? "Only the false rows (red) produce a clause."
                       : "Only the true rows (green) produce a term.")
                .font(.caption).foregroundStyle(.secondary)

            // Truth table + clause/term column
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                GridRow {
                    ForEach(vs, id: \.self) { cell($0, header: true) }
                    cell(formulas[selected], header: true, wide: true)
                    cell(isCNF ? "clause" : "term", header: true, wide: true)
                }
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    let value = f.evaluate(PropLogic.env(vs, row))
                    let isTarget = isCNF ? !value : value
                    let bg: Color = isTarget ? (isCNF ? Color.red : Color.green).opacity(0.10) : .clear
                    GridRow {
                        ForEach(Array(row.enumerated()), id: \.offset) { _, b in
                            cell(b ? "T" : "F", tint: b ? .green : .red, background: bg)
                        }
                        cell(value ? "T" : "F", tint: value ? .green : .red, background: bg)
                        cell(isTarget ? piece(vs, row) : "—", mono: true, background: bg, wide: true)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))

            // Assembled normal form: the pieces above, joined
            VStack(alignment: .leading, spacing: 4) {
                Text(isCNF ? "Conjunctive normal form" : "Disjunctive normal form")
                    .font(.caption).foregroundStyle(.secondary)
                if targets.isEmpty {
                    Text(isCNF ? "⊤   (always true: no clauses)"
                               : "⊥   (always false: no terms)")
                        .font(.system(size: 15, design: .monospaced))
                } else {
                    ForEach(Array(targets.enumerated()), id: \.offset) { i, row in
                        HStack(spacing: 8) {
                            Text(i == 0 ? "  " : outerSep)
                                .font(.system(size: 15, weight: .medium, design: .monospaced))
                                .foregroundStyle(.secondary)
                            Text(piece(vs, row))
                                .font(.system(size: 15, weight: .medium, design: .monospaced))
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background((isCNF ? Color.blue : Color.green).opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    // One row's piece:
    //  CNF clause = OR of literals, each false on this row  (¬x if x true, x if false).
    //  DNF term   = AND of literals, each true  on this row ( x if x true, ¬x if false).
    private func piece(_ vs: [String], _ row: [Bool]) -> String {
        let isCNF = (mode == .cnf)
        let lits = zip(vs, row).map { name, val -> String in
            isCNF ? (val ? "¬\(name)" : name)
                  : (val ? name : "¬\(name)")
        }
        let sep = isCNF ? " ∨ " : " ∧ "
        return "(" + lits.joined(separator: sep) + ")"
    }

    private func cell(_ s: String, header: Bool = false, mono: Bool = false,
                      tint: Color? = nil, background: Color = .clear, wide: Bool = false) -> some View {
        Text(s)
            .font(.system(size: header ? 13 : 14, weight: header ? .semibold : .regular,
                          design: (mono || !header) ? .monospaced : .default))
            .foregroundStyle(tint ?? .primary)
            .lineLimit(1).minimumScaleFactor(0.6)
            .frame(minWidth: wide ? 90 : 40, minHeight: header ? 38 : 32)
            .frame(maxWidth: wide ? .infinity : nil)
            .padding(.horizontal, 6)
            .background(header ? Color.blue.opacity(0.12) : background)
            .border(Color.gray.opacity(0.15))
    }
}

#Preview { CNFView() }
