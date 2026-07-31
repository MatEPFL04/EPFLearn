////
//  FunctionView.swift
//  EPFLearn
//
//  Created by Mat on 05.04.2026.
//

import SwiftUI

struct AxisDrawing: Shape {

    enum Axis { case horizontal, vertical }

    let axis: Axis
    func path(in rect: CGRect) -> Path {
        var path = Path()
        switch axis {
        case .horizontal:
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        case .vertical:
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        }
        return path
    }
}

struct GridDrawing: Shape {
    var step: CGFloat = 1

    func path(in rect: CGRect) -> Path {
        var path = Path()
        stride(from: rect.minX, through: rect.maxX, by: step).forEach { x in
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
        }
        stride(from: rect.minY, through: rect.maxY, by: step).forEach { y in
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
        }
        return path
    }
}


struct FunctionDrawing: Shape {

    let f: @Sendable (Double) -> Double
    let integrF: @Sendable (Double) -> Double
    let scale: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cs = MathCoordinateSpace(rect: rect, scale: scale)
        for x in stride(from: rect.minX, to: rect.maxX, by: 0.01) {
            let point = cs.toScreen(x: cs.toMath(x: x), y: f(cs.toMath(x: x)))
            if x == rect.minX {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        return path
    }

    /// Returns the exact integral value over the visible x range
    func integralValue(in rect: CGRect) -> Double {
        let cs = MathCoordinateSpace(rect: rect, scale: scale)
        let xStart = cs.toMath(x: rect.minX)
        let xEnd   = cs.toMath(x: rect.maxX)
        return integrF(xEnd) - integrF(xStart)
    }

    static func make(_ type: MathFunctionType, scale: Double) -> FunctionDrawing {
        switch type {
        case .affine:
            return FunctionDrawing(
                f:      { x in 2 * x + 5 },
                integrF: { x in pow(x, 2) + 5 * x },
                scale: scale
            )
        case .cubic:
            return FunctionDrawing(
                f:      { x in 0.01 * pow(x, 3) },
                integrF: { x in 0.01 * pow(x, 4) / 4 },
                scale: scale
            )
        case .sine:
            return FunctionDrawing(
                f:      { x in  10 * sin(0.2 * x) },
                integrF: { x in -50 * cos(0.2 * x) },
                scale: scale
            )
        case .cosine:
            return FunctionDrawing(
                f:      { x in 10 * cos(0.2 * x) },
                integrF: { x in  50 * sin(0.2 * x) },
                scale: scale
            )

        case .dirichlet:
            let period = 0.01
            return FunctionDrawing(
                f: { x in
                    Int(floor(x / period)) % 2 == 0 ? 1.0 : 0.0
                },
                integrF: { _ in .nan },
                scale: scale
            )
        case .constant:
            return FunctionDrawing(
                f:      { _ in 5 },
                integrF: { x in 5 * x },
                scale: scale
            )
        }
    }
}

enum MathFunctionType: String, CaseIterable {
    case constant  = "f(x) = 5"
    case affine    = "f(x) = 2x + 5"
    case cubic     = "f(x) = x³"
    case sine      = "f(x) = sin(x)"
    case cosine    = "f(x) = cos(x)"
    case dirichlet = "f(x) = 1 if x ∈ ℚ, 0 otherwise"
}

//
//  DarbouxView.swift
//  LearnViz
//
//  Darboux sums. The lower sum is filled, and the band between the lower and
//  upper staircases is filled on top of it: that band is the whole subject.
//  Refining thins it out, except on the Dirichlet function where it never
//  moves at all.
//

//


import SwiftUI

// MARK: - Functions

private struct DarbouxFunction {
    let f: @Sendable (Double) -> Double
    /// nil when f is not Riemann integrable, which the readout reports.
    let antiderivative: (@Sendable (Double) -> Double)?
    /// Closed form for the infimum and supremum on a slice, when sampling
    /// would be wrong. Dirichlet needs it: no finite sample set can see that
    /// both values occur in every interval, however small.
    let exactExtrema: (@Sendable (Double, Double) -> (inf: Double, sup: Double))?
}

enum DarbouxPreset: String, CaseIterable, Identifiable {
    case constant
    case affine
    case cubic
    case sine
    case cosine
    case dirichlet

    var id: Self { self }

    var displayName: String {
        switch self {
        case .constant:  return "f(x) = 5"
        case .affine:    return "f(x) = x/2 + 3"
        case .cubic:     return "f(x) = x³/500"
        case .sine:      return "f(x) = 10 sin(x/5)"
        case .cosine:    return "f(x) = 10 cos(x/5)"
        case .dirichlet: return "f(x) = 1 on ℚ, 0 elsewhere"
        }
    }

    var isIntegrable: Bool { self != .dirichlet }

    fileprivate var function: DarbouxFunction {
        switch self {
        case .constant:
            return DarbouxFunction(f: { _ in 5 },
                                   antiderivative: { 5 * $0 },
                                   exactExtrema: nil)
        case .affine:
            return DarbouxFunction(f: { $0 / 2 + 3 },
                                   antiderivative: { $0 * $0 / 4 + 3 * $0 },
                                   exactExtrema: nil)
        case .cubic:
            return DarbouxFunction(f: { pow($0, 3) / 500 },
                                   antiderivative: { pow($0, 4) / 2000 },
                                   exactExtrema: nil)
        case .sine:
            return DarbouxFunction(f: { 10 * sin($0 / 5) },
                                   antiderivative: { -50 * cos($0 / 5) },
                                   exactExtrema: nil)
        case .cosine:
            return DarbouxFunction(f: { 10 * cos($0 / 5) },
                                   antiderivative: { 50 * sin($0 / 5) },
                                   exactExtrema: nil)
        case .dirichlet:
            return DarbouxFunction(
                // Drawn as a dense comb so the curve reads as "everywhere 0
                // and everywhere 1" instead of a blank line.
                f: { x in Int(floor(x / 0.05)) % 2 == 0 ? 1 : 0 },
                antiderivative: nil,
                exactExtrema: { _, _ in (inf: 0, sup: 1) }
            )
        }
    }
}

// MARK: - Slices

private struct Slice: Identifiable {
    let id: Int
    let xStart: Double
    let xEnd: Double
    let low: Double
    let high: Double
}

private func buildSlices(
    _ fn: DarbouxFunction,
    from a: Double,
    to b: Double,
    count: Int
) -> [Slice] {
    let dx = (b - a) / Double(count)
    // Fixed sample budget per slice. The old version stepped by 0.001 in maths
    // space, which meant tens of thousands of evaluations per slice at low
    // subdivision counts and made the slider stutter.
    let samples = 48

    return (0..<count).map { k in
        let x0 = a + Double(k) * dx
        let x1 = x0 + dx

        if let exact = fn.exactExtrema {
            let e = exact(x0, x1)
            return Slice(id: k, xStart: x0, xEnd: x1, low: e.inf, high: e.sup)
        }

        var lo = fn.f(x0)
        var hi = lo
        for i in 1...samples {
            let v = fn.f(x0 + dx * Double(i) / Double(samples))
            lo = min(lo, v)
            hi = max(hi, v)
        }
        return Slice(id: k, xStart: x0, xEnd: x1, low: lo, high: hi)
    }
}

// MARK: - Shapes

/// Bars from the axis up to a chosen height of each slice.
private struct StaircaseFill: Shape {
    let slices: [Slice]
    let level: (Slice) -> Double
    let scale: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cs = MathCoordinateSpace(rect: rect, scale: scale)
        for slice in slices {
            let left  = cs.toScreen(x: slice.xStart, y: 0).x
            let right = cs.toScreen(x: slice.xEnd,   y: 0).x
            let top   = cs.toScreen(x: 0, y: level(slice)).y
            path.addRect(CGRect(x: left, y: min(top, rect.midY),
                                width: right - left, height: abs(top - rect.midY)))
        }
        return path
    }
}

/// The band between the two staircases. This is the quantity that has to reach
/// zero for f to be Riemann integrable.
private struct GapFill: Shape {
    let slices: [Slice]
    let scale: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cs = MathCoordinateSpace(rect: rect, scale: scale)
        for slice in slices {
            let left  = cs.toScreen(x: slice.xStart, y: 0).x
            let right = cs.toScreen(x: slice.xEnd,   y: 0).x
            let yHigh = cs.toScreen(x: 0, y: slice.high).y
            let yLow  = cs.toScreen(x: 0, y: slice.low).y
            path.addRect(CGRect(x: left, y: yHigh,
                                width: right - left, height: yLow - yHigh))
        }
        return path
    }
}

/// Outline of one staircase, drawn over the fills so the steps stay crisp.
private struct StaircaseOutline: Shape {
    let slices: [Slice]
    let level: (Slice) -> Double
    let scale: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cs = MathCoordinateSpace(rect: rect, scale: scale)
        for slice in slices {
            let left  = cs.toScreen(x: slice.xStart, y: 0).x
            let right = cs.toScreen(x: slice.xEnd,   y: 0).x
            let top   = cs.toScreen(x: 0, y: level(slice)).y
            path.move(to: CGPoint(x: left, y: top))
            path.addLine(to: CGPoint(x: right, y: top))
        }
        return path
    }
}

/// Thin rules at each slice boundary. Without them a run of bars of similar
/// height reads as one blob and the subdivision becomes invisible.
private struct StaircaseSeparators: Shape {
    let slices: [Slice]
    let level: (Slice) -> Double
    let scale: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cs = MathCoordinateSpace(rect: rect, scale: scale)
        for slice in slices {
            let x = cs.toScreen(x: slice.xStart, y: 0).x
            let top = cs.toScreen(x: 0, y: level(slice)).y
            path.move(to: CGPoint(x: x, y: rect.midY))
            path.addLine(to: CGPoint(x: x, y: top))
        }
        return path
    }
}

/// Which staircase is on screen. Showing one at a time is the only way the
/// individual steps stay legible; the combined view is for comparing.
enum DarbouxMode: String, CaseIterable, Identifiable {
    case lower
    case upper
    case both

    var id: Self { self }

    var label: String {
        switch self {
        case .lower: return "S⁻"
        case .upper: return "S⁺"
        case .both:  return "both"
        }
    }
}

// MARK: - View

struct DarbouxView: View {

    @State private var preset: DarbouxPreset
    @State private var mode: DarbouxMode = .both
    @State private var rawSections: Double = 8
    @State private var graphSize: CGFloat = 300

    private let baseScale: Double = 10
    private var scale: Double { baseScale * Double(graphSize) / 300 }
    private var sections: Int { Int(rawSections.rounded()) }

    init(initial: DarbouxPreset = .sine) {
        _preset = State(initialValue: initial)
    }

    private var fn: DarbouxFunction { preset.function }

    private var bounds: (a: Double, b: Double) {
        let cs = MathCoordinateSpace(size: graphSize, scale: scale)
        return (cs.toMath(x: 0), cs.toMath(x: graphSize))
    }

    var body: some View {
        let (a, b) = bounds
        let slices = buildSlices(fn, from: a, to: b, count: sections)
        let dx = (b - a) / Double(sections)
        let lowerSum = slices.reduce(0) { $0 + $1.low * dx }
        let upperSum = slices.reduce(0) { $0 + $1.high * dx }
        let integral = fn.antiderivative.map { $0(b) - $0(a) }

        VStack(spacing: 14) {

            Text("Darboux sums against the integral")
                .font(.caption)
                .foregroundStyle(.secondary)

            plot(slices)

            ModeSelector(mode: $mode)
                .frame(width: graphSize)

            Picker("Function", selection: $preset) {
                ForEach(DarbouxPreset.allCases) { option in
                    Text(option.displayName).tag(option)
                }
            }
            .pickerStyle(.menu)
            .frame(width: graphSize)

            readout(lower: lowerSum, upper: upperSum, integral: integral)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(sections) sections")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                // Continuous on purpose: a stepped slider ticks under the
                // finger the whole way across.
                Slider(value: $rawSections, in: 2...80)
                    .tint(.orange)
            }
            .frame(width: graphSize - 40)
        }
        .padding()
        .adaptivePlot($graphSize)
    }

    // MARK: - Plot

    private func plot(_ slices: [Slice]) -> some View {
        ZStack {
            GridDrawing(step: scale)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 0.5)
            AxisDrawing(axis: .horizontal)
                .stroke(Color.primary.opacity(0.7), lineWidth: 1)
            AxisDrawing(axis: .vertical)
                .stroke(Color.primary.opacity(0.7), lineWidth: 1)

            if mode != .upper {
                StaircaseFill(slices: slices, level: \.low, scale: scale)
                    .fill(Color.blue.opacity(mode == .both ? 0.26 : 0.34))
            }
            if mode == .upper {
                StaircaseFill(slices: slices, level: \.high, scale: scale)
                    .fill(Color.orange.opacity(0.34))
            }
            if mode == .both {
                GapFill(slices: slices, scale: scale)
                    .fill(Color.orange.opacity(0.4))
            }

            // Only while the bars are wide enough to tell apart. Past that the
            // rules would form a solid block of their own.
            if sections <= 32 {
                StaircaseSeparators(slices: slices,
                                    level: mode == .upper ? \.high : \.low,
                                    scale: scale)
                    .stroke(Color.black.opacity(0.35), lineWidth: 0.6)
            }

            if mode != .upper {
                StaircaseOutline(slices: slices, level: \.low, scale: scale)
                    .stroke(Color.blue, lineWidth: 1.2)
            }
            if mode != .lower {
                StaircaseOutline(slices: slices, level: \.high, scale: scale)
                    .stroke(Color.orange, lineWidth: 1.2)
            }

            FunctionDrawing(f: fn.f, integrF: { _ in 0 }, scale: scale)
                .stroke(Color.primary, lineWidth: 1.5)
        }
        .frame(width: graphSize, height: graphSize)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Readout

    private func readout(lower: Double, upper: Double, integral: Double?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("S⁻ = \(lower, specifier: "%.2f")")
                    .foregroundStyle(.blue)
                Spacer()
                Text("S⁺ = \(upper, specifier: "%.2f")")
                    .foregroundStyle(.orange)
            }
            HStack {
                Text("gap = \(upper - lower, specifier: "%.2f")")
                    .foregroundStyle(upper - lower < 0.05 ? .green : .primary)
                Spacer()
                if let integral {
                    Text("∫f = \(integral, specifier: "%.2f")")
                } else {
                    Text("∫f undefined")
                }
            }
            .foregroundStyle(.secondary)
        }
        .font(.system(size: 13, design: .monospaced))
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .padding(16)
        .frame(width: graphSize)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(alignment: .bottom) {
            Text(preset.isIntegrable
                 ? "The gap shrinks with every extra section."
                 : "The gap never shrinks, whatever the subdivision.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .offset(y: 18)
        }
        .padding(.bottom, 18)
    }
}

/// Tappable buttons rather than a segmented control: no selection tick, and
/// the three states read as what is drawn rather than as a setting.
private struct ModeSelector: View {
    @Binding var mode: DarbouxMode

    var body: some View {
        HStack(spacing: 6) {
            ForEach(DarbouxMode.allCases) { option in
                Button {
                    mode = option
                } label: {
                    Text(option.label)
                        .font(.system(size: 14, weight: mode == option ? .semibold : .regular))
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(mode == option
                                      ? tint(option).opacity(0.25)
                                      : Color.secondary.opacity(0.12))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(tint(option).opacity(mode == option ? 0.9 : 0),
                                        lineWidth: 1)
                        )
                        .foregroundStyle(mode == option ? tint(option) : Color.secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func tint(_ option: DarbouxMode) -> Color {
        switch option {
        case .lower: return .blue
        case .upper: return .orange
        case .both:  return .primary
        }
    }
}

#Preview {
    ScrollView { DarbouxView() }
        .preferredColorScheme(.dark)
}
