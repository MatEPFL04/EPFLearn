////
//  ComplexPlaneView.swift
//  EPFLearn
//
//  Plan complexe — z₁, z₂ et leur somme ou produit. Vue autonome.
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

    /// Le produit multiplie les modules et additionne les arguments — c'est
    /// exactement ce que la vue donne à voir.
    static func * (a: Self, b: Self) -> Self {
        .init(re: a.re * b.re - a.im * b.im, im: a.re * b.im + a.im * b.re)
    }
}

enum ComplexOp: String, CaseIterable, Identifiable {
    case add = "+", multiply = "×"
    var id: Self { self }
}

struct ComplexPlaneView: View {

    @State private var r1: Double = 1
    @State private var theta1: Double = .pi / 4
    @State private var r2: Double = 0.7
    @State private var theta2: Double = .pi / 3
    @State private var operation: ComplexOp = .multiply

    @State private var grabbedZ2 = false
    /// Échelle gelée pendant un drag, pour ne pas zoomer sous le doigt.
    @State private var frozenFit: Double?

    private var z1: Complex { .init(modulus: r1, argument: theta1) }
    private var z2: Complex { .init(modulus: r2, argument: theta2) }
    private var result: Complex { operation == .add ? z1 + z2 : z1 * z2 }

    /// r₁ = r₂ = 2 en multiplication donne un module de 4 : avec un cadrage
    /// fixe, le vecteur résultat sortait purement et simplement de l'écran.
    private var fitRadius: Double {
        frozenFit ?? max(1.34, max(r1, r2, result.modulus) * 1.15)
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 24) {
                plot.frame(width: 400, height: 400)
                VStack(alignment: .leading, spacing: 16) { panel; Spacer(minLength: 0) }
                    .frame(width: 320)
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
            onDragBegan: { location, space in
                frozenFit = fitRadius
                grabbedZ2 = nearerToZ2(location, space)
            },
            onDragChanged: { location, space in
                let (x, y) = space.math(location)
                let angle = TrigAngles.snap(atan2(y, x))
                let r = snapRadius(min(2, (x * x + y * y).squareRoot()))
                if grabbedZ2 { theta2 = angle; r2 = r } else { theta1 = angle; r1 = r }
            },
            onDragEnded: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { frozenFit = nil }
            },
            content: { ctx, s in draw(&ctx, s) }
        )
    }

    private func draw(_ ctx: inout GraphicsContext, _ s: TrigSpace) {
        ctx.drawUnitCircle(s)
        ctx.drawArc(s, to: theta1)

        // Cercle du module de z₁ quand il diffère de 1.
        if abs(r1 - 1) > 0.02 {
            ctx.ring(s, radius: r1, TrigPalette.radius.opacity(0.3), width: 1, dash: [3, 3])
        }

        // Parallélogramme de la somme.
        if operation == .add {
            let tip = point(s, result)
            ctx.line(point(s, z1), tip, TrigPalette.ghost.opacity(0.45), width: 1, dash: [3, 3])
            ctx.line(point(s, z2), tip, TrigPalette.ghost.opacity(0.45), width: 1, dash: [3, 3])
        }

        vector(&ctx, s, z1, TrigPalette.radius, "z₁", width: 2.4)
        vector(&ctx, s, z2, TrigPalette.z2, "z₂", width: 2.4)
        vector(&ctx, s, result, TrigPalette.result, "z₁ \(operation.rawValue) z₂", width: 3)
    }

    private func vector(_ ctx: inout GraphicsContext, _ s: TrigSpace,
                        _ z: Complex, _ color: Color, _ name: String, width: CGFloat) {
        let tip = point(s, z)
        ctx.arrow(s, to: tip, color, width: width)
        ctx.dot(tip, color, radius: width * 2.2)
        ctx.label(name, at: CGPoint(x: tip.x + 22, y: tip.y - 12), size: 11, color, bold: true)
    }

    private func point(_ s: TrigSpace, _ z: Complex) -> CGPoint { s.point(z.re, z.im) }

    // MARK: Interaction

    private func nearerToZ2(_ p: CGPoint, _ s: TrigSpace) -> Bool {
        let a = point(s, z1), b = point(s, z2)
        return hypot(p.x - b.x, p.y - b.y) < hypot(p.x - a.x, p.y - a.y)
    }

    private func snapRadius(_ r: Double) -> Double {
        [0.5, 1, 1.5, 2].first { abs($0 - r) < 0.045 } ?? r
    }

    // MARK: Contrôles et lectures

    @ViewBuilder
    private var panel: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Plan complexe").font(.headline)
            Text("Fais glisser z₁ ou z₂ ; le résultat suit.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        VStack(spacing: 8) {
            TrigSlider(title: "θ₁", value: $theta1, range: 0...(2 * .pi),
                       tint: TrigPalette.radius, asMultipleOfPi: true)
            TrigSlider(title: "r₁", value: $r1, range: 0...2, tint: TrigPalette.radius)
            TrigSlider(title: "θ₂", value: $theta2, range: 0...(2 * .pi),
                       tint: TrigPalette.z2, asMultipleOfPi: true)
            TrigSlider(title: "r₂", value: $r2, range: 0...2, tint: TrigPalette.z2)

            Picker("Opération", selection: $operation) {
                ForEach(ComplexOp.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.top, 2)
        }
        .padding(.horizontal, 8)

        VStack(alignment: .leading, spacing: 5) {
            Text("z₁ = \(fmt(r1))∠\(piCoeff(theta1)) = \(str(z1))")
                .foregroundStyle(TrigPalette.radius)
            Text("z₂ = \(fmt(r2))∠\(piCoeff(theta2)) = \(str(z2))")
                .foregroundStyle(TrigPalette.z2)
            Text("z₁ \(operation.rawValue) z₂ = \(fmt(result.modulus))∠\(piCoeff(result.argument)) = \(str(result))")
                .foregroundStyle(TrigPalette.result).fontWeight(.semibold)
        }
        .font(.system(.footnote, design: .monospaced))
        .lineLimit(1)
        .minimumScaleFactor(0.65)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func fmt(_ v: Double) -> String { String(format: "%.2f", v) }
    private func piCoeff(_ a: Double) -> String { String(format: "%.2fπ", a / .pi) }
    /// Évite les « + −1.01i ».
    private func str(_ z: Complex) -> String {
        "\(fmt(z.re)) \(z.im < 0 ? "−" : "+") \(fmt(abs(z.im)))i"
    }
}

#Preview {
    ScrollView { ComplexPlaneView() }
}
