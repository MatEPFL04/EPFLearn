////
//  TrigonometricView.swift
//  EPFLearn
//
//  Cercle trigonométrique — cos, sin, tan. Vue autonome, sans mode complexe.
//
//  Cadrage fixe. La tangente est tracée jusqu'à sa vraie valeur et sort du
//  cadre : c'est le clip du Canvas qui la coupe, pas un plafond. Le segment
//  continue donc de travailler hors champ quand θ approche π/2.
//

import SwiftUI

struct TrigoView: View {

    @State private var theta: Double = .pi / 4

    /// Cercle unité + étiquettes (1.17) + axe des tangentes en x = 1.
    private let fitRadius: Double = 1.34

    private var cosT: Double { cos(theta) }
    private var sinT: Double { sin(theta) }

    /// Seuil bas : au-delà, les coordonnées du Path deviennent absurdes sans
    /// rien apporter — le trait est déjà sorti du cadre depuis longtemps.
    private var tanT: Double? { abs(cosT) < 0.02 ? nil : sinT / cosT }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 24) {
                plot.frame(width: 400, height: 400)
                VStack(alignment: .leading, spacing: 16) { panel; Spacer(minLength: 0) }
                    .frame(width: 300)
            }
            .padding(20)

            VStack(spacing: 14) {
                plot.frame(maxWidth: 520)
                panel
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    // MARK: Tracé

    private var plot: some View {
        TrigPlotCanvas(
            fitRadius: fitRadius,
            onDragChanged: { location, space in
                let (x, y) = space.math(location)
                theta = TrigAngles.snap(atan2(y, x))
            },
            content: { ctx, s in draw(&ctx, s) }
        )
    }

    private func draw(_ ctx: inout GraphicsContext, _ s: TrigSpace) {
        let c = cosT, y = sinT

        ctx.drawUnitCircle(s)
        ctx.drawArc(s, to: theta)

        ctx.line(s.point(0, 0), s.point(c, 0), TrigPalette.cosColor, width: 3)
        ctx.line(s.point(0, 0), s.point(0, y), TrigPalette.sinColor, width: 3)
        ctx.line(s.point(c, 0), s.point(c, y), TrigPalette.ghost.opacity(0.45), width: 1.2, dash: [3, 3])
        ctx.line(s.point(0, y), s.point(c, y), TrigPalette.ghost.opacity(0.45), width: 1.2, dash: [3, 3])

        drawTangent(&ctx, s)

        ctx.line(s.point(0, 0), s.point(c, y), TrigPalette.radius, width: 2)
        ctx.dot(s.point(c, y), TrigPalette.radius, radius: 7)

        let cp = s.point(c / 2, 0), sp = s.point(0, y / 2)
        ctx.label("cos θ", at: CGPoint(x: cp.x, y: cp.y + 13), size: 11, TrigPalette.cosColor, bold: true)
        ctx.label("sin θ", at: CGPoint(x: sp.x - 22, y: sp.y), size: 11, TrigPalette.sinColor, bold: true)
    }

    private func drawTangent(_ ctx: inout GraphicsContext, _ s: TrigSpace) {
        let e = s.halfExtent

        // Axe des tangentes : le support sur lequel tan θ se lit.
        ctx.line(s.point(1, -e), s.point(1, e), TrigPalette.tanColor.opacity(0.25), width: 1, dash: [4, 4])

        guard let t = tanT else { return }

        // Aucun clamp : on va jusqu'à la vraie valeur, le clip fait le reste.
        ctx.line(s.point(cosT, sinT), s.point(1, t),
                 TrigPalette.radius.opacity(0.4), width: 1.2, dash: [2, 3])
        ctx.line(s.point(1, 0), s.point(1, t), TrigPalette.tanColor, width: 3)

        // Étiquette au bout du segment tant qu'il est visible, sinon plaquée
        // en haut du cadre pour rester lisible.
        let inside = abs(t) < e * 0.88
        let anchor = inside ? s.point(1, t) : s.point(1, (t < 0 ? -1 : 1) * e * 0.88)
        ctx.label("tan θ", at: CGPoint(x: anchor.x + 28, y: anchor.y),
                  size: 11, TrigPalette.tanColor, bold: true)
    }

    // MARK: Contrôles et lectures

    @ViewBuilder
    private var panel: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Cercle unité").font(.headline)
            Text("Fais glisser le point — il s'aimante aux angles remarquables.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        TrigSlider(title: "θ", value: $theta, range: 0...(2 * .pi),
                   tint: TrigPalette.radius, asMultipleOfPi: true)
            .padding(.horizontal, 8)

        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 16) {
                Text("cos θ = \(fmt(cosT))").foregroundStyle(TrigPalette.cosColor)
                Text("sin θ = \(fmt(sinT))").foregroundStyle(TrigPalette.sinColor)
            }
            Text(tanT.map { "tan θ = \(fmt($0))" } ?? "tan θ indéfinie")
                .foregroundStyle(TrigPalette.tanColor)
        }
        .font(.system(.footnote, design: .monospaced))
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func fmt(_ v: Double) -> String { String(format: "%.2f", v) }
}

#Preview {
    ScrollView { TrigoView() }
}
