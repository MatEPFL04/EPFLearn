//
//  SeqPlotKit.swift
//  EPFLearn
//
//  Socle commun aux vues de suites (Sequence, Sandwich, Convergence).
//  Réutilise les primitives ctx.line / ctx.dot / ctx.label de TrigPlotKit.swift.
//

import SwiftUI

enum SeqPalette {
    static let term    = Color(red: 0.25, green: 0.55, blue: 0.95)   // uₙ
    static let bound   = Color(red: 0.95, green: 0.55, blue: 0.15)   // encadrement
    static let limit   = Color(red: 0.20, green: 0.72, blue: 0.45)   // L
    static let outside = Color(red: 0.90, green: 0.30, blue: 0.35)
    static let cursor  = Color(red: 0.55, green: 0.40, blue: 0.85)
    static let ghost   = Color(.secondaryLabel)
    static let ink     = Color(.label)
}

/// Repère (n, valeur) → pixels. La taille arrive du Canvas, jamais d'une constante.
struct SeqSpace {
    let size: CGSize
    let nRange: ClosedRange<Int>
    let yRange: ClosedRange<Double>

    private let padL: CGFloat = 30      // place pour les graduations Y
    private let padR: CGFloat = 12
    private let padV: CGFloat = 14

    func x(_ n: Int) -> CGFloat {
        let span = max(nRange.upperBound - nRange.lowerBound, 1)
        let t = CGFloat(n - nRange.lowerBound) / CGFloat(span)
        return padL + t * (size.width - padL - padR)
    }

    func y(_ v: Double) -> CGFloat {
        let lo = yRange.lowerBound, hi = yRange.upperBound
        let t = (min(max(v, lo), hi) - lo) / (hi - lo)
        return size.height - padV - CGFloat(t) * (size.height - 2 * padV)
    }

    /// Valeur hors cadre : on renvoie aussi le drapeau pour dessiner une flèche.
    func yClamped(_ v: Double) -> (y: CGFloat, offScreen: Bool) {
        (y(v), v < yRange.lowerBound || v > yRange.upperBound)
    }

    /// Indice le plus proche d'une abscisse écran — pour le scrub.
    func n(at px: CGFloat) -> Int {
        let span = max(nRange.upperBound - nRange.lowerBound, 1)
        let t = (px - padL) / max(size.width - padL - padR, 1)
        let raw = Double(nRange.lowerBound) + Double(t) * Double(span)
        return min(max(Int(raw.rounded()), nRange.lowerBound), nRange.upperBound)
    }

    var left: CGFloat { padL }
    var right: CGFloat { size.width - padR }
}

/// Graphe pleine largeur, hauteur fixée par l'appelant. Le Canvas reçoit sa
/// taille dans sa closure : rien à mesurer, rien à coder en dur.
struct SeqPlotCanvas: View {

    let nRange: ClosedRange<Int>
    let yRange: ClosedRange<Double>
    var height: CGFloat = 240
    var onScrub: ((Int) -> Void)? = nil
    let content: (inout GraphicsContext, SeqSpace) -> Void

    @State private var width: CGFloat = 0

    var body: some View {
        Canvas { ctx, size in
            let s = SeqSpace(size: size, nRange: nRange, yRange: yRange)
            let frame = Path(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 12)
            ctx.fill(frame, with: .color(Color(.secondarySystemBackground)))
            ctx.clip(to: frame)

            drawScaffold(&ctx, s)
            content(&ctx, s)
        }
        .frame(height: height)
        .background(GeometryReader { g in
            Color.clear.preference(key: SeqWidthKey.self, value: g.size.width)
        })
        .onPreferenceChange(SeqWidthKey.self) { width = $0 }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0).onChanged { g in
                guard let onScrub, width > 0 else { return }
                let s = SeqSpace(size: CGSize(width: width, height: height),
                                 nRange: nRange, yRange: yRange)
                onScrub(s.n(at: g.location.x))
            }
        )
    }

    /// Grille horizontale + axe n + graduations Y aux extrémités et à zéro.
    private func drawScaffold(_ ctx: inout GraphicsContext, _ s: SeqSpace) {
        let ticks = [yRange.lowerBound, 0, yRange.upperBound].filter {
            $0 >= yRange.lowerBound && $0 <= yRange.upperBound
        }
        for v in ticks {
            let yy = s.y(v)
            ctx.line(CGPoint(x: s.left, y: yy), CGPoint(x: s.right, y: yy),
                     SeqPalette.ghost.opacity(v == 0 ? 0.35 : 0.15),
                     width: v == 0 ? 1 : 0.5)
            ctx.label(fmtTick(v), at: CGPoint(x: s.left - 15, y: yy),
                      size: 8, SeqPalette.ghost)
        }
    }

    private func fmtTick(_ v: Double) -> String {
        if v == 0 { return "0" }
        let a = abs(v)
        if a >= 0.1  { return String(format: "%.2f", v) }
        if a >= 0.001 { return String(format: "%.3f", v) }
        return String(format: "%.0e", v)
    }
}

private struct SeqWidthKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

/// Bandeau de lecture commun aux trois vues.
struct SeqReadout: View {
    let badge: String
    let badgeColor: Color
    let detail: String

    var body: some View {
        HStack(spacing: 8) {
            Text(badge)
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 9).padding(.vertical, 3)
                .background(badgeColor.opacity(0.14), in: Capsule())
                .foregroundStyle(badgeColor)
            Text(detail)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
