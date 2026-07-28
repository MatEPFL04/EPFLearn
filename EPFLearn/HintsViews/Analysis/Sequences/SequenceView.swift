//
//  SequenceView.swift
//  EPFLearn
//
//  Sous-suites : convergence, limites multiples, ou aucune limite finie.
//  Le scrub remplace le Play/Pause — on avance dans la suite au doigt, sans
//  Timer qui tourne en fond.
//

import SwiftUI

private struct SubDef: Identifiable {
    let id: Int
    let color: Color
    let belongs: (Int) -> Bool
    let label: String
    let limit: Double?
}

private struct SeqDef: Identifiable {
    let id: Int
    let name: String
    let f: (Int) -> Double
    let first: Int
    let count: Int
    let yRange: ClosedRange<Double>
    let summary: String
    let subs: [SubDef]
}

private let subColors: [Color] = [
    Color(red: 0.20, green: 0.72, blue: 0.85),
    Color(red: 0.95, green: 0.55, blue: 0.15),
    Color(red: 0.90, green: 0.35, blue: 0.60)
]

private let sequences: [SeqDef] = [

    SeqDef(id: 0, name: "1/n", f: { 1 / Double($0) }, first: 1, count: 24,
           yRange: -0.12...1.15,
           summary: "La suite converge elle-même : toute sous-suite converge vers la même limite.",
           subs: [SubDef(id: 0, color: subColors[0], belongs: { _ in true }, label: "→ 0", limit: 0)]),

    SeqDef(id: 1, name: "cos(nπ/2)", f: { cos(Double($0) * .pi / 2) }, first: 0, count: 24,
           yRange: -1.2...1.2,
           summary: "Bornée et périodique : trois sous-suites convergent, vers trois limites différentes. La suite, elle, diverge.",
           subs: [
            SubDef(id: 0, color: subColors[0], belongs: { $0 % 4 == 0 }, label: "→ 1", limit: 1),
            SubDef(id: 1, color: subColors[1], belongs: { $0 % 2 == 1 }, label: "→ 0", limit: 0),
            SubDef(id: 2, color: subColors[2], belongs: { $0 % 4 == 2 }, label: "→ −1", limit: -1)
           ]),

    SeqDef(id: 2, name: "(−1)ⁿ(n+1)", f: { ($0 % 2 == 0 ? 1.0 : -1.0) * Double($0 + 1) },
           first: 0, count: 16, yRange: -17...17,
           summary: "Non bornée : Bolzano–Weierstrass ne s'applique pas. Aucune sous-suite ne converge vers une limite finie.",
           subs: [])
]

struct SequenceView: View {

    @State private var index = 0
    @State private var shown = 6

    private var seq: SeqDef { sequences[index] }
    private var lastN: Int { seq.first + seq.count - 1 }
    private func sub(for n: Int) -> SubDef? { seq.subs.first { $0.belongs(n) } }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            VStack(alignment: .leading, spacing: 2) {
                Text("Sous-suites").font(.headline)
                Text("uₙ = \(seq.name)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            Picker("Suite", selection: $index) {
                ForEach(sequences) { Text($0.name).tag($0.id) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .onChange(of: index) { shown = 6 }

            SeqPlotCanvas(
                nRange: seq.first...lastN,
                yRange: seq.yRange,
                height: 230,
                onScrub: { shown = max(1, $0 - seq.first + 1) },
                content: { ctx, s in draw(&ctx, s) }
            )

            if !seq.subs.isEmpty {
                HStack(spacing: 14) {
                    ForEach(seq.subs) { sub in
                        HStack(spacing: 5) {
                            Circle().fill(sub.color).frame(width: 8, height: 8)
                            Text(sub.label).foregroundStyle(sub.color)
                        }
                    }
                }
                .font(.caption2)
            }

            HStack(spacing: 8) {
                Text("n").font(.caption.bold()).foregroundStyle(SeqPalette.term).frame(width: 16)
                Slider(value: .init(get: { Double(shown) }, set: { shown = Int($0) }),
                       in: 1...Double(seq.count), step: 1)
                    .tint(SeqPalette.term)
                Text("\(seq.first + shown - 1)")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .frame(width: 34, alignment: .trailing)
            }
            .padding(.horizontal, 8)

            Text(seq.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: 640)
    }

    // MARK: Tracé

    private func draw(_ ctx: inout GraphicsContext, _ s: SeqSpace) {
        // Les limites des sous-suites, visibles dès le départ : c'est vers
        // elles que les couleurs vont converger.
        for sub in seq.subs {
            guard let l = sub.limit else { continue }
            let y = s.y(l)
            ctx.line(CGPoint(x: s.left, y: y), CGPoint(x: s.right, y: y),
                     sub.color.opacity(0.45), width: 1, dash: [5, 4])
            ctx.label(sub.label, at: CGPoint(x: s.right - 18, y: y - 9),
                      size: 9, sub.color, bold: true)
        }

        let visible = (0..<shown).map { seq.first + $0 }

        var poly = Path()
        for (i, n) in visible.enumerated() {
            let p = CGPoint(x: s.x(n), y: s.y(seq.f(n)))
            i == 0 ? poly.move(to: p) : poly.addLine(to: p)
        }
        ctx.stroke(poly, with: .color(SeqPalette.ghost.opacity(0.3)), lineWidth: 1)

        for n in visible {
            let v = seq.f(n)
            let (y, off) = s.yClamped(v)
            let color = sub(for: n)?.color ?? Color(white: 0.6)

            if off {
                // Terme sorti du cadre : une flèche vaut mieux qu'un point
                // écrasé contre le bord.
                var tri = Path()
                let dir: CGFloat = v > seq.yRange.upperBound ? -1 : 1
                tri.move(to: CGPoint(x: s.x(n), y: y + dir * 7))
                tri.addLine(to: CGPoint(x: s.x(n) - 5, y: y))
                tri.addLine(to: CGPoint(x: s.x(n) + 5, y: y))
                tri.closeSubpath()
                ctx.fill(tri, with: .color(color))
            } else {
                ctx.dot(CGPoint(x: s.x(n), y: y), color,
                        radius: sub(for: n) != nil ? 4 : 2.6)
            }
        }
    }
}

#Preview {
    ScrollView { SequenceView() }
}
