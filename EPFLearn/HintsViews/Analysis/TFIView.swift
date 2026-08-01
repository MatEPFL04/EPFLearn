//
//  TFIView.swift
//  LearnViz
//
//  f and g agree up to a break point, then part ways. As long as x stays
//  before that point, F(x) = ∫₀ˣ f and G(x) = ∫₀ˣ g are rigorously equal,
//  because f = g over the whole stretch travelled. Past the break point the
//  two values drift apart. This is the theorem read backwards:
//  F = G everywhere ⟺ f = g everywhere, since F' = f and G' = g.
//

import SwiftUI

// MARK: - Typeset integral

/// Renders something like  F(x) = ∫₀ˣ f(t) dt  with the bounds set above and
/// below the integral sign, rather than crammed onto the baseline.
struct IntegralExpression: View {
    let lhs: String
    let lower: String
    let upper: String
    let integrand: String
    var color: Color = .primary
    var scale: CGFloat = 1

    private var bodyFont: Font { .system(size: 16 * scale, design: .serif) }
    private var limitFont: Font { .system(size: 9 * scale, design: .serif) }

    var body: some View {
        HStack(alignment: .center, spacing: 3 * scale) {
            Text(lhs)
                .font(bodyFont)
                .italic()

            Text("∫")
                .font(.system(size: 34 * scale, weight: .thin, design: .serif))
                .padding(.leading, 3 * scale)
                .padding(.trailing, 11 * scale)
                .overlay(alignment: .topTrailing) {
                    Text(upper)
                        .font(limitFont)
                        .italic()
                        .offset(y: 5 * scale)
                }
                .overlay(alignment: .bottomLeading) {
                    Text(lower)
                        .font(limitFont)
                        .offset(y: -5 * scale)
                }

            Text(integrand)
                .font(bodyFont)
                .italic()
        }
        .foregroundStyle(color)
        .fixedSize()
    }
}

// MARK: - Area between the axis and a curve

struct AreaUnderCurve: Shape {
    var from: Double
    var to: Double
    let f: @Sendable (Double) -> Double
    let scale: Double

    func path(in rect: CGRect) -> Path {
        let cs = MathCoordinateSpace(rect: rect, scale: scale)
        var path = Path()
        let lo = min(from, to)
        let hi = max(from, to)
        guard hi > lo else { return path }

        let steps = max(Int((hi - lo) * scale / 2), 2)
        path.move(to: cs.toScreen(x: lo, y: 0))
        for i in 0...steps {
            let x = lo + (hi - lo) * Double(i) / Double(steps)
            path.addLine(to: cs.toScreen(x: x, y: f(x)))
        }
        path.addLine(to: cs.toScreen(x: hi, y: 0))
        path.closeSubpath()
        return path
    }
}

// MARK: - Model

private struct TFICase {
    let shared: (Double) -> Double
    let splitPoint: Double
    let bumpAmplitude: Double
    let bumpFreq: Double

    /// g always follows `shared`. f follows it too until the break point, then
    /// adds a term that is exactly 0 at the break, so f stays continuous.
    func f(_ x: Double) -> Double {
        guard x > splitPoint else { return shared(x) }
        return shared(x) + bumpAmplitude * sin(bumpFreq * (x - splitPoint))
    }

    func g(_ x: Double) -> Double { shared(x) }
}

/// Named presets so a question can target one pair without an array index.
enum TFIPreset: String, CaseIterable, Identifiable {
    case sine
    case line
    case cosine

    var id: Self { self }

    var displayName: String {
        switch self {
        case .sine:   return "sin(x)"
        case .line:   return "x"
        case .cosine: return "cos(x)"
        }
    }

    fileprivate var definition: TFICase {
        switch self {
        case .sine:
            return TFICase(shared: { sin($0) }, splitPoint: 0.0,
                           bumpAmplitude: 0.4, bumpFreq: 3)
        case .line:
            // The fastest oscillation of the three: the vertical gap between
            // the curves swings quickly, so the rate at which F and G separate
            // is easy to watch.
            return TFICase(shared: { $0 }, splitPoint: 0.5,
                           bumpAmplitude: 0.3, bumpFreq: 4)
        case .cosine:
            return TFICase(shared: { cos($0) }, splitPoint: -0.4,
                           bumpAmplitude: -0.35, bumpFreq: 2.5)
        }
    }
}

// MARK: - View

struct TFIView: View {

    @State private var preset: TFIPreset
    @State private var target: Double = -1.2
    @State private var graphSize: CGFloat = 300

    private let baseScale: Double = 90
    private var scale: Double { baseScale * Double(graphSize) / 300 }

    init(_ initial: TFIPreset = .sine) {
        _preset = State(initialValue: initial)
    }

    private var current: TFICase { preset.definition }

    /// Trapezoid rule. Avoids the sign traps of a piecewise antiderivative and
    /// stays exact to the pixel for display purposes.
    private func integral(
        of fn: (Double) -> Double,
        from a: Double,
        to b: Double,
        steps: Int = 400
    ) -> Double {
        guard b != a else { return 0 }
        let lo = min(a, b), hi = max(a, b)
        let dx = (hi - lo) / Double(steps)
        var sum = 0.0
        var yPrev = fn(lo)
        for i in 1...steps {
            let x = lo + dx * Double(i)
            let y = fn(x)
            sum += (yPrev + y) / 2 * dx
            yPrev = y
        }
        return b >= a ? sum : -sum
    }

    private var F: Double { integral(of: current.f, from: 0, to: target) }
    private var G: Double { integral(of: current.g, from: 0, to: target) }
    private var gap: Double { F - G }
    // Tight on purpose: the gap grows quadratically just past the break point,
    // so a loose threshold keeps claiming equality long after the curves part.
    private var areEqual: Bool { abs(gap) < 0.002 }

    private var cs: MathCoordinateSpace {
        MathCoordinateSpace(size: graphSize, scale: scale)
    }

    var body: some View {
        VStack(spacing: 14) {
            
            Text("Fundamental Theorem of Calculus").font(.headline)

            VStack(alignment: .leading, spacing: 2) {
                IntegralExpression(lhs: "F(x) =", lower: "0", upper: "x",
                                   integrand: "f(t) dt", color: .red)
                IntegralExpression(lhs: "G(x) =", lower: "0", upper: "x",
                                   integrand: "g(t) dt", color: .blue)
            }

            ZStack {
                // Neutral grid: blue would collide with the colour of g.
                GridDrawing(step: scale / 2)
                    .stroke(Color.secondary.opacity(0.25), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal)
                    .stroke(Color.primary.opacity(0.7), lineWidth: 1)
                AxisDrawing(axis: .vertical)
                    .stroke(Color.primary.opacity(0.7), lineWidth: 1)

                // The two accumulated areas. They overlap perfectly while the
                // cursor stays before the break point.
                AreaUnderCurve(from: 0, to: target, f: current.g, scale: scale)
                    .fill(Color.blue.opacity(0.25))
                AreaUnderCurve(from: 0, to: target, f: current.f, scale: scale)
                    .fill(Color.red.opacity(0.25))

                FunctionDrawing(f: current.g, integrF: { _ in 0 }, scale: scale)
                    .stroke(Color.blue, lineWidth: 2)
                FunctionDrawing(f: current.f, integrF: { _ in 0 }, scale: scale)
                    .stroke(Color.red, lineWidth: 1.5)

                // Break point: a plain rule. A translucent panel here muddied
                // into the red and blue areas and turned everything orange.
                verticalRule(at: current.splitPoint,
                             color: .secondary.opacity(0.5), dash: [2, 3])

                verticalRule(at: target,
                             color: .primary.opacity(0.4), dash: [4, 3])
            }
            .frame(width: graphSize, height: graphSize)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(alignment: .topLeading) { legend }

            Picker("Function pair", selection: $preset) {
                ForEach(TFIPreset.allCases) { option in
                    Text(option.displayName).tag(option)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(width: graphSize)

            VStack(alignment: .leading, spacing: 4) {
                Text("x = \(target, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Slider(value: $target, in: -1.6...1.6)
            }
            .frame(width: graphSize - 40)

            readout

            Text(target <= current.splitPoint
                 ? "f and g agree on all of [0, x], so the two shaded regions coincide and F(x) = G(x)."
                 : "Past the break point f and g differ, so the regions no longer match and the two values drift apart.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(width: graphSize)
        }
        .padding()
        .adaptivePlot($graphSize)
    }

    // MARK: - Pieces

    private func verticalRule(at x: Double, color: Color, dash: [CGFloat]) -> some View {
        Path { p in
            let screenX = cs.toScreen(x: x, y: 0).x
            p.move(to: CGPoint(x: screenX, y: 0))
            p.addLine(to: CGPoint(x: screenX, y: graphSize))
        }
        .stroke(color, style: StrokeStyle(lineWidth: 1, dash: dash))
    }

    private var legend: some View {
        VStack(alignment: .leading, spacing: 4) {
            legendItem(.red, "f(x)")
            legendItem(.blue, "g(x)")
        }
        .padding(8)
    }

    private func legendItem(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 6) {
            Rectangle().fill(color).frame(width: 16, height: 3)
            Text(label).font(.caption2).foregroundStyle(color)
        }
    }

    private var readout: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("F(x) = \(F, specifier: "%.3f")")
                    .foregroundStyle(.red)
                Text("G(x) = \(G, specifier: "%.3f")")
                    .foregroundStyle(.blue)
            
            }
            .font(.system(size: 13, design: .monospaced))

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: areEqual ? "checkmark.circle.fill" : "xmark.circle.fill")
                Text(areEqual ? "F(x) = G(x)" : "F(x) ≠ G(x)")
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(areEqual ? .green : .orange)
        }
        .frame(width: graphSize)
    }
}

#Preview {
    ScrollView { TFIView() }
        .preferredColorScheme(.dark)
}
