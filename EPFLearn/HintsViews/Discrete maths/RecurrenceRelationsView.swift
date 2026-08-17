//
//  RecurrenceRelationsView.swift
//  EPFLearn
//
//  The point of a recurrence is the *unfolding*: the substitution chain that
//  runs a term back down to the base case, next to the growth curve.
//
//  The chart stops at a₇: past that the terms stop being checkable by hand,
//  and the unfolding below always runs down from the last term on the chart.
//
//  Chrome deliberately matches the sorting views: native picker, plain
//  secondarySystemBackground panels, solid system colours.
//

import SwiftUI

struct RecurrenceRelationsView: View {

    enum Kind: String, CaseIterable, Hashable {
        case arithmetic = "Arithmetic", geometric = "Geometric"
        case fibonacci = "Fibonacci"
    }

    private struct Recurrence {
        let letter: String
        let linear: (r: Int, c: Int)?
        let recurrenceLine: String
        let baseLine: String
        let value: (Int) -> Int
    }

    // MARK: State

    @State private var kind: Kind = .arithmetic
    @State private var terms = 8

    private static let a0 = 1

    private var model: Recurrence { recurrence(for: kind) }
    private var stepCount: Int { max(2, min(terms, maxTerms)) }

    /// The chart stops at a₇: everything below it then fits without scrolling.
    private let maxTerms = 8

    private var tint: Color {
        switch kind {
        case .arithmetic: return .blue
        case .geometric:  return .purple
        case .fibonacci:  return .orange
        }
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: 12) {
            VizHeader("Recurrence Relations", subtitle: "Each term is built from the ones before it.")

            definitionPanel
            chartPanel
            unfoldingPanel

            // Under the chart, like every other picker in the app.
            Picker("Kind", selection: $kind) {
                ForEach(Kind.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.menu)
            .labelsHidden()

            Spacer(minLength: 0)
        }
        .padding()
    }

    private func panel<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(.gray.opacity(0.2)))
    }

    // MARK: Definition

    private var definitionPanel: some View {
        panel {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(model.recurrenceLine)
                        .font(.system(.subheadline, design: .monospaced).bold())
                        .foregroundStyle(tint)
                    Text(model.baseLine)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 0)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            }
        }
    }

    // MARK: Growth

    private var chartPanel: some View {
        panel {
            VStack(alignment: .leading, spacing: 8) {
                curve(points: chartPoints, colour: tint)
                    .frame(height: 110)

                termsStrip

                VizSlider(label: "terms shown", intValue: $terms, range: 3...maxTerms,
                          accent: tint, caption: "up to \(label(stepCount - 1))")
            }
        }
    }

    private func curve(points: [CGPoint], colour: Color) -> some View {
        Canvas { ctx, size in
            guard points.count > 1 else { return }
            var path = Path()
            for (i, p) in points.enumerated() {
                let pt = CGPoint(x: p.x * size.width, y: 6 + p.y * (size.height - 12))
                if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            ctx.stroke(path, with: .color(colour), style: StrokeStyle(lineWidth: 2.5, lineJoin: .round))
            for p in points {
                let pt = CGPoint(x: p.x * size.width, y: 6 + p.y * (size.height - 12))
                ctx.fill(Path(ellipseIn: CGRect(x: pt.x - 2.5, y: pt.y - 2.5, width: 5, height: 5)),
                         with: .color(colour))
            }
        }
    }

    private var chartPoints: [CGPoint] {
        normalise((0..<stepCount).map { Double(model.value($0)) })
    }

    private func normalise(_ mapped: [Double]) -> [CGPoint] {
        let maxV = mapped.max() ?? 1, minV = mapped.min() ?? 0
        let span = max(maxV - minV, 0.0001)
        return mapped.enumerated().map { i, v in
            CGPoint(x: Double(i) / Double(max(stepCount - 1, 1)), y: 1 - (v - minV) / span)
        }
    }

    private var termsStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                ForEach(0..<stepCount, id: \.self) { i in
                    VStack(spacing: 0) {
                        Text(label(i))
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundStyle(.secondary)
                        Text("\(model.value(i))")
                            .font(.system(size: 12, design: .monospaced))
                            .contentTransition(.numericText())
                    }
                    .frame(minWidth: 38)
                    .padding(.vertical, 4)
                    .background(RoundedRectangle(cornerRadius: 6).fill(tint.opacity(0.12)))
                }
            }
        }
    }

    // MARK: Unfolding

    private var unfoldingPanel: some View {
        panel {
            VStack(alignment: .leading, spacing: 3) {
                ForEach(traceLines.indices, id: \.self) { i in
                    Text(traceLines[i])
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(i == traceLines.count - 1 ? .orange : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
            }
        }
    }

    private var traceLines: [String] {
        let m = model
        // Follows the chart: unfolding always starts from the last term drawn.
        let t = stepCount - 1
        guard t >= 1 else { return [] }

        switch kind {
        case .arithmetic, .geometric:
            guard let lin = m.linear else { return [] }
            var lines: [String] = []
            var A = 1, B = 0, j = 1
            while t - j >= 0 {
                let newA = A * lin.r
                let newB = B + A * lin.c
                let rhs = term(coefficient: newA, label: label(t - j), constant: newB)
                lines.append(j == 1 ? "\(label(t)) = \(rhs)" : "     = \(rhs)")
                A = newA; B = newB; j += 1
            }
            lines.append("     = \(A)·\(m.value(0)) + \(B) = \(m.value(t))")
            return lines

        case .fibonacci:
            var lines = ["\(label(0)) = \(m.value(0)),  \(label(1)) = \(m.value(1))"]
            for i in 2...max(2, t) where i < stepCount {
                lines.append("\(label(i)) = \(m.value(i - 1)) + \(m.value(i - 2)) = \(m.value(i))")
            }
            return lines
        }
    }

    private func term(coefficient: Int, label: String, constant: Int) -> String {
        let head = coefficient == 1 ? label : "\(coefficient)·\(label)"
        if constant == 0 { return head }
        return constant > 0 ? "\(head) + \(constant)" : "\(head) − \(-constant)"
    }

    private func label(_ position: Int) -> String {
        model.letter + DMMath.subscriptDigits(position)
    }

    // MARK: Catalogue

    private static func fib(_ n: Int) -> Int {
        if n == 0 { return 0 }
        var a = 0, b = 1
        for _ in 1..<max(n, 1) { let t = a + b; a = b; b = t }
        return b
    }

    /// aₙ for the linear family, from a₀ up. Static so the closures stored in
    /// Recurrence never capture the view.
    private static func linearValue(_ n: Int, r: Int, c: Int) -> Int {
        var v = a0
        guard n > 0 else { return v }
        for _ in 1...n { v = r * v + c }
        return v
    }

    private func recurrence(for kind: Kind) -> Recurrence {
        switch kind {
        case .arithmetic:
            return Recurrence(
                letter: "a", linear: (r: 1, c: 3),
                recurrenceLine: "aₙ = aₙ₋₁ + 3",
                baseLine: "a₀ = \(Self.a0)",
                value: { n in Self.a0 + 3 * n }
            )

        case .geometric:
            return Recurrence(
                letter: "a", linear: (r: 2, c: 1),
                recurrenceLine: "aₙ = 2·aₙ₋₁ + 1",
                baseLine: "a₀ = \(Self.a0)",
                value: { n in Self.linearValue(n, r: 2, c: 1) }
            )

        case .fibonacci:
            return Recurrence(
                letter: "F", linear: nil,
                recurrenceLine: "Fₙ = Fₙ₋₁ + Fₙ₋₂",
                baseLine: "F₀ = 0, F₁ = 1",
                value: { n in Self.fib(n) }
            )
        }
    }
}

#Preview {
    RecurrenceRelationsView()
}
