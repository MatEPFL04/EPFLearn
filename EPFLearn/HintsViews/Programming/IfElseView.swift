//
//  IfElseView.swift
//  EPFLearn
//
//  Three things students actually get wrong with conditionals, one tab each:
//
//    1. CHAIN — `else if` makes the branches mutually exclusive: the first
//       true test wins and everything below is never even looked at. Replace
//       the `else`s by independent `if`s and every true test fires, so the
//       LAST one silently overwrites the answer. The toggle shows the same
//       input producing a different result, which is the whole lesson.
//
//    2. SHORT-CIRCUIT — `&&` does not evaluate its right operand when the
//       left is false (and `||` skips it when the left is true). This is not
//       an optimisation detail: it is what makes the guard idiom
//       `i < n && a[i] > 0` safe.
//
//    3. TRUTH TABLE — the four rows of a two-variable formula, with De
//       Morgan checked live on the current row.
//

import SwiftUI

// MARK: - Condition rows

private enum CondState {
    case pending, isTrue, isFalse, skipped
}

private struct CondRow: Identifiable {
    let id: Int
    let test: String
    let assign: String
    var state: CondState = .pending
    var fired: Bool = false          // assignment executed at this row
    var overwrites: Bool = false     // it silently replaced a previous answer
}

private struct IfStep {
    let rows: [CondRow]
    let line: Int
    let note: String
    let grade: String
    var warning: Bool = false
}

// MARK: - View

struct IfElseView: View {

    private enum Tab: String, CaseIterable, Identifiable {
        case chain = "else if", shortCircuit = "&& ||", table = "truth table"
        var id: String { rawValue }
    }

    @State private var tab: Tab = .chain
    @State private var score: Double = 95
    @State private var useElseIf = true
    @State private var index = 0

    // short-circuit tab
    @State private var i: Double = 3
    @State private var useOr = false

    // truth table tab
    @State private var pTrue = true
    @State private var qTrue = false

    private let accent = Color.orange
    private let arr = [5, -3, 8]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                VizTitle(title: "Conditionals",
                         subtitle: "Which test runs, which one is skipped, and why it matters.",
                         accent: accent)

                Picker("Tab", selection: $tab) {
                    ForEach(Tab.allCases) { t in Text(t.rawValue).tag(t) }
                }
                .pickerStyle(.segmented)

                switch tab {
                case .chain:        chainTab
                case .shortCircuit: shortCircuitTab
                case .table:        truthTableTab
                }
            }
            .padding(18)
        }
        .background(Color(.systemGroupedBackground))
        .animation(.spring(duration: 0.28), value: index)
        .animation(.easeInOut(duration: 0.2), value: tab)
    }

    // MARK: - Tab 1: else-if chain

    private var chainSteps: [IfStep] { Self.chainTrace(score: Int(score), useElseIf: useElseIf) }
    private var chainStep: IfStep { chainSteps[min(index, chainSteps.count - 1)] }

    private var chainCode: [String] {
        let kw = useElseIf ? "} else if" : "}\nif"
        _ = kw
        var lines = ["String g = \"?\";"]
        let tests = [("s >= 90", "A"), ("s >= 80", "B"), ("s >= 70", "C"), ("s >= 60", "D")]
        for (k, t) in tests.enumerated() {
            let head = (k == 0 || !useElseIf) ? "if (\(t.0)) {" : "} else if (\(t.0)) {"
            lines.append(head)
            lines.append("    g = \"\(t.1)\";")
            if !useElseIf { lines.append("}") }
        }
        if useElseIf {
            lines.append("} else {")
            lines.append("    g = \"F\";")
            lines.append("}")
        } else {
            lines.append("if (s < 60) {")
            lines.append("    g = \"F\";")
            lines.append("}")
        }
        return lines
    }

    private var chainTab: some View {
        VStack(alignment: .leading, spacing: 16) {

            VizPanel(title: "input", accent: accent) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("s = \(Int(score))")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundStyle(accent)
                    Slider(value: $score, in: 0...100, step: 1)
                        .tint(accent)
                        .onChange(of: score) { _ in index = 0 }
                    Toggle(isOn: $useElseIf) {
                        Text(useElseIf ? "chained with `else if`" : "five independent `if`s")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .tint(accent)
                    .onChange(of: useElseIf) { _ in index = 0 }
                }
            }

            VizPanel { CodePane(lines: chainCode, activeLine: chainStep.line, accent: accent) }

            VizPanel { StepPlayer(index: $index, count: chainSteps.count, accent: accent) }

            StepNote(text: chainStep.note,
                     accent: chainStep.warning ? .red : accent,
                     icon: chainStep.warning ? "exclamationmark.triangle.fill" : "arrow.turn.down.right")

            VizPanel(title: "tests, in order", accent: accent) {
                VStack(spacing: 5) {
                    ForEach(chainStep.rows) { row in condRow(row) }
                }
            }

            HStack(spacing: 12) {
                VarChip(name: "g", value: chainStep.grade, type: "String",
                        color: chainStep.warning ? .red : .green, highlighted: true)
                VarChip(name: "expected", value: Self.correctGrade(Int(score)),
                        type: "String", color: .secondary)
            }
        }
    }

    private func condRow(_ row: CondRow) -> some View {
        let (icon, color, label): (String, Color, String) = {
            switch row.state {
            case .pending:  return ("circle", .secondary, "not reached yet")
            case .isTrue:   return ("checkmark.circle.fill", .green, "true → body runs")
            case .isFalse:  return ("xmark.circle.fill", .red, "false → body skipped")
            case .skipped:  return ("minus.circle.fill", .secondary, "never evaluated")
            }
        }()
        return HStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 13)).foregroundStyle(color)
            Text(row.test)
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(row.state == .skipped ? .secondary : .primary)
            Spacer(minLength: 4)
            if row.fired {
                Text(row.overwrites ? "g = \(row.assign)  ⚠︎ overwrites" : "g = \(row.assign)")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(row.overwrites ? .red : .green)
            } else {
                Text(label).font(.system(size: 10)).foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 9).padding(.vertical, 7)
        .background(RoundedRectangle(cornerRadius: 8).fill(color.opacity(row.state == .pending ? 0.05 : 0.12)))
    }

    // MARK: - Tab 2: short-circuit

    private var scCode: [String] {
        useOr
        ? ["int[] a = {5, -3, 8};   // length 3",
           "int i = \(Int(i));",
           "if (i >= a.length || a[i] > 0) {",
           "    // safe: a[i] is read only when i < length",
           "}"]
        : ["int[] a = {5, -3, 8};   // length 3",
           "int i = \(Int(i));",
           "if (i < a.length && a[i] > 0) {",
           "    // safe: a[i] is read only when i < length",
           "}"]
    }

    private var scLeft: Bool { useOr ? Int(i) >= arr.count : Int(i) < arr.count }
    private var scEvaluatesRight: Bool { useOr ? !scLeft : scLeft }
    private var scRight: Bool? {
        guard scEvaluatesRight else { return nil }
        let idx = Int(i)
        guard idx >= 0 && idx < arr.count else { return nil }
        return arr[idx] > 0
    }
    private var scResult: Bool {
        if useOr { return scLeft || (scRight ?? false) }
        return scLeft && (scRight ?? false)
    }

    private var shortCircuitTab: some View {
        VStack(alignment: .leading, spacing: 16) {

            VizPanel(title: "input", accent: accent) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("i = \(Int(i))")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundStyle(accent)
                    Slider(value: $i, in: 0...5, step: 1).tint(accent)
                    Picker("op", selection: $useOr) {
                        Text("&&").tag(false)
                        Text("||").tag(true)
                    }
                    .pickerStyle(.segmented)
                }
            }

            VizPanel { CodePane(lines: scCode, activeLine: 2, accent: accent) }

            VizPanel(title: "array", accent: .teal) {
                HStack(spacing: 6) {
                    ForEach(Array(arr.enumerated()), id: \.offset) { k, v in
                        VStack(spacing: 2) {
                            Text("\(v)")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .frame(width: 40, height: 34)
                                .background(RoundedRectangle(cornerRadius: 7)
                                    .fill(k == Int(i) ? Color.teal.opacity(0.35) : Color.teal.opacity(0.10)))
                            Text("[\(k)]").font(.system(size: 9, design: .monospaced)).foregroundStyle(.secondary)
                        }
                    }
                    if Int(i) >= arr.count {
                        VStack(spacing: 2) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                                .frame(width: 40, height: 34)
                                .background(RoundedRectangle(cornerRadius: 7).fill(Color.red.opacity(0.15)))
                            Text("[\(Int(i))]").font(.system(size: 9, design: .monospaced)).foregroundStyle(.red)
                        }
                    }
                }
            }

            VizPanel(title: "evaluation, left to right", accent: accent) {
                VStack(alignment: .leading, spacing: 8) {
                    operandRow(text: useOr ? "i >= a.length" : "i < a.length",
                               state: scLeft ? "true" : "false",
                               color: scLeft ? .green : .red,
                               note: scEvaluatesRight ? "not decisive → the right operand must be evaluated"
                                                      : "decisive on its own")
                    operandRow(text: "a[i] > 0",
                               state: scEvaluatesRight ? (scRight == true ? "true" : "false") : "not evaluated",
                               color: scEvaluatesRight ? ((scRight == true) ? .green : .red) : .secondary,
                               note: scEvaluatesRight
                                     ? "index \(Int(i)) is inside the array, the read is legal"
                                     : "⚡︎ short-circuit — and this is exactly what saves you: reading a[\(Int(i))] would throw ArrayIndexOutOfBoundsException")
                    Divider()
                    HStack {
                        Text("whole condition")
                            .font(.system(size: 12, weight: .medium)).foregroundStyle(.secondary)
                        Spacer()
                        VerdictPill(text: scResult ? "true" : "false", ok: scResult)
                    }
                }
            }

            VizPanel(title: "what to remember", accent: accent) {
                Text(useOr
                     ? "`||` stops as soon as an operand is true. Put the cheap or protective test first: `i >= n || a[i] > 0` never reads out of bounds. The strict versions `&` and `|` always evaluate both sides — never use them on guards."
                     : "`&&` stops as soon as an operand is false. That is why the length check must come FIRST: swapping the two operands turns a correct program into a crash for i = 3.")
                    .font(.system(size: 13))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func operandRow(text: String, state: String, color: Color, note: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(text).font(.system(size: 13, design: .monospaced))
                Spacer()
                Text(state)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(color)
                    .padding(.horizontal, 7).padding(.vertical, 3)
                    .background(Capsule().fill(color.opacity(0.16)))
            }
            Text(note)
                .font(.system(size: 11))
                .foregroundStyle(color == .secondary ? .orange : .secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(9)
        .background(RoundedRectangle(cornerRadius: 9).fill(Color.secondary.opacity(0.07)))
    }

    // MARK: - Tab 3: truth table

    private var truthTableTab: some View {
        VStack(alignment: .leading, spacing: 16) {

            VizPanel(title: "operands", accent: accent) {
                HStack(spacing: 14) {
                    Toggle("p", isOn: $pTrue).tint(.green)
                    Toggle("q", isOn: $qTrue).tint(.green)
                }
                .font(.system(size: 15, weight: .semibold, design: .monospaced))
            }

            VizPanel(title: "truth table", accent: accent) {
                VStack(spacing: 0) {
                    tableHeader
                    ForEach(0..<4, id: \.self) { r in
                        let p = (r / 2) == 1
                        let q = (r % 2) == 1
                        tableRow(p: p, q: q, active: p == pTrue && q == qTrue)
                    }
                }
            }

            VizPanel(title: "de morgan, on the current row", accent: accent) {
                let lhs = !(pTrue && qTrue)
                let rhs = (!pTrue) || (!qTrue)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("!(p && q)").font(.system(size: 13, design: .monospaced))
                        Spacer()
                        VerdictPill(text: lhs ? "true" : "false", ok: lhs)
                    }
                    HStack {
                        Text("!p || !q").font(.system(size: 13, design: .monospaced))
                        Spacer()
                        VerdictPill(text: rhs ? "true" : "false", ok: rhs)
                    }
                    Text(lhs == rhs
                         ? "Same value — as on all four rows. Negating an && flips it into an ||, and vice versa: that is how you rewrite a loop guard when you invert it."
                         : "—")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var tableHeader: some View {
        HStack(spacing: 0) {
            ForEach(["p", "q", "p&&q", "p||q", "!p", "p^q"], id: \.self) { h in
                Text(h)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 6)
    }

    private func tableRow(p: Bool, q: Bool, active: Bool) -> some View {
        let values = [p, q, p && q, p || q, !p, p != q]
        return HStack(spacing: 0) {
            ForEach(Array(values.enumerated()), id: \.offset) { _, v in
                Text(v ? "T" : "F")
                    .font(.system(size: 13, weight: active ? .bold : .regular, design: .monospaced))
                    .foregroundStyle(v ? Color.green : Color.red)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 7)
        .background(RoundedRectangle(cornerRadius: 7).fill(active ? accent.opacity(0.18) : .clear))
    }

    // MARK: - Trace

    private static func correctGrade(_ s: Int) -> String {
        if s >= 90 { return "A" }
        if s >= 80 { return "B" }
        if s >= 70 { return "C" }
        if s >= 60 { return "D" }
        return "F"
    }

    private static func chainTrace(score s: Int, useElseIf: Bool) -> [IfStep] {
        let tests: [(String, String)] = [
            ("s >= 90", "\"A\""), ("s >= 80", "\"B\""),
            ("s >= 70", "\"C\""), ("s >= 60", "\"D\""), ("s < 60", "\"F\""),
        ]
        let holds: [Bool] = [s >= 90, s >= 80, s >= 70, s >= 60, s < 60]

        var rows = tests.enumerated().map { CondRow(id: $0.offset, test: $0.element.0, assign: $0.element.1) }
        var steps: [IfStep] = []
        var grade = "?"
        var assignedOnce = false

        // line of test k in the generated listing
        func lineOf(_ k: Int) -> Int { useElseIf ? 1 + k * 2 : 1 + k * 3 }

        steps.append(IfStep(rows: rows, line: 0, note: "g starts at \"?\". The tests will now be evaluated top to bottom — order is part of the semantics.", grade: grade))

        for k in 0..<tests.count {
            rows[k].state = holds[k] ? .isTrue : .isFalse
            let verdict = holds[k] ? "true" : "false"

            if holds[k] {
                let overwrote = assignedOnce && !useElseIf
                rows[k].fired = true
                rows[k].overwrites = overwrote
                grade = tests[k].1.replacingOccurrences(of: "\"", with: "")
                assignedOnce = true

                if useElseIf {
                    for j in (k + 1)..<tests.count { rows[j].state = .skipped }
                    steps.append(IfStep(rows: rows, line: lineOf(k),
                                        note: "\(tests[k].0) with s = \(s) is \(verdict) → g = \(grade). Because the following tests are attached with `else`, the machine jumps straight past all of them: they are not even evaluated.",
                                        grade: grade))
                    return steps
                } else {
                    steps.append(IfStep(rows: rows, line: lineOf(k),
                                        note: overwrote
                                              ? "\(tests[k].0) is \(verdict) too → g = \(grade), silently replacing the previous answer. Independent `if`s do not exclude each other."
                                              : "\(tests[k].0) is \(verdict) → g = \(grade).",
                                        grade: grade, warning: overwrote))
                }
            } else {
                steps.append(IfStep(rows: rows, line: lineOf(k),
                                    note: "\(tests[k].0) with s = \(s) is \(verdict) → this body is skipped, evaluation continues below.",
                                    grade: grade))
            }
        }

        let wrong = grade != correctGrade(s)
        steps.append(IfStep(rows: rows, line: -1,
                            note: wrong
                                  ? "Final answer g = \(grade), but the expected grade is \(correctGrade(s)). Every true test fired and the last one won. Chaining with `else if` — or reversing the order of the tests — fixes it."
                                  : "Final answer g = \(grade), which is correct here. Try s = 95 with independent `if`s to see the same code produce a wrong grade.",
                            grade: grade, warning: wrong))
        return steps
    }
}

#Preview {
    IfElseView()
}
