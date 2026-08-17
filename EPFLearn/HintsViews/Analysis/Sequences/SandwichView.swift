//
//  SandwichView.swift
//  EPFLearn
//
//  Squeeze (Sandwich) Theorem. Fixed scale: watch the vise close on the
//  first terms where the movement is readable. Beyond that, the cursor
//  and numerical readout take over.
//

import SwiftUI

private struct SqueezeCase: Identifiable {
    let id: Int
    let name: String
    let boundLabel: String
    let middle: (Int) -> Double
    let bound: (Int) -> Double          // positive envelope; negative is its opposite
}

private let squeezeCases: [SqueezeCase] = [
    SqueezeCase(
        id: 0, name: "(−1)ⁿ/n", boundLabel: "±1/n",
        middle: { ($0 % 2 == 0 ? 1.0 : -1.0) / Double($0) },
        bound:  { 1 / Double($0) }
    ),
    SqueezeCase(
        id: 1, name: "sin(n²)/√n", boundLabel: "±1/√n",
        middle: { sin(Double($0 * $0)) / sqrt(Double($0)) },
        bound:  { 1 / sqrt(Double($0)) }
    ),
    SqueezeCase(
        id: 2, name: "cos(n)/n²", boundLabel: "±1/n²",
        middle: { cos(Double($0)) / pow(Double($0), 2) },
        bound:  { 1 / pow(Double($0), 2) }
    ),
]

struct SandwichView: View {

    private let maxN = 40

    @State private var caseIndex = 0
    @State private var cursor: Int = 4

    private var c: SqueezeCase { squeezeCases[caseIndex] }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            VStack(alignment: .leading, spacing: 2) {
                VizHeader("Squeeze Theorem", subtitle: "Two bounds closing in force the middle to follow.")
                Text("−\(c.boundLabel.dropFirst()) ≤ uₙ ≤ \(c.boundLabel.dropFirst())  with  uₙ = \(c.name)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            SeqPlotCanvas(
                nRange: 1...maxN,
                yRange: -1.15...1.15,
                height: 240,
                onScrub: { cursor = $0 },
                content: { ctx, s in draw(&ctx, s) }
            )

            Picker("Sequence", selection: $caseIndex) {
                ForEach(squeezeCases) { Text($0.name).tag($0.id) }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .onChange(of: caseIndex) { cursor = 4 }

            legend

            HStack(spacing: 8) {
                VizSlider(label: "n", intValue: $cursor, range: 1...maxN,
                          accent: SeqPalette.cursor)
            }
            .padding(.horizontal, 8)

            SeqReadout(badge: "n = \(cursor)", badgeColor: SeqPalette.cursor,
                       detail: "\(f(-c.bound(cursor)))  ≤  \(f(c.middle(cursor)))  ≤  \(f(c.bound(cursor)))")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: 640)
    }

    private var legend: some View {
        HStack(spacing: 14) {
            legendItem(SeqPalette.bound, c.boundLabel)
            legendItem(SeqPalette.term, c.name)
            legendItem(SeqPalette.limit, "L = 0")
        }
        .font(.caption2)
    }

    private func legendItem(_ color: Color, _ text: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(text).foregroundStyle(color)
        }
    }

    // MARK: Drawing

    private func draw(_ ctx: inout GraphicsContext, _ s: SeqSpace) {
        let ns = Array(1...maxN)

        // Squeeze zone.
        var band = Path()
        band.move(to: CGPoint(x: s.x(1), y: s.y(c.bound(1))))
        for n in ns { band.addLine(to: CGPoint(x: s.x(n), y: s.y(c.bound(n)))) }
        for n in ns.reversed() { band.addLine(to: CGPoint(x: s.x(n), y: s.y(-c.bound(n)))) }
        band.closeSubpath()
        ctx.fill(band, with: .color(SeqPalette.bound.opacity(0.13)))

        // The two bounding sequences.
        for sign in [1.0, -1.0] {
            var env = Path()
            for (i, n) in ns.enumerated() {
                let p = CGPoint(x: s.x(n), y: s.y(sign * c.bound(n)))
                i == 0 ? env.move(to: p) : env.addLine(to: p)
            }
            ctx.stroke(env, with: .color(SeqPalette.bound), lineWidth: 1.6)
        }

        // The limit.
        ctx.line(CGPoint(x: s.left, y: s.y(0)), CGPoint(x: s.right, y: s.y(0)),
                 SeqPalette.limit.opacity(0.8), width: 1, dash: [5, 3])

        // The squeezed sequence in the middle.
        var poly = Path()
        for (i, n) in ns.enumerated() {
            let p = CGPoint(x: s.x(n), y: s.y(c.middle(n)))
            i == 0 ? poly.move(to: p) : poly.addLine(to: p)
        }
        ctx.stroke(poly, with: .color(SeqPalette.term.opacity(0.35)), lineWidth: 1)

        for n in ns {
            ctx.dot(CGPoint(x: s.x(n), y: s.y(c.bound(n))), SeqPalette.bound, radius: 2.2)
            ctx.dot(CGPoint(x: s.x(n), y: s.y(-c.bound(n))), SeqPalette.bound, radius: 2.2)
            ctx.dot(CGPoint(x: s.x(n), y: s.y(c.middle(n))), SeqPalette.term, radius: 3.2)
        }

        drawBracket(&ctx, s)
    }

    /// Vise materialized at the pointed index: two jaws and the term caught between them.
    private func drawBracket(_ ctx: inout GraphicsContext, _ s: SeqSpace) {
        let n = min(max(cursor, 1), maxN)
        let x = s.x(n)
        let up = s.y(c.bound(n)), down = s.y(-c.bound(n)), mid = s.y(c.middle(n))

        ctx.line(CGPoint(x: x, y: up), CGPoint(x: x, y: down),
                 SeqPalette.cursor.opacity(0.9), width: 1.5)
        for yy in [up, down] {
            ctx.line(CGPoint(x: x - 6, y: yy), CGPoint(x: x + 6, y: yy),
                     SeqPalette.cursor, width: 2)
        }
        ctx.dot(CGPoint(x: x, y: mid), SeqPalette.cursor, radius: 4.5)
        ctx.label("n = \(n)", at: CGPoint(x: x, y: 10), size: 9, SeqPalette.cursor, bold: true)
    }

    private func f(_ v: Double) -> String {
        abs(v) >= 0.001 || v == 0 ? String(format: "%+.4f", v) : String(format: "%+.1e", v)
    }
}

#Preview {
    ScrollView { SandwichView() }
}
