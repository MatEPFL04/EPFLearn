//
//  SandwichView.swift
//  EPFLearn
//
//  Théorème des gendarmes. Échelle fixe : on voit l'étau se refermer sur les
//  premiers termes, là où le mouvement est lisible. Au-delà, c'est le curseur
//  et la lecture chiffrée qui prennent le relais — pas un zoom.
//

import SwiftUI

private struct SqueezeCase: Identifiable {
    let id: Int
    let name: String
    let boundLabel: String
    let middle: (Int) -> Double
    let bound: (Int) -> Double          // enveloppe positive ; l'autre est son opposée
    let note: String
}

private let squeezeCases: [SqueezeCase] = [
    SqueezeCase(
        id: 0, name: "sin(n²)/√n", boundLabel: "±1/√n",
        middle: { sin(Double($0 * $0)) / sqrt(Double($0)) },
        bound:  { 1 / sqrt(Double($0)) },
        note: "sin(n²) oscille sans aucun motif — mais reste pris entre ±1/√n, qui tendent vers 0. L'oscillation devient sans importance."
    ),
    SqueezeCase(
        id: 1, name: "(−1)ⁿ/n", boundLabel: "±1/n",
        middle: { ($0 % 2 == 0 ? 1.0 : -1.0) / Double($0) },
        bound:  { 1 / Double($0) },
        note: "Le signe alterne à chaque pas, mais l'enveloppe ±1/n se referme quel que soit ce signe."
    ),
    SqueezeCase(
        id: 2, name: "cos(n)/n²", boundLabel: "±1/n²",
        middle: { cos(Double($0)) / pow(Double($0), 2) },
        bound:  { 1 / pow(Double($0), 2) },
        note: "Même principe, étau bien plus serré : ±1/n² se referme beaucoup plus vite que ±1/n."
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
                Text("Théorème des gendarmes").font(.headline)
                Text("−\(c.boundLabel.dropFirst()) ≤ uₙ ≤ \(c.boundLabel.dropFirst())  avec  uₙ = \(c.name)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            Picker("Suite", selection: $caseIndex) {
                ForEach(squeezeCases) { Text($0.name).tag($0.id) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .onChange(of: caseIndex) { cursor = 4 }

            SeqPlotCanvas(
                nRange: 1...maxN,
                yRange: -1.15...1.15,
                height: 240,
                onScrub: { cursor = $0 },
                content: { ctx, s in draw(&ctx, s) }
            )

            legend

            HStack(spacing: 8) {
                Text("n").font(.caption.bold()).foregroundStyle(SeqPalette.cursor).frame(width: 16)
                Slider(value: .init(get: { Double(cursor) }, set: { cursor = Int($0) }),
                       in: 1...Double(maxN), step: 1)
                    .tint(SeqPalette.cursor)
                Text("\(cursor)")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .frame(width: 30, alignment: .trailing)
            }
            .padding(.horizontal, 8)

            SeqReadout(badge: "n = \(cursor)", badgeColor: SeqPalette.cursor,
                       detail: "\(f(-c.bound(cursor)))  ≤  \(f(c.middle(cursor)))  ≤  \(f(c.bound(cursor)))")

            SeqReadout(badge: "étau", badgeColor: SeqPalette.bound,
                       detail: "largeur = \(f(2 * c.bound(cursor)))  ·  la suite n'a plus la place de s'éloigner de 0")

            Text(c.note)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
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

    // MARK: Tracé

    private func draw(_ ctx: inout GraphicsContext, _ s: SeqSpace) {
        let ns = Array(1...maxN)

        // Zone d'étau.
        var band = Path()
        band.move(to: CGPoint(x: s.x(1), y: s.y(c.bound(1))))
        for n in ns { band.addLine(to: CGPoint(x: s.x(n), y: s.y(c.bound(n)))) }
        for n in ns.reversed() { band.addLine(to: CGPoint(x: s.x(n), y: s.y(-c.bound(n)))) }
        band.closeSubpath()
        ctx.fill(band, with: .color(SeqPalette.bound.opacity(0.13)))

        // Les deux gendarmes.
        for sign in [1.0, -1.0] {
            var env = Path()
            for (i, n) in ns.enumerated() {
                let p = CGPoint(x: s.x(n), y: s.y(sign * c.bound(n)))
                i == 0 ? env.move(to: p) : env.addLine(to: p)
            }
            ctx.stroke(env, with: .color(SeqPalette.bound), lineWidth: 1.6)
        }

        // La limite.
        ctx.line(CGPoint(x: s.left, y: s.y(0)), CGPoint(x: s.right, y: s.y(0)),
                 SeqPalette.limit.opacity(0.8), width: 1, dash: [5, 3])

        // La suite prise au milieu.
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

    /// Étau matérialisé à l'indice pointé : deux mors et le terme coincé entre eux.
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
