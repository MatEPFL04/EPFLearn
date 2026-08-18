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

    /// Set in challenge mode so the run can grade what the student builds.
    /// Left nil everywhere else, which keeps this a plain hint view.
    var onReading: ((ChallengeReading) -> Void)? = nil

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

    private var reading: ComplexReading {
        ComplexReading(z1re: z1.re, z1im: z1.im,
                       z2re: z2.re, z2im: z2.im,
                       resultRe: result.re, resultIm: result.im,
                       isProduct: operation == .multiply)
    }

    var body: some View {
        VStack(spacing: 7) {
            plot.frame(maxWidth: 520, maxHeight: 520)
                .aspectRatio(1, contentMode: .fit)
            panel
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .onChange(of: reading, initial: true) { _, new in
            onReading?(.complexPlane(new))
        }
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

        // Pushed out along the vector rather than a fixed up-and-right nudge:
        // that offset dropped z₂'s label straight onto z₁'s whenever the two
        // pointed the same way, which is exactly the case worth reading. The
        // value travels with the name so the figure states what it is.
        let dx = tip.x - s.center.x, dy = tip.y - s.center.y
        let len = max(hypot(dx, dy), 1)
        let anchor = CGPoint(x: tip.x + dx / len * 26, y: tip.y + dy / len * 26)
        ctx.chip("\(name) = \(compact(z))", at: anchor, size: 9.5, color,
                 within: CGSize(width: s.side, height: s.side))
    }

    /// One decimal, and no "+ 0.0i" tail on a real: the plate has to stay
    /// narrow enough that it never buries the figure it is labelling.
    private func compact(_ z: Complex) -> String {
        let re = (z.re * 10).rounded() / 10
        let im = (z.im * 10).rounded() / 10
        if abs(im) < 0.05 { return String(format: "%.1f", re) }
        if abs(re) < 0.05 { return String(format: "%.1fi", im) }
        return String(format: "%.1f", re) + (im < 0 ? "−" : "+") + String(format: "%.1fi", abs(im))
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

        // Three cards rather than three shrink-to-fit lines: the old readout
        // squeezed cartesian and polar onto one row and scaled it down to
        // ~8pt, so the numbers the whole view is about were the hardest thing
        // on screen to read.
        VStack(spacing: 6) {
            readout("z₁", z1, TrigPalette.radius)
            readout("z₂", z2, TrigPalette.z2)
            readout("z₁ \(operation.rawValue) z₂", result, TrigPalette.result, emphasised: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func readout(_ name: String, _ z: Complex, _ color: Color,
                         emphasised: Bool = false) -> some View {
        HStack(spacing: 9) {
            Text(name)
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(color, in: RoundedRectangle(cornerRadius: 5))

            VStack(alignment: .leading, spacing: 1) {
                Text(str(z))
                    .font(.system(size: 13, weight: emphasised ? .heavy : .semibold,
                                  design: .monospaced))
                Text("|z| = \(fmt(z.modulus))   ·   arg = \(fmt(z.argument / .pi))π")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.8)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(color.opacity(emphasised ? 0.15 : 0.07),
                    in: RoundedRectangle(cornerRadius: 9))
    }

    private func fmt(_ v: Double) -> String { String(format: "%.2f", v) }

    private func str(_ z: Complex) -> String {
        "\(fmt(z.re)) \(z.im < 0 ? "−" : "+") \(fmt(abs(z.im)))i"
    }
}

#Preview {
    ScrollView { ComplexPlaneView() }
}
