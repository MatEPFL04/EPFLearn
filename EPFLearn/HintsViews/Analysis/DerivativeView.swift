//
//  DerivativeView.swift
//  LearnViz
//

import SwiftUI

// MARK: - Function catalogue

fileprivate struct MathFunction {
    let name: String
    let f: @Sendable (Double) -> Double
    /// Antiderivative, handed to FunctionDrawing as integrF.
    let antiderivative: @Sendable (Double) -> Double
    let derivative: @Sendable (Double) -> Double
}

/// Named presets so a question can target one function without hardcoding an
/// array index. Adding a case never shifts the others.
enum DerivativePreset: String, CaseIterable, Identifiable {
    case affine
    case waveThenLine
    case sine
    case cosineDrift
    case absolute
    case quartic

    var id: Self { self }

    var displayName: String {
        switch self {
        case .affine:       return "x/2 + 3"
        case .waveThenLine: return "piecewise-defined"
        case .sine:         return "6 sin(x/2)"
        case .cosineDrift:  return "5 cos(x/2) + x/2"
        case .absolute:     return "|x|"
        case .quartic:      return "x⁴/500 − 3x²/10"
        }
    }

    fileprivate var function: MathFunction {
        switch self {
        case .affine:
            // Secant and tangent coincide for every h. The reference case.
            return MathFunction(
                name: displayName,
                f: { x in x / 2 + 3 },
                antiderivative: { x in x * x / 4 + 3 * x },
                derivative: { _ in 0.5 }
            )

        case .waveThenLine:
            // Oscillates on the negatives, straight line on the positives.
            // Value and slope are matched at x = 0 (3 × 1/2 = 1.5), so the
            // junction is invisible and the only thing that changes across it
            // is whether the quotient still depends on h.
            return MathFunction(
                name: displayName,
                f: { x in
                    x < 0 ? -9 + 3 * sin(x / 2)
                          : -9 + 1.5 * x
                },
                antiderivative: { x in
                    x < 0 ? -9 * x - 6 * cos(x / 2)
                          : -9 * x + 0.75 * x * x - 6
                },
                derivative: { x in
                    x < 0 ? 1.5 * cos(x / 2)
                          : 1.5
                }
            )

        case .sine:
            // Odd and periodic, with a period wide enough to read on screen.
            return MathFunction(
                name: displayName,
                f: { x in 6 * sin(x / 2) },
                antiderivative: { x in -12 * cos(x / 2) },
                derivative: { x in 3 * cos(x / 2) }
            )

        case .cosineDrift:
            return MathFunction(
                name: displayName,
                f: { x in 5 * cos(x / 2) + x / 2 },
                antiderivative: { x in 10 * sin(x / 2) + x * x / 4 },
                derivative: { x in -2.5 * sin(x / 2) + 0.5 }
            )

        case .absolute:
            return MathFunction(
                name: displayName,
                f: { x in abs(x) },
                antiderivative: { x in x >= 0 ? x * x / 2 : -x * x / 2 },
                derivative: { x in x >= 0 ? 1.0 : -1.0 }
            )

        case .quartic:
            // Coefficients chosen so the two minima and the hump at 0 all fit
            // the visible window. A plain x⁴ − 2x² hugs the axis near 0 and
            // leaves the frame before the wells become visible.
            return MathFunction(
                name: displayName,
                f: { x in 0.002 * pow(x, 4) - 0.3 * x * x },
                antiderivative: { x in 0.0004 * pow(x, 5) - 0.1 * pow(x, 3) },
                derivative: { x in 0.008 * pow(x, 3) - 0.6 * x }
            )
        }
    }
}

// MARK: - Secant

struct SlopeView: Shape {
    var xOffset: Double
    var xOffsetEnd: Double
    let f: @Sendable (Double) -> Double
    let scale: Double

    func path(in rect: CGRect) -> Path {
        let cs = MathCoordinateSpace(rect: rect, scale: scale)
        var path = Path()
        let xMathStart = cs.toMath(x: rect.minX + xOffset)
        let xMathEnd   = cs.toMath(x: rect.minX + xOffsetEnd)
        path.move(to:    cs.toScreen(x: xMathStart, y: f(xMathStart)))
        path.addLine(to: cs.toScreen(x: xMathEnd,   y: f(xMathEnd)))
        return path
    }
}

/// The tangent drawn as a short segment centred on the point of tangency,
/// rather than a line spanning the plot. `halfLength` is in points and the
/// segment keeps that length whatever the slope, so a steep tangent does not
/// visually dwarf a flat one.
struct TangentSegment: Shape {
    var x0: Double
    var y0: Double
    var slope: Double
    var halfLength: CGFloat
    let scale: Double

    func path(in rect: CGRect) -> Path {
        let cs = MathCoordinateSpace(rect: rect, scale: scale)
        let dx = Double(halfLength) / (scale * (1 + slope * slope).squareRoot())
        var path = Path()
        path.move(to:    cs.toScreen(x: x0 - dx, y: y0 - slope * dx))
        path.addLine(to: cs.toScreen(x: x0 + dx, y: y0 + slope * dx))
        return path
    }
}

// MARK: - DerivateView

struct DerivateView: View {

    @State private var preset: DerivativePreset
    @State private var xOffset    = 100.0
    @State private var xOffsetEnd = 200.0
    @State private var graphSize: CGFloat = 300

    private let baseScale: Double = 10
    private var scale: Double { baseScale * Double(graphSize) / 300 }

    init(initial: DerivativePreset = .sine) {
        _preset = State(initialValue: initial)
    }

    var body: some View {
        let fn = preset.function
        let cs = MathCoordinateSpace(size: graphSize, scale: scale)

        let xMathStart = cs.toMath(x: xOffset)
        let xMathEnd   = cs.toMath(x: xOffsetEnd)
        let h          = xMathEnd - xMathStart

        let tangentSlope = fn.derivative(xMathStart)
        let secantSlope: Double? = abs(h) < 0.001
            ? nil
            : (fn.f(xMathEnd) - fn.f(xMathStart)) / h

        VStack(spacing: 14) {

            Text("Secant slope against the derivative")
                .font(.caption)
                .foregroundStyle(.secondary)

            ZStack {
                // One grid square is one unit of x, whatever the plot size.
                GridDrawing(step: scale)
                    .stroke(Color.blue.opacity(0.35), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal)
                    .stroke(Color.primary.opacity(0.7), lineWidth: 1.5)
                AxisDrawing(axis: .vertical)
                    .stroke(Color.primary.opacity(0.7), lineWidth: 1.5)

                FunctionDrawing(f: fn.f, integrF: fn.antiderivative, scale: scale)
                    .stroke(lineWidth: 1.5)

                SlopeView(xOffset: xOffset, xOffsetEnd: xOffsetEnd, f: fn.f, scale: scale)
                    .stroke(Color.orange, lineWidth: 1.5)

                TangentSegment(
                    x0: xMathStart,
                    y0: fn.f(xMathStart),
                    slope: tangentSlope,
                    halfLength: graphSize * 0.22,
                    scale: scale
                )
                .stroke(Color.red, lineWidth: 1.5)

                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .position(cs.toScreen(x: xMathStart, y: fn.f(xMathStart)))

                Circle()
                    .fill(Color.orange)
                    .frame(width: 8, height: 8)
                    .position(cs.toScreen(x: xMathEnd, y: fn.f(xMathEnd)))
            }
            .frame(width: graphSize, height: graphSize)
            .clipped()

            legend

            Picker("Function", selection: $preset) {
                ForEach(DerivativePreset.allCases) { option in
                    Text(option.displayName).tag(option)
                }
            }
            .pickerStyle(.menu)
            .frame(width: graphSize)

            readout(
                x0: xMathStart,
                x1: xMathEnd,
                h: h,
                f: fn.f,
                secant: secantSlope,
                tangent: tangentSlope
            )

            slider(
                title: "Tangent point (x = \(formatted(xMathStart)))",
                value: $xOffset
            )
            slider(
                title: "Secant point (x = \(formatted(xMathEnd)))",
                value: $xOffsetEnd
            )
        }
        .padding()
        .adaptivePlot($graphSize)
        .onChange(of: graphSize) { old, new in
            // The offsets are stored in pixels, so they need rescaling to keep
            // both points at the same mathematical x.
            guard old > 0 else { return }
            xOffset *= new / old
            xOffsetEnd *= new / old
        }
    }

    // MARK: - Pieces

    private var legend: some View {
        HStack(spacing: 16) {
            legendItem(.red, "Tangent")
            legendItem(.orange, "Secant")
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
    }

    private func legendItem(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(label)
        }
    }

    /// Writes the quotient in the form that matches the side the secant point
    /// sits on: forward difference to the right, backward difference to the
    /// left. h is displayed as a positive step in both cases.
    ///
    /// The five lines are always rendered, including when h reaches 0. A
    /// branch that drops lines would change the panel height and make
    /// everything below it jump while the slider moves.
    private func readout(
        x0: Double,
        x1: Double,
        h: Double,
        f: (Double) -> Double,
        secant: Double?,
        tangent: Double
    ) -> some View {
        let step = abs(h)
        let fromRight = h >= 0
        let fx0 = f(x0)
        let fx1 = f(x1)
        let lead = fromRight ? fx1 : fx0
        let sub  = fromRight ? fx0 : fx1

        return VStack(alignment: .leading, spacing: 6) {
            Text(fromRight
                 ? "From the right, h = \(formatted(step))"
                 : "From the left,  h = \(formatted(step))")
                .foregroundStyle(.secondary)

            Text(fromRight
                 ? "(f(x+h) − f(x)) / h"
                 : "(f(x) − f(x−h)) / h")

            Text("= (\(difference(lead, sub))) / \(formatted(step))")

            Text("= \(secant.map(formatted) ?? "undefined (0 / 0)")")
                .foregroundStyle(.orange)

            Text("f'(x) = \(formatted(tangent))")
                .foregroundStyle(.red)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.75)
        .font(.system(.footnote, design: .monospaced))
        .padding()
        .frame(width: graphSize, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    /// "5.12 − 3.50", or "5.12 + 3.50" when the subtracted value is negative,
    /// to avoid printing a double minus.
    private func difference(_ lead: Double, _ sub: Double) -> String {
        sub < 0
            ? "\(formatted(lead)) + \(formatted(-sub))"
            : "\(formatted(lead)) − \(formatted(sub))"
    }

    private func slider(title: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Slider(value: value, in: 0...graphSize)
        }
        .frame(width: graphSize)
    }

    private func formatted(_ value: Double) -> String {
        String(format: "%.2f", value)
    }
}

#Preview {
    DerivateView()
        .preferredColorScheme(.dark)
}
