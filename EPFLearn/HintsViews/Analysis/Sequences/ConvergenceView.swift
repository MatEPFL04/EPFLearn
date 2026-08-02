//
//  ConvergenceView.swift
//  EPFLearn
//
//  ε-N definition of convergence. Tighten ε: the band shrinks, rank N moves forward.
//

import SwiftUI

private struct ConvCase: Identifiable {
    let id: Int
    let name: String
    let f: (Int) -> Double
    let limit: Double
    let converges: Bool
}

private let convCases: [ConvCase] = [
    ConvCase(id: 0, name: "1/n",      f: { 1 / Double($0) },                           limit: 0, converges: true),
    ConvCase(id: 1, name: "(−1)ⁿ/n",  f: { ($0 % 2 == 0 ? 1.0 : -1.0) / Double($0) },  limit: 0, converges: true),
    ConvCase(id: 2, name: "sin(n)/n", f: { sin(Double($0)) / Double($0) },             limit: 0, converges: true),
    ConvCase(id: 3, name: "(−1)ⁿ",    f: { $0 % 2 == 0 ? 1.0 : -1.0 },                 limit: 0, converges: false)
]

struct ConvergenceView: View {

    private let totalN = 40
    private let epsMin = 0.01, epsMax = 1.2

    @State private var index = 0
    /// Linear position ∈ [0,1], converted to ε on a log scale: small ε values
    /// deserve more slider range than large ones.
    @State private var sliderPos: Double = 0.55
    @State private var cursor: Int? = nil

    private var c: ConvCase { convCases[index] }
    private var epsilon: Double { exp(log(epsMin) + sliderPos * (log(epsMax) - log(epsMin))) }

    /// First rank from which all visible terms stay inside the band.
    private var critN: Int? {
        guard c.converges else { return nil }
        var n = totalN
        while n >= 1 {
            if abs(c.f(n) - c.limit) >= epsilon { return n < totalN ? n + 1 : nil }
            n -= 1
        }
        return 1
    }

    private var allInside: Bool {
        (1...totalN).allSatisfy { abs(c.f($0) - c.limit) < epsilon }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            VStack(alignment: .leading, spacing: 2) {
                Text("Convergence: the ε-N definition").font(.headline)
                Text("uₙ = \(c.name)   ·   ∀ε > 0, ∃N, ∀n ≥ N : |uₙ − L| < ε")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1).minimumScaleFactor(0.7)
            }

            SeqPlotCanvas(
                nRange: 1...totalN,
                yRange: -1.3...1.3,
                height: 250,
                onScrub: { cursor = $0 },
                content: { ctx, s in draw(&ctx, s) }
            )

            Picker("Sequence", selection: $index) {
                ForEach(convCases) { seq in
                    Text(seq.name).tag(seq.id)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .onChange(of: index) { cursor = nil }

            HStack(spacing: 8) {
                Text("ε").font(.caption.bold()).foregroundStyle(SeqPalette.limit).frame(width: 16)
                Slider(value: $sliderPos, in: 0...1).tint(SeqPalette.limit)
                Text(String(format: "%.3f", epsilon))
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .frame(width: 46, alignment: .trailing)
            }
            .padding(.horizontal, 8)

            verdict

            if let n = cursor {
                SeqReadout(badge: "n = \(n)", badgeColor: SeqPalette.cursor,
                           detail: "|u\(n) − L| = \(String(format: "%.4f", abs(c.f(n) - c.limit)))  \(abs(c.f(n) - c.limit) < epsilon ? "< ε ✓" : "≥ ε ✗")")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: 640)
    }

    @ViewBuilder
    private var verdict: some View {
        if !c.converges {
            if allInside {
                SeqReadout(badge: "ε ≥ 1", badgeColor: SeqPalette.ghost,
                           detail: "The band contains everything, but this would work for any 'limit'")
            } else {
                SeqReadout(badge: "No N", badgeColor: SeqPalette.outside,
                           detail: "Terms remain outside no matter which rank is chosen")
            }
        } else if let n = critN {
            SeqReadout(badge: "N = \(n)", badgeColor: SeqPalette.limit,
                       detail: "∀n ≥ \(n),  |uₙ − L| < ε")
        } else {
            SeqReadout(badge: "N > \(totalN)", badgeColor: SeqPalette.bound,
                       detail: "The rank exists, but beyond the \(totalN) plotted terms: increase ε")
        }
    }

    // MARK: Drawing

    private func draw(_ ctx: inout GraphicsContext, _ s: SeqSpace) {
        let color = c.converges ? SeqPalette.limit : SeqPalette.outside

        // ε band.
        let top = s.y(c.limit + epsilon), bot = s.y(c.limit - epsilon)
        ctx.fill(Path(CGRect(x: s.left, y: top, width: s.right - s.left, height: bot - top)),
                 with: .color(color.opacity(0.10)))
        for y in [top, bot] {
            ctx.line(CGPoint(x: s.left, y: y), CGPoint(x: s.right, y: y),
                     color.opacity(0.75), width: 1, dash: [5, 3])
        }
        ctx.label("L+ε", at: CGPoint(x: s.left + 16, y: top - 8), size: 9, color)
        ctx.label("L−ε", at: CGPoint(x: s.left + 16, y: bot + 8), size: 9, color)

        // Critical rank.
        if let n = critN {
            let x = s.x(n)
            ctx.line(CGPoint(x: x, y: 6), CGPoint(x: x, y: s.size.height - 6),
                     SeqPalette.bound.opacity(0.8), width: 1.5, dash: [4, 3])
            ctx.label("N = \(n)", at: CGPoint(x: x, y: 11), size: 9, SeqPalette.bound, bold: true)
        }

        var poly = Path()
        for n in 1...totalN {
            let p = CGPoint(x: s.x(n), y: s.y(c.f(n)))
            n == 1 ? poly.move(to: p) : poly.addLine(to: p)
        }
        ctx.stroke(poly, with: .color(SeqPalette.ghost.opacity(0.25)), lineWidth: 1)

        for n in 1...totalN {
            let inside = abs(c.f(n) - c.limit) < epsilon
            let p = CGPoint(x: s.x(n), y: s.y(c.f(n)))
            ctx.dot(p, inside ? SeqPalette.limit : SeqPalette.outside,
                    radius: cursor == n ? 5 : 3.2)
            if cursor == n {
                ctx.line(CGPoint(x: p.x, y: s.y(c.limit)), p, SeqPalette.cursor, width: 1.5)
            }
        }
    }
}

#Preview {
    ScrollView { ConvergenceView() }
}
