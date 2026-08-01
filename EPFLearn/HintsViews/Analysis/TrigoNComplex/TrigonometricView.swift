////
//  TrigonometricView.swift
//  EPFLearn
//
//  Unit circle — cos, sin, tan. Standalone view, no complex mode.
//
//  Fixed framing. The tangent is drawn to its true value and exits the
//  frame: it's the Canvas clip that cuts it, not a ceiling. The segment
//  continues working offscreen as θ approaches π/2.
//

import SwiftUI

struct TrigoView: View {

    @State private var theta: Double = .pi / 4

    /// Unit circle + labels (1.17) + tangent axis at x = 1.
    private let fitRadius: Double = 1.34

    private var cosT: Double { cos(theta) }
    private var sinT: Double { sin(theta) }

    /// Low threshold: beyond this, the Path coordinates become absurd without
    /// adding anything — the line is already off-screen.
    private var tanT: Double? { abs(cosT) < 0.02 ? nil : sinT / cosT }

    var body: some View {
        VStack(spacing: 14) {
            plot.frame(maxWidth: 520, maxHeight: 520)
                .aspectRatio(1, contentMode: .fit)
            panel
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: Drawing

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

        // Tangent axis: the support on which tan θ is read.
        ctx.line(s.point(1, -e), s.point(1, e), TrigPalette.tanColor.opacity(0.25), width: 1, dash: [4, 4])

        guard let t = tanT else { return }

        // No clamping: we go to the true value, the clip does the rest.
        ctx.line(s.point(cosT, sinT), s.point(1, t),
                 TrigPalette.radius.opacity(0.4), width: 1.2, dash: [2, 3])
        ctx.line(s.point(1, 0), s.point(1, t), TrigPalette.tanColor, width: 3)

        // Label at the end of the segment while visible, otherwise pinned
        // to the top of the frame to stay readable.
        let inside = abs(t) < e * 0.88
        let anchor = inside ? s.point(1, t) : s.point(1, (t < 0 ? -1 : 1) * e * 0.88)
        ctx.label("tan θ", at: CGPoint(x: anchor.x + 28, y: anchor.y),
                  size: 11, TrigPalette.tanColor, bold: true)
    }

    // MARK: Controls and readout

    @ViewBuilder
    private var panel: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Unit circle").font(.headline)
            Text("Drag the point — it snaps to notable angles.")
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
            Text(tanT.map { "tan θ = \(fmt($0))" } ?? "tan θ undefined")
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
