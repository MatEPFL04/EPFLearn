//
//  SequenceView.swift
//  LearnViz
//
//  Subsequences: one limit, several, infinitely many, or none.
//  Scrubbing replaces play/pause: the user walks through the terms by finger,
//  with no Timer running in the background.
//

import SwiftUI

// MARK: - Model

private struct SubDef: Identifiable {
    let id: Int
    let color: Color
    let belongs: (Int) -> Bool
    let label: String
    let limit: Double?
}

private struct SeqDef {
    let f: (Int) -> Double
    let first: Int
    let count: Int
    let initialShown: Int
    let yRange: ClosedRange<Double>
    /// Drawn as a translucent band when the set of subsequential limits is a
    /// whole interval rather than a handful of values.
    let limitBand: ClosedRange<Double>?
    let summary: String
    let subs: [SubDef]
}

private let subColors: [Color] = [
    Color(red: 0.20, green: 0.72, blue: 0.85),
    Color(red: 0.95, green: 0.55, blue: 0.15),
    Color(red: 0.90, green: 0.35, blue: 0.60)
]

/// Named presets so a question can target one sequence without relying on an
/// array index. Adding a case never shifts the others.
enum SequencePreset: String, CaseIterable, Identifiable {
    case inverseN
    case cosQuarterTurn
    case alternatingRatio
    case alternatingGrowth

    var id: Self { self }

    var displayName: String {
        switch self {
        case .inverseN:          return "1/n"
        case .cosQuarterTurn:    return "cos(nπ/2)"
        case .alternatingRatio:  return "(−1)ⁿ · n/(n+1)"
        case .alternatingGrowth: return "(−1)ⁿ(n+1)"
        }
    }

    fileprivate var definition: SeqDef {
        switch self {

        case .inverseN:
            return SeqDef(
                f: { 1 / Double($0) },
                first: 1, count: 24, initialShown: 6,
                yRange: -0.12...1.15,
                limitBand: nil,
                summary: "The sequence converges, so every subsequence converges to the same limit.",
                subs: [
                    SubDef(id: 0, color: subColors[0], belongs: { _ in true },
                           label: "→ 0", limit: 0)
                ]
            )

        case .cosQuarterTurn:
            return SeqDef(
                f: { cos(Double($0) * .pi / 2) },
                first: 0, count: 24, initialShown: 6,
                yRange: -1.2...1.2,
                limitBand: nil,
                summary: "Bounded and periodic. Three subsequences converge, to three different limits, while the sequence itself has none.",
                subs: [
                    SubDef(id: 0, color: subColors[0], belongs: { $0 % 4 == 0 },
                           label: "→ 1", limit: 1),
                    SubDef(id: 1, color: subColors[1], belongs: { $0 % 2 == 1 },
                           label: "→ 0", limit: 0),
                    SubDef(id: 2, color: subColors[2], belongs: { $0 % 4 == 2 },
                           label: "→ −1", limit: -1)
                ]
            )

        case .alternatingRatio:
            // Two limits, like a plain (−1)ⁿ, but neither is ever reached: the
            // terms only creep toward ±1 from the inside.
            return SeqDef(
                f: { ($0 % 2 == 0 ? 1.0 : -1.0) * Double($0) / Double($0 + 1) },
                first: 1, count: 24, initialShown: 6,
                yRange: -1.25...1.25,
                limitBand: nil,
                summary: "Bounded, with two subsequential limits. Neither +1 nor −1 is ever attained: the terms only approach them.",
                subs: [
                    SubDef(id: 0, color: subColors[0], belongs: { $0 % 2 == 0 },
                           label: "→ 1", limit: 1),
                    SubDef(id: 1, color: subColors[2], belongs: { $0 % 2 == 1 },
                           label: "→ −1", limit: -1)
                ]
            )

        case .alternatingGrowth:
            return SeqDef(
                f: { ($0 % 2 == 0 ? 1.0 : -1.0) * Double($0 + 1) },
                first: 0, count: 16, initialShown: 6,
                yRange: -17...17,
                limitBand: nil,
                summary: "Unbounded, so Bolzano-Weierstrass does not apply. No subsequence converges to a finite limit.",
                subs: []
            )
        }
    }
}

// MARK: - View

struct SequenceView: View {

    @State private var preset: SequencePreset
    @State private var shown: Int

    init(_ initial: SequencePreset = .inverseN) {
        _preset = State(initialValue: initial)
        _shown  = State(initialValue: initial.definition.initialShown)
    }

    private var seq: SeqDef { preset.definition }
    private var lastN: Int { seq.first + seq.count - 1 }
    private var currentN: Int { seq.first + shown - 1 }
    private func sub(for n: Int) -> SubDef? { seq.subs.first { $0.belongs(n) } }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            VStack(alignment: .leading, spacing: 2) {
                Text("Subsequences").font(.headline)
                Text("uₙ = \(preset.displayName)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            SeqPlotCanvas(
                nRange: seq.first...lastN,
                yRange: seq.yRange,
                height: 230,
                onScrub: { shown = max(1, $0 - seq.first + 1) },
                content: { ctx, s in draw(&ctx, s) }
            )

            Picker("Sequence", selection: $preset) {
                ForEach(SequencePreset.allCases) { option in
                    Text(option.displayName).tag(option)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .onChange(of: preset) { _, new in
                shown = new.definition.initialShown
            }

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
                Text("n")
                    .font(.caption.bold())
                    .foregroundStyle(SeqPalette.term)
                    .frame(width: 16)
                Slider(
                    value: .init(get: { Double(shown) },
                                 set: { shown = Int($0) }),
                    in: 1...Double(seq.count),
                    step: 1
                )
                .tint(SeqPalette.term)
                Text("\(currentN)")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .frame(width: 34, alignment: .trailing)
            }
            .padding(.horizontal, 8)

            SeqReadout(
                badge: "n = \(currentN)",
                badgeColor: sub(for: currentN)?.color ?? SeqPalette.term,
                detail: "uₙ = \(String(format: "%.4f", seq.f(currentN)))"
            )

            Text(seq.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: 640)
    }

    // MARK: - Drawing

    private func draw(_ ctx: inout GraphicsContext, _ s: SeqSpace) {

        // A whole interval of subsequential limits: shade it, rather than draw
        // an impossible number of dashed lines.
        if let band = seq.limitBand {
            let top    = s.y(band.upperBound)
            let bottom = s.y(band.lowerBound)
            let rect = CGRect(x: s.left, y: top,
                              width: s.right - s.left, height: bottom - top)
            ctx.fill(Path(rect), with: .color(SeqPalette.limit.opacity(0.10)))
            ctx.label("every point is a limit",
                      at: CGPoint(x: s.left + 68, y: top + 10),
                      size: 9, SeqPalette.limit, bold: true)
        }

        // Subsequence limits, visible from the start: the colours are heading
        // toward them.
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
                // A term outside the frame: an arrow reads better than a dot
                // squashed against the edge.
                var tri = Path()
                let dir: CGFloat = v > seq.yRange.upperBound ? -1 : 1
                tri.move(to: CGPoint(x: s.x(n), y: y + dir * 7))
                tri.addLine(to: CGPoint(x: s.x(n) - 5, y: y))
                tri.addLine(to: CGPoint(x: s.x(n) + 5, y: y))
                tri.closeSubpath()
                ctx.fill(tri, with: .color(color))
            } else {
                ctx.dot(CGPoint(x: s.x(n), y: y), color,
                        radius: n == currentN ? 5 : (sub(for: n) != nil ? 4 : 2.6))
            }
        }
    }
}

#Preview {
    ScrollView { SequenceView() }
        .preferredColorScheme(.dark)
}
