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
            
            Text("Derivative").font(.headline)


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
            .labelsHidden()
            .frame(width: graphSize)

            compactReadout(
                x0: xMathStart,
                h: h,
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

    /// Compact readout showing just the essential slopes
    private func compactReadout(
        x0: Double,
        h: Double,
        secant: Double?,
        tangent: Double
    ) -> some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("h = \(formatted(abs(h)))")
                    .foregroundStyle(.secondary)
                Text("Secant: \(secant.map(formatted) ?? "—")")
                    .foregroundStyle(.orange)
            }
            
            Spacer()
            
            Text("f'(x) = \(formatted(tangent))")
                .foregroundStyle(.red)
        }
        .font(.system(.footnote, design: .monospaced))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(width: graphSize)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
