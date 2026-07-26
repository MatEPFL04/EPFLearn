//
//  GaussView.swift
//  EPFLearn
//
//  Gaussian elimination shown twice at once: as a system of equations,
//  and as the augmented matrix. Reuses BracketShape from Matrix3DView.swift.
//

import SwiftUI

// MARK: - Elementary row operations

enum RowOp {
    case scale(row: Int, factor: Double)
    case combine(target: Int, source: Int, factor: Double)
    case swap(Int, Int)

    /// Full notation, written next to the matrix.
    var matrixLabel: String {
        switch self {
        case .scale(let r, let f):
            return "L\(sub(r)) → \(coefficient(f))L\(sub(r))"
        case .combine(let t, let s, let f):
            return "L\(sub(t)) → L\(sub(t)) \(signedTerm(f, "L\(sub(s))"))"
        case .swap(let a, let b):
            return "L\(sub(a)) ↔ L\(sub(b))"
        }
    }

    /// Compact operator, hanging off the equation.
    var systemBadge: String {
        switch self {
        case .scale(_, let f):          return "× \(pretty(f))"
        case .combine(_, let s, let f): return signedTerm(f, "L\(sub(s))")
        case .swap(_, let b):           return "↔ L\(sub(b))"
        }
    }

    var target: Int {
        switch self {
        case .scale(let r, _):      return r
        case .combine(let t, _, _): return t
        case .swap(let a, _):       return a
        }
    }

    var source: Int? {
        switch self {
        case .scale:                return nil
        case .combine(_, let s, _): return s
        case .swap(_, let b):       return b
        }
    }

    func applied(to m: [[Double]]) -> [[Double]] {
        var out = m
        switch self {
        case .scale(let r, let f):
            for c in 0..<4 { out[r][c] = clean(out[r][c] * f) }
        case .combine(let t, let s, let f):
            for c in 0..<4 { out[t][c] = clean(out[t][c] + f * out[s][c]) }
        case .swap(let a, let b):
            out.swapAt(a, b)
        }
        return out
    }
}

struct GaussStep {
    let op: RowOp
    let caption: String
}

/// A worked example: a starting matrix, a script, and every intermediate state.
struct GaussExample {
    let name: String
    let start: [[Double]]
    let script: [GaussStep]
    let states: [[[Double]]]

    init(name: String, start: [[Double]], script: [GaussStep]) {
        self.name = name
        self.start = start
        self.script = script
        var all = [start]
        var cur = start
        for s in script { cur = s.op.applied(to: cur); all.append(cur) }
        self.states = all
    }
}

// MARK: - Main view

struct GaussView: View {

    @State private var cursor: Double = 0
    @State private var exampleIndex: Int = 0

    static let warm = Color(red: 1.00, green: 0.80, blue: 0.26)
    static let warmUI = Color(red: 0.72, green: 0.50, blue: 0.00)
    static let cellW: CGFloat = 40
    static let rowH: CGFloat = 30

    // MARK: Examples

    /// x = 1, y = 2, z = 3.
    static let unique = GaussExample(
        name: "Unique solution",
        start: [[1, 2, 1, 8],
                [2, 1, -1, 1],
                [1, -1, 2, 5]],
        script: [
            GaussStep(op: .combine(target: 1, source: 0, factor: -2),
                      caption: "Clear x from L₂ using the pivot of L₁."),
            GaussStep(op: .combine(target: 2, source: 0, factor: -1),
                      caption: "Clear x from L₃ with the same pivot."),
            GaussStep(op: .scale(row: 1, factor: -1.0 / 3),
                      caption: "Normalise the second pivot to 1."),
            GaussStep(op: .combine(target: 0, source: 1, factor: -2),
                      caption: "Clear y from L₁ — Jordan also cleans upwards."),
            GaussStep(op: .combine(target: 2, source: 1, factor: 3),
                      caption: "Clear y from L₃."),
            GaussStep(op: .scale(row: 2, factor: 1.0 / 4),
                      caption: "Normalise the third pivot to 1."),
            GaussStep(op: .combine(target: 0, source: 2, factor: 1),
                      caption: "Clear z from L₁."),
            GaussStep(op: .combine(target: 1, source: 2, factor: -1),
                      caption: "Clear z from L₂ — the left block is now the identity.")
        ])

    /// L₂ = 2·L₁ on the left, but not on the right: the elimination exposes 0 = 1.
    static let none = GaussExample(
        name: "No solution",
        start: [[1, 1, 1, 2],
                [2, 2, 2, 5],
                [1, -1, 0, 1]],
        script: [
            GaussStep(op: .combine(target: 1, source: 0, factor: -2),
                      caption: "Clear x from L₂ — watch what happens to the constant."),
            GaussStep(op: .combine(target: 2, source: 0, factor: -1),
                      caption: "Clear x from L₃ as usual."),
            GaussStep(op: .scale(row: 2, factor: -1.0 / 2),
                      caption: "Normalise L₃ to expose the second pivot."),
            GaussStep(op: .swap(1, 2),
                      caption: "Move the zero line to the bottom: the staircase is done.")
        ])

    /// L₂ = 2·L₁ on both sides: one equation is pure redundancy.
    static let many = GaussExample(
        name: "Infinitely many",
        start: [[1, 1, 1, 3],
                [2, 2, 2, 6],
                [1, -1, 0, 0]],
        script: [
            GaussStep(op: .combine(target: 1, source: 0, factor: -2),
                      caption: "Clear x from L₂ — the whole line vanishes, constant included."),
            GaussStep(op: .combine(target: 2, source: 0, factor: -1),
                      caption: "Clear x from L₃."),
            GaussStep(op: .scale(row: 2, factor: -1.0 / 2),
                      caption: "Normalise the second pivot to 1."),
            GaussStep(op: .swap(1, 2),
                      caption: "Move the empty line to the bottom."),
            GaussStep(op: .combine(target: 0, source: 1, factor: -1),
                      caption: "Clear y from L₁ — only two pivots exist, z stays free.")
        ])

    static let examples: [GaussExample] = [unique, none, many]

    private var example: GaussExample { GaussView.examples[exampleIndex] }
    private var step: Int { min(max(Int(cursor.rounded()), 0), example.script.count) }
    private var m: [[Double]] { example.states[step] }
    private var pending: RowOp? {
        step < example.script.count ? example.script[step].op : nil
    }
    private var done: Bool { step == example.script.count }

    // MARK: Verdict, read off the current matrix

    private struct Verdict {
        let title: String
        let detail: String
        let icon: String
        let color: Color
    }

    private var verdict: Verdict {
        for r in 0..<3 {
            let emptyLeft: Bool = (0..<3).allSatisfy { abs(m[r][$0]) < 1e-9 }
            if emptyLeft && abs(m[r][3]) > 1e-9 {
                return Verdict(title: "No solution",
                               detail: "L\(sub(r)) now reads 0 = \(pretty(m[r][3])). No triple (x, y, z) can satisfy that, so the three planes never meet.",
                               icon: "xmark.octagon.fill",
                               color: .red)
            }
        }
        let rank: Int = (0..<3).filter { r in
            !(0..<3).allSatisfy { abs(m[r][$0]) < 1e-9 }
        }.count
        if rank < 3 {
            return Verdict(title: "Infinitely many solutions",
                           detail: "Rank \(rank) < 3: one line dissolved entirely, so an unknown stays free and the solutions form a \(3 - rank == 1 ? "line" : "plane").",
                           icon: "infinity.circle.fill",
                           color: GaussView.warmUI)
        }
        if isIdentity {
            return Verdict(title: "Solved",
                           detail: solutionText,
                           icon: "checkmark.circle.fill",
                           color: .green)
        }
        return Verdict(title: "Unique solution ahead",
                       detail: "Three pivots, no contradiction: keep reducing until the left block is the identity.",
                       icon: "arrow.triangle.turn.up.right.circle.fill",
                       color: .cyan)
    }

    private var isIdentity: Bool {
        for r in 0..<3 {
            for c in 0..<3 {
                let expected: Double = (r == c) ? 1 : 0
                if abs(m[r][c] - expected) > 1e-9 { return false }
            }
        }
        return true
    }

    private var solutionText: String {
        let x: String = pretty(m[0][3])
        let y: String = pretty(m[1][3])
        let z: String = pretty(m[2][3])
        return "x = \(x)   ·   y = \(y)   ·   z = \(z)"
    }

    private var captionText: String {
        if done { return verdict.detail }
        return example.script[step].caption
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Gaussian Elimination")
                        .font(.title3.bold())
                    Text("One system, two notations, one operation at a time.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 2)

                stage
                stepControl
                verdictCard
            }
            .padding(14)
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Stage

    private var stage: some View {
        VStack(alignment: .leading, spacing: 9) {
            stageLabel("SYSTEM")

            VStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { r in systemRow(r) }
            }

            Rectangle()
                .frame(height: 0.5)
                .foregroundStyle(.white.opacity(0.12))
                .padding(.vertical, 3)

            stageLabel("AUGMENTED MATRIX")

            VStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { r in matrixRow(r) }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [Color(red: 0.10, green: 0.11, blue: 0.16),
                                    Color(red: 0.04, green: 0.05, blue: 0.08)],
                           startPoint: .top, endPoint: .bottom)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func stageLabel(_ s: String) -> some View {
        Text(s)
            .font(.system(size: 9, weight: .bold))
            .tracking(0.8)
            .foregroundStyle(.white.opacity(0.4))
    }

    // MARK: Equation row

    private func systemRow(_ r: Int) -> some View {
        HStack(spacing: 8) {
            equationText(r)
                .font(.system(size: 15, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Spacer(minLength: 6)
            if let op = pending, r == op.target || (op.source == r && isSwap(op)) {
                HStack(spacing: 5) {
                    Rectangle()
                        .frame(width: 1.5, height: 15)
                        .foregroundStyle(GaussView.warm.opacity(0.8))
                    Text(badge(for: op, row: r))
                        .font(.system(size: 12, weight: .heavy, design: .monospaced))
                        .foregroundStyle(GaussView.warm)
                }
            }
        }
        .padding(.horizontal, 8)
        .frame(height: GaussView.rowH + 2)
        .background(rowTint(r))
    }

    private func isSwap(_ op: RowOp) -> Bool {
        if case .swap = op { return true }
        return false
    }

    private func badge(for op: RowOp, row r: Int) -> String {
        if isSwap(op) && r != op.target { return "↔ L\(sub(op.target))" }
        return op.systemBadge
    }

    private func equationText(_ r: Int) -> Text {
        let names: [String] = ["x", "y", "z"]
        let colors: [Color] = [.red, .green, .blue]
        let dim: Color = Color.white.opacity(0.45)
        var out: Text = Text("")
        var started: Bool = false

        for c in 0..<3 {
            let v: Double = m[r][c]
            if abs(v) < 1e-9 { continue }
            let lead: String = started ? (v < 0 ? "  −  " : "  +  ") : (v < 0 ? "−" : "")
            let a: Double = abs(v)
            let coef: String = abs(a - 1) < 1e-9 ? "" : pretty(a)

            out = out + Text(lead).foregroundStyle(dim)
            out = out + Text(coef).foregroundStyle(Color.white)
            out = out + Text(names[c]).foregroundStyle(colors[c])
            started = true
        }
        if !started {
            out = out + Text("0").foregroundStyle(Color.white.opacity(0.5))
        }

        out = out + Text("  =  ").foregroundStyle(dim)
        out = out + Text(pretty(m[r][3])).foregroundStyle(GaussView.warm)
        return out
    }

    // MARK: Matrix row

    private func matrixRow(_ r: Int) -> some View {
        HStack(spacing: 3) {
            Text("L\(sub(r))")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.45))
                .frame(width: 18)

            BracketShape(leading: true)
                .stroke(Color.white.opacity(0.45), lineWidth: 1.2)
                .frame(width: 5, height: GaussView.rowH)

            ForEach(0..<3, id: \.self) { c in
                Text(pretty(m[r][c]))
                    .font(.system(size: 12.5, weight: .semibold, design: .monospaced))
                    .foregroundStyle(abs(m[r][c]) < 1e-9 ? Color.white.opacity(0.25) : Color.white)
                    .frame(width: GaussView.cellW, height: GaussView.rowH)
            }

            Rectangle()
                .frame(width: 1, height: GaussView.rowH)
                .foregroundStyle(.white.opacity(0.3))

            Text(pretty(m[r][3]))
                .font(.system(size: 12.5, weight: .heavy, design: .monospaced))
                .foregroundStyle(GaussView.warm)
                .frame(width: GaussView.cellW, height: GaussView.rowH)

            BracketShape(leading: false)
                .stroke(Color.white.opacity(0.45), lineWidth: 1.2)
                .frame(width: 5, height: GaussView.rowH)

            if let op = pending, r == op.target {
                Text(op.matrixLabel)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(GaussView.warm)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.leading, 5)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 4)
        .frame(height: GaussView.rowH)
        .background(rowTint(r))
    }

    private func rowTint(_ r: Int) -> some View {
        let isTarget: Bool = (pending?.target == r)
        let isSource: Bool = (pending?.source == r)
        let c: Color = isTarget ? GaussView.warm : (isSource ? Color.cyan : Color.clear)
        let o: Double = isTarget ? 0.13 : (isSource ? 0.10 : 0)
        return RoundedRectangle(cornerRadius: 6).fill(c.opacity(o))
    }

    // MARK: - Step control + example picker

    private var stepControl: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("STEP  \(step) / \(example.script.count)")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.7)
                    .foregroundStyle(.secondary)

                Slider(value: $cursor, in: 0...Double(example.script.count), step: 1)
                    .tint(GaussView.warmUI)

                Text(captionText)
                    .font(.system(size: 10.5))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 0) {
                Text("EXAMPLE")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.7)
                    .foregroundStyle(.secondary)
                Picker("", selection: $exampleIndex) {
                    ForEach(GaussView.examples.indices, id: \.self) { i in
                        Text(GaussView.examples[i].name)
                            .font(.system(size: 13, weight: .medium))
                            .tag(i)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 82)
                .clipped()
                .onChange(of: exampleIndex) { cursor = 0 }
            }
            .frame(width: 140)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 13).fill(Color(.secondarySystemGroupedBackground)))
    }

    // MARK: - Verdict + script

    private var verdictCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: verdict.icon).font(.system(size: 13))
                Text(verdict.title).font(.system(size: 12.5, weight: .bold))
            }
            .foregroundStyle(verdict.color)

            Divider()

            VStack(alignment: .leading, spacing: 3) {
                ForEach(example.script.indices, id: \.self) { i in
                    stepRow(i)
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 13).fill(Color(.secondarySystemGroupedBackground)))
    }

    /// Kept in its own function with explicit types: nested ternaries inlined in a
    /// ForEach are what blows up the type-checker.
    private func stepRow(_ i: Int) -> some View {
        let isCurrent: Bool = (i == step)
        let isPast: Bool = (i < step)
        let color: Color = isCurrent ? GaussView.warmUI
                                     : (isPast ? Color.secondary : Color.gray.opacity(0.5))
        let weight: Font.Weight = isCurrent ? .heavy : .semibold
        let number: String = "\(i + 1)."
        let label: String = example.script[i].op.matrixLabel

        return HStack(spacing: 6) {
            Text(number)
                .font(.system(size: 9.5, design: .monospaced))
                .foregroundStyle(Color.gray.opacity(0.6))
                .frame(width: 14, alignment: .trailing)
            Text(label)
                .font(.system(size: 10.5, weight: weight, design: .monospaced))
                .foregroundStyle(color)
        }
        .contentShape(Rectangle())
        .onTapGesture { cursor = Double(i) }
    }
}

// MARK: - Formatting helpers

/// Small rationals read far better than 0.3333 during an elimination.
private func pretty(_ x: Double) -> String {
    if abs(x) < 1e-9 { return "0" }
    if abs(x - x.rounded()) < 1e-9 { return String(Int(x.rounded())) }
    for d in 2...16 {
        let n = x * Double(d)
        if abs(n - n.rounded()) < 1e-9 { return "\(Int(n.rounded()))/\(d)" }
    }
    return String(format: "%.2f", x)
}

private func coefficient(_ f: Double) -> String {
    abs(f - 1) < 1e-9 ? "" : "\(pretty(f))·"
}

private func signedTerm(_ f: Double, _ label: String) -> String {
    let sign: String = f < 0 ? "−" : "+"
    let a: Double = abs(f)
    let coef: String = abs(a - 1) < 1e-9 ? "" : "\(pretty(a))·"
    return "\(sign) \(coef)\(label)"
}

private func sub(_ i: Int) -> String { ["₁", "₂", "₃"][i] }

/// Kills the −0 and the 1e-17 that elimination leaves behind.
private func clean(_ x: Double) -> Double {
    abs(x) < 1e-10 ? 0 : (x * 1e9).rounded() / 1e9
}

#Preview {
    GaussView()
        .preferredColorScheme(.dark)
}
