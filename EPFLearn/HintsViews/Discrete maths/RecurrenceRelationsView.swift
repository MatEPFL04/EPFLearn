//
//  RecurrenceRelationsView.swift
//  EPFLearn
//
//  Rebuilt: the point of a recurrence is the *unfolding*. This view shows the
//  substitution chain that turns a recursive definition into a closed form,
//  next to an animated growth curve with an optional log scale.
//

import SwiftUI

struct RecurrenceRelationsView: View {

    // MARK: Model

    enum Kind: String, CaseIterable, Hashable {
        case arithmetic, geometric, fibonacci

        var title: String {
            switch self {
            case .arithmetic: return "Arithmetic"
            case .geometric:  return "Geometric"
            case .fibonacci:  return "Fibonacci"
            }
        }
    }

    private struct Recurrence {
        let tint: Color
        let symbol: String
        let letter: String
        let firstIndex: Int
        /// (multiplier, added constant) for a first-order linear recurrence.
        let linear: (r: Int, c: Int)?
        let recurrenceLine: String
        let baseLine: String
        let closedForm: String
        let blurb: String
        let value: (Int) -> Int                        // by position (0-based)
    }

    // MARK: State

    @State private var kind: Kind = .geometric
    @State private var terms = 10
    @State private var logScale = false
    @State private var progress: CGFloat = 0

    private var model: Recurrence { Self.model(for: kind) }
    private var tint: Color { model.tint }
    private var stepCount: Int { max(2, terms) }
    private var stateKey: String { "\(kind.rawValue)-\(terms)-\(logScale)" }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                DMHero(title: "Recurrence Relations",
                       subtitle: model.blurb,
                       symbol: model.symbol,
                       tint: tint)

                DMSegmented(selection: $kind,
                            options: Kind.allCases,
                            label: { $0.title },
                            tint: tint)

                definitionCard
                chartCard
                termsCard
                unfoldingCard
            }
            .padding(20)
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: kind)
        }
        .background(DMAurora(tint: tint, accent: DMTheme.violet))
        .task(id: stateKey) {
            progress = 0
            withAnimation(.easeOut(duration: 0.9)) { progress = 1 }
        }
    }

    // MARK: Definition

    private var definitionCard: some View {
        DMCard(tint: tint) {
            VStack(alignment: .leading, spacing: 10) {
                DMSectionTitle(text: "Definition", symbol: "text.book.closed.fill", tint: tint)
                DMFormula(text: model.recurrenceLine, tint: tint, emphasised: true)
                DMFormula(text: model.baseLine, tint: tint)
            }
        }
    }

    // MARK: Chart

    private var chartCard: some View {
        DMCard(tint: tint) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    DMSectionTitle(text: "Growth", symbol: "chart.xyaxis.line", tint: tint)
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            logScale.toggle()
                        }
                    } label: {
                        Text(logScale ? "log scale" : "linear")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(logScale ? .white : tint)
                            .padding(.vertical, 5).padding(.horizontal, 10)
                            .background(Capsule().fill(logScale ? AnyShapeStyle(DMTheme.grad(tint))
                                                               : AnyShapeStyle(tint.opacity(0.14))))
                    }
                    .buttonStyle(.plain)
                }

                chartBody
                    .frame(height: 210)

                DMStepper(title: "Number of terms", value: $terms, range: 3...20, tint: tint)
            }
        }
    }

    private var chartBody: some View {
        GeometryReader { geo in
            let padLeading: CGFloat = 6
            let padTrailing: CGFloat = 6
            let padTop: CGFloat = 18
            let padBottom: CGFloat = 24
            let w = max(geo.size.width - padLeading - padTrailing, 1)
            let h = max(geo.size.height - padTop - padBottom, 1)
            let pts = chartPoints

            ZStack(alignment: .topLeading) {
                ForEach(0..<4, id: \.self) { i in
                    Rectangle()
                        .fill(Color.primary.opacity(0.06))
                        .frame(width: w, height: 1)
                        .offset(x: padLeading, y: padTop + h * CGFloat(i) / 3)
                }

                DMAreaShape(points: pts)
                    .fill(LinearGradient(colors: [tint.opacity(0.38), tint.opacity(0.02)],
                                         startPoint: .top, endPoint: .bottom))
                    .frame(width: w, height: h)
                    .offset(x: padLeading, y: padTop)
                    .opacity(Double(progress))

                DMPolyline(points: pts)
                    .trim(from: 0, to: progress)
                    .stroke(DMTheme.grad(tint),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .frame(width: w, height: h)
                    .offset(x: padLeading, y: padTop)
                    .shadow(color: tint.opacity(0.35), radius: 8, y: 4)

                ForEach(pts.indices, id: \.self) { i in
                    let reached = CGFloat(i) / CGFloat(max(pts.count - 1, 1)) <= progress
                    Circle()
                        .fill(Color(.systemBackground))
                        .overlay(Circle().strokeBorder(tint, lineWidth: 2))
                        .frame(width: 8, height: 8)
                        .position(x: padLeading + pts[i].x * w, y: padTop + pts[i].y * h)
                        .opacity(reached ? 1 : 0)
                }

                if let last = pts.last {
                    Text("\(model.value(stepCount - 1))")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.vertical, 3).padding(.horizontal, 7)
                        .background(Capsule().fill(tint))
                        .position(x: min(padLeading + last.x * w, geo.size.width - 28),
                                  y: max(padTop + last.y * h - 16, 10))
                        .opacity(Double(progress))
                }

                Text("n")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
                    .position(x: geo.size.width - 10, y: padTop + h + 10)
            }
        }
    }

    private var chartPoints: [CGPoint] {
        let raw = (0..<stepCount).map { Double(model.value($0)) }
        let mapped = logScale ? raw.map { log10(max($0, 0) + 1) } : raw
        let maxV = mapped.max() ?? 1
        let minV = mapped.min() ?? 0
        let span = max(maxV - minV, 0.0001)
        return mapped.enumerated().map { i, v in
            CGPoint(x: Double(i) / Double(max(stepCount - 1, 1)),
                    y: 1 - (v - minV) / span)
        }
    }

    // MARK: Terms strip

    private var termsCard: some View {
        DMCard(tint: tint) {
            VStack(alignment: .leading, spacing: 10) {
                DMSectionTitle(text: "The sequence", symbol: "list.number", tint: tint)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(0..<stepCount, id: \.self) { i in
                            VStack(spacing: 3) {
                                Text(label(i))
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                Text("\(model.value(i))")
                                    .font(.system(.subheadline, design: .rounded).weight(.heavy))
                                    .foregroundStyle(tint)
                                    .contentTransition(.numericText())
                            }
                            .frame(minWidth: 52)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(tint.opacity(0.10)))
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    // MARK: Unfolding - the pedagogical core

    private var unfoldingCard: some View {
        DMCard(tint: DMTheme.amber) {
            VStack(alignment: .leading, spacing: 10) {
                DMSectionTitle(text: kind == .fibonacci ? "Building it up" : "Unfolding the recursion",
                               symbol: "arrow.triangle.branch", tint: DMTheme.amber)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(traceLines.indices, id: \.self) { i in
                        Text(traceLines[i])
                            .font(.system(.footnote, design: .monospaced))
                            .foregroundStyle(i == traceLines.count - 1 ? DMTheme.amber : .primary)
                            .fontWeight(i == traceLines.count - 1 ? .bold : .regular)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(DMTheme.amber.opacity(0.08)))

            }
        }
    }

    private var traceLines: [String] {
        let m = model
        let t = min(stepCount - 1, 4)
        guard t >= 1 else { return [] }

        if let lin = m.linear {
            var lines: [String] = []
            var A = 1, B = 0
            var j = 1
            while t - j >= 0 {
                let newA = A * lin.r
                let newB = B + A * lin.c
                let rhs = term(coefficient: newA, label: label(t - j), constant: newB)
                lines.append(j == 1 ? "\(label(t)) = \(rhs)" : "     = \(rhs)")
                A = newA; B = newB
                j += 1
            }
            let base = m.value(0)
            lines.append("     = \(A)·\(base) + \(B) = \(m.value(t))")
            return lines
        }

        // Fibonacci: bottom-up ladder.
        var lines: [String] = ["\(label(0)) = \(m.value(0)),  \(label(1)) = \(m.value(1))"]
        for i in 2...max(2, t) where i < stepCount {
            lines.append("\(label(i)) = \(m.value(i - 1)) + \(m.value(i - 2)) = \(m.value(i))")
        }
        return lines
    }

    private func term(coefficient: Int, label: String, constant: Int) -> String {
        let head = coefficient == 1 ? label : "\(coefficient)·\(label)"
        return constant == 0 ? head : "\(head) + \(constant)"
    }

    private func label(_ position: Int) -> String {
        model.letter + DMMath.subscriptDigits(position + model.firstIndex)
    }

    // MARK: Catalogue

    private static func model(for kind: Kind) -> Recurrence {
        switch kind {
        case .arithmetic:
            return Recurrence(
                tint: DMTheme.cyan, symbol: "plus.forwardslash.minus", letter: "a",
                firstIndex: 0, linear: (r: 1, c: 3),
                recurrenceLine: "aₙ = aₙ₋₁ + 3",
                baseLine: "a₀ = 1",
                closedForm: "aₙ = 1 + 3n",
                blurb: "Each term adds a fixed step to the previous one, so growth is a straight line.",
                value: { 1 + 3 * $0 }
            )

        case .geometric:
            return Recurrence(
                tint: DMTheme.violet, symbol: "chart.line.uptrend.xyaxis", letter: "a",
                firstIndex: 0, linear: (r: 2, c: 0),
                recurrenceLine: "aₙ = 2·aₙ₋₁",
                baseLine: "a₀ = 1",
                closedForm: "aₙ = 2ⁿ",
                blurb: "Each term multiplies the previous one, so growth explodes exponentially.",
                value: { Int(pow(2.0, Double($0))) }
            )

        case .fibonacci:
            return Recurrence(
                tint: DMTheme.amber, symbol: "leaf.fill", letter: "F",
                firstIndex: 0, linear: nil,
                recurrenceLine: "Fₙ = Fₙ₋₁ + Fₙ₋₂",
                baseLine: "F₀ = 0,  F₁ = 1",
                closedForm: "Fₙ = (φⁿ − ψⁿ)/√5,  φ = (1+√5)/2",
                blurb: "Each term needs the two before it: a second-order recurrence with a golden-ratio closed form.",
                value: { n in
                    var a = 0, b = 1
                    if n == 0 { return 0 }
                    for _ in 1..<max(n, 1) { let t = a + b; a = b; b = t }
                    return b
                }
            )
        }
    }
}

#Preview {
    RecurrenceRelationsView()
}
