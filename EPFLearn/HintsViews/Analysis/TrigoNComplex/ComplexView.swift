//
//  ComplexPlaneView.swift
//  EPFLearn
//
//  Plan complexe - z₁, z₂ et leur somme ou produit. Vue autonome.
//

import SwiftUI

struct Complex: Equatable {
    var re: Double, im: Double

    init(re: Double, im: Double) { self.re = re; self.im = im }
    init(modulus: Double, argument: Double) {
        re = modulus * cos(argument); im = modulus * sin(argument)
    }

    var modulus: Double { (re * re + im * im).squareRoot() }
    var argument: Double { TrigAngles.normalize(atan2(im, re)) }

    static func + (a: Self, b: Self) -> Self { .init(re: a.re + b.re, im: a.im + b.im) }

    /// Le produit multiplie les modules et additionne les arguments.
    static func * (a: Self, b: Self) -> Self {
        .init(re: a.re * b.re - a.im * b.im, im: a.re * b.im + a.im * b.re)
    }
}

enum ComplexOp: String, CaseIterable, Identifiable {
    case add = "+", multiply = "•"
    var id: Self { self }
}

struct ComplexPlaneView: View {

    @State private var r1: Double = 1
    @State private var theta1: Double = .pi / 4
    @State private var r2: Double = 0.7
    @State private var theta2: Double = .pi / 3
    @State private var operation: ComplexOp = .multiply

    @State private var grabbedZ2 = false
    @State private var dragging = false
    /// Finger-to-tip offset in math units, held for the length of one drag.
    @State private var grabOffset: (dx: Double, dy: Double) = (0, 0)
    /// Échelle gelée pendant un drag, pour ne pas zoomer sous le doigt.
    @State private var frozenFit: Double?

    private var z1: Complex { .init(modulus: r1, argument: theta1) }
    private var z2: Complex { .init(modulus: r2, argument: theta2) }
    private var result: Complex { operation == .add ? z1 + z2 : z1 * z2 }

    private var fitRadius: Double {
        frozenFit ?? max(1.34, max(r1, r2, result.modulus) * 1.15)
    }

    var body: some View {
        VStack(spacing: 9) {
            plot.frame(maxWidth: 520, maxHeight: 520)
                .aspectRatio(1, contentMode: .fit)
            panel
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: Tracé

    private var plot: some View {
        TrigPlotCanvas(
            fitRadius: fitRadius,
            onDragBegan: { location, space in
                frozenFit = fitRadius
                dragging = true
                grabbedZ2 = nearerToZ2(location, space)
                let (fx, fy) = space.math(location)
                let held = grabbedZ2 ? z2 : z1
                grabOffset = (held.re - fx, held.im - fy)
            },
            onDragChanged: { location, space in
                let (fx, fy) = space.math(location)
                let x = fx + grabOffset.dx, y = fy + grabOffset.dy
                let rawAngle = atan2(y, x)
                
                // Aimantation intelligente : si on est proche du cercle unité (r entre 0.85 et 1.15),
                // on force le module à 1.0 pile pour faciliter le placement tactile.
                let rawR = (x * x + y * y).squareRoot()
                let targetR: Double
                if abs(rawR - 1.0) < 0.15 {
                    targetR = 1.0
                } else {
                    targetR = rawR
                }

                // Aimantation de l'angle sur les angles remarquables
                let angle = TrigAngles.snap(rawAngle, tolerance: 0.12)

                if grabbedZ2 {
                    theta2 = angle
                    r2 = targetR
                } else {
                    theta1 = angle
                    r1 = targetR
                }
            },
            onDragEnded: {
                dragging = false
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { frozenFit = nil }
            },
            content: { ctx, s in draw(&ctx, s) }
        )
    }

    private func draw(_ ctx: inout GraphicsContext, _ s: TrigSpace) {
        ctx.drawUnitCircle(s)
        ctx.drawArc(s, to: theta1)

        // Parallélogramme de la somme.
        if operation == .add {
            let tip = point(s, result)
            ctx.line(point(s, z1), tip, TrigPalette.ghost.opacity(0.45), width: 1)
            ctx.line(point(s, z2), tip, TrigPalette.ghost.opacity(0.45), width: 1)
        }

        vector(&ctx, s, z1, TrigPalette.radius, "z₁", width: 2.4,
               held: dragging && !grabbedZ2)
        vector(&ctx, s, z2, TrigPalette.z2, "z₂", width: 2.4,
               held: dragging && grabbedZ2)
        vector(&ctx, s, result, TrigPalette.result, "z₁ \(operation.rawValue) z₂", width: 3)
    }

    private func vector(_ ctx: inout GraphicsContext, _ s: TrigSpace,
                        _ z: Complex, _ color: Color, _ name: String,
                        width: CGFloat, held: Bool = false) {
        let tip = point(s, z)
        ctx.arrow(s, to: tip, color, width: width)
        if held {
            ctx.dot(tip, color.opacity(0.28), radius: width * 4.4)
        }
        ctx.dot(tip, color, radius: width * (held ? 2.8 : 2.2))
        ctx.label(name, at: CGPoint(x: tip.x + 22, y: tip.y - 12), size: 11, color, bold: true)
    }

    private func point(_ s: TrigSpace, _ z: Complex) -> CGPoint { s.point(z.re, z.im) }

    // MARK: Interaction

    private func nearerToZ2(_ p: CGPoint, _ s: TrigSpace) -> Bool {
        let a = point(s, z1), b = point(s, z2)
        return hypot(p.x - b.x, p.y - b.y) < hypot(p.x - a.x, p.y - a.y)
    }

    // MARK: Contrôles et lectures

    @ViewBuilder
    private var panel: some View {
        VStack(alignment: .leading, spacing: 2) {
            VizHeader("Complex Plane", subtitle: "Drag z₁ and z₂; read modulus and argument.")
            Text("Drag z₁ or z₂, the result follows.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        Picker("Operation", selection: $operation) {
            ForEach(ComplexOp.allCases) { Text($0.rawValue).tag($0) }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .padding(.horizontal, 8)

        VStack(alignment: .leading, spacing: 5) {
            Text("z₁ = \(exponentialStr(r: r1, theta: theta1)) = \(str(z1))")
                .foregroundStyle(TrigPalette.radius)
            Text("z₂ = \(exponentialStr(r: r2, theta: theta2)) = \(str(z2))")
                .foregroundStyle(TrigPalette.z2)
            Text("z₁ \(operation.rawValue) z₂ = \(exponentialStr(r: result.modulus, theta: result.argument)) = \(str(result))")
                .foregroundStyle(TrigPalette.result).fontWeight(.semibold)
        }
        .font(.system(.footnote, design: .monospaced))
        .lineLimit(1)
        .minimumScaleFactor(0.65)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func fmt(_ v: Double) -> String { String(format: "%.2f", v) }
    
    private func exponentialStr(r: Double, theta: Double) -> String {
        let coeff = String(format: "%.2f", theta / .pi)
        return "\(fmt(r))eⁱ⁽\(coeff)π⁾"
    }

    private func str(_ z: Complex) -> String {
        "\(fmt(z.re)) \(z.im < 0 ? "−" : "+") \(fmt(abs(z.im)))i"
    }
}

#Preview {
    ScrollView { ComplexPlaneView() }
}
