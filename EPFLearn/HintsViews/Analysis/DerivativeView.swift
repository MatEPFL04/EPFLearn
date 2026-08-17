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
    case waveThenLine
    case sine
    case cosineDrift
    case absolute
    case quartic

    var id: Self { self }

    var displayName: String {
        switch self {
        case .waveThenLine: return "piecewise-defined"
        case .sine:         return "6 sin(x/2)"
        case .cosineDrift:  return "5 cos(x/2) + x/2"
        case .absolute:     return "|x|"
        case .quartic:      return "x⁴/500 − 3x²/10"
        }
    }

    fileprivate var function: MathFunction {
        switch self {
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

// MARK: - Derivative curve and rise/run

/// The Δx / Δy right angle under the secant: the two numbers whose ratio is
/// the difference quotient, drawn rather than only printed.
struct RiseRunTriangle: Shape {
    var x0: Double
    var x1: Double
    let f: @Sendable (Double) -> Double
    let scale: Double

    func path(in rect: CGRect) -> Path {
        let cs = MathCoordinateSpace(rect: rect, scale: scale)
        var path = Path()
        let a = cs.toScreen(x: x0, y: f(x0))
        let b = cs.toScreen(x: x1, y: f(x1))
        path.move(to: a)
        path.addLine(to: CGPoint(x: b.x, y: a.y))   // Δx, horizontal
        path.addLine(to: b)                         // Δy, vertical
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

        // Snapped first, so the plot, the tiles and the slider readouts all
        // describe the same two points.
        let pxStart = snappedPixel(xOffset, cs)
        let pxEnd   = snappedPixel(xOffsetEnd, cs)

        let xMathStart = cs.toMath(x: pxStart)
        let xMathEnd   = cs.toMath(x: pxEnd)
        let h          = xMathEnd - xMathStart

        let tangentSlope = fn.derivative(xMathStart)
        let secantSlope: Double? = abs(h) < 0.001
            ? nil
            : (fn.f(xMathEnd) - fn.f(xMathStart)) / h

        VStack(spacing: 8) {
            VizHeader("Derivative", subtitle: "Secant against tangent at a point.")

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

                RiseRunTriangle(x0: xMathStart, x1: xMathEnd, f: fn.f, scale: scale)
                    .stroke(Color.orange.opacity(0.95),
                            style: StrokeStyle(lineWidth: 2.5, lineCap: .round,
                                               dash: [1, 5]))

                SlopeView(xOffset: pxStart, xOffsetEnd: pxEnd, f: fn.f, scale: scale)
                    .stroke(Color.orange, lineWidth: 1.5)

                TangentSegment(
                    x0: xMathStart,
                    y0: fn.f(xMathStart),
                    slope: tangentSlope,
                    halfLength: graphSize * 0.22,
                    scale: scale
                )
                .stroke(Color.red, lineWidth: 1.5)

                endpointDot(.red)
                    .position(cs.toScreen(x: xMathStart, y: fn.f(xMathStart)))

                endpointDot(.orange)
                    .position(cs.toScreen(x: xMathEnd, y: fn.f(xMathEnd)))

            }
            .frame(width: graphSize, height: graphSize)
            .clipped()

            slopeTiles(dx: h,
                       dy: fn.f(xMathEnd) - fn.f(xMathStart),
                       secant: secantSlope,
                       tangent: tangentSlope)

            Picker("Function", selection: $preset) {
                ForEach(DerivativePreset.allCases) { option in
                    Text(option.displayName).tag(option)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(width: graphSize)

            // Full width, one per row: side by side, the label and the value
            // squeezed the track down to a few points and the thumb could not
            // be grabbed at all.
            VStack(spacing: 5) {
                slider(title: "tangent x", value: $xOffset)
                slider(title: "secant x", value: $xOffsetEnd)
            }
            .frame(width: graphSize)
        }
        .padding()
        .adaptivePlot($graphSize, max: 260)
        .onChange(of: graphSize) { old, new in
            // The offsets are stored in pixels, so they need rescaling to keep
            // both points at the same mathematical x.
            guard old > 0 else { return }
            xOffset *= new / old
            xOffsetEnd *= new / old
        }
    }

    // MARK: - Pieces

    /// Two tiles, each drawing its own slope as a short segment next to the
    /// number. The plot alone cannot separate the secant from the tangent on a
    /// straight line - side by side, "same tilt, same number" is the point.
    private func slopeTiles(dx: Double, dy: Double,
                            secant: Double?, tangent: Double) -> some View {
        let agree = secant.map { abs($0 - tangent) < 0.005 } ?? false
        return VStack(spacing: 4) {
            HStack(spacing: 8) {
                slopeTile(title: "SECANT  Δy/Δx",
                          detail: "\(formatted(dy)) / \(formatted(dx))",
                          slope: secant,
                          color: .orange)
                slopeTile(title: "TANGENT  f′(x₀)",
                          detail: agree ? "same as the secant" : "at the red point",
                          slope: tangent,
                          color: agree ? .green : .red)
            }
        }
        .frame(width: graphSize)
    }

    private func slopeTile(title: String, detail: String,
                           slope: Double?, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 8.5, weight: .bold))
                .tracking(0.5)
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            HStack(spacing: 6) {
                // A 26pt-wide segment at exactly this slope, clamped so a steep
                // one still fits the tile.
                Canvas { ctx, size in
                    let m = min(max(slope ?? 0, -4), 4)
                    let halfW = size.width / 2
                    let dy = CGFloat(m) * halfW
                    let clamped = min(max(dy, -size.height / 2 + 2), size.height / 2 - 2)
                    var p = Path()
                    p.move(to: CGPoint(x: 0, y: size.height / 2 + clamped))
                    p.addLine(to: CGPoint(x: size.width, y: size.height / 2 - clamped))
                    ctx.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                }
                .frame(width: 26, height: 18)

                Text(slope.map(formatted) ?? "—")
                    .font(.system(.footnote, design: .monospaced).weight(.bold))
                    .foregroundStyle(color)
                    .contentTransition(.numericText())
            }

            Text(detail)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.10)))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(color.opacity(0.28)))
    }

    private func slider(title: String, value: Binding<Double>) -> some View {
        // The offsets are pixel positions, so the readout converts back to x -
        // through the same snap the plot uses, or the number and the dot disagree.
        let cs = MathCoordinateSpace(size: graphSize, scale: scale)
        return VizSlider(label: title, value: value, range: 0...max(graphSize, 1),
                         accent: .orange,
                         valueText: formatted(cs.toMath(x: snappedPixel(value.wrappedValue, cs))))
    }

    /// Aimantation. Both sliders move in pixels, so x lands on 1.97 rather than
    /// 2 and the one comparison this view exists for - secant slope against
    /// tangent slope - never comes out on a round number. Tenths match the
    /// step every other slider in Analysis uses, and still read cleanly in the
    /// Δx, Δy and slope tiles.
    private func snappedPixel(_ px: Double, _ cs: MathCoordinateSpace) -> Double {
        let x = cs.toMath(x: CGFloat(px))
        return Double(cs.toScreen(x: (x * 10).rounded() / 10))
    }

    /// A flat 8pt disc on top of the curve, the grid and the dashed triangle was
    /// hard to pick out at all; a ring in the background colour lifts each end
    /// of the secant off whatever it happens to sit on.
    private func endpointDot(_ color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 11, height: 11)
            .overlay(Circle().strokeBorder(Color(.systemBackground).opacity(0.5), lineWidth: 1))
            .shadow(color: .black.opacity(0.3), radius: 1.5, y: 0.5)
    }

    private func formatted(_ value: Double) -> String {
        String(format: "%.2f", value)
    }
}

#Preview {
    DerivateView()
}
