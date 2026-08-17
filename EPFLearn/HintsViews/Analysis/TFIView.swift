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

            HStack(alignment: .center, spacing: 1 * scale) {
                Text("∫")
                    .font(.system(size: 30 * scale, weight: .thin, design: .serif))
                VStack(alignment: .leading, spacing: 0) {
                    Text(upper).font(limitFont).italic()
                    Spacer(minLength: 2 * scale)
                    Text(lower).font(limitFont)
                }
                .frame(height: 26 * scale)
            }
            .padding(.leading, 3 * scale)

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

    /// g always follows `shared`. f follows it too inside the agreement zone
    /// [−splitPoint, splitPoint], and parts from it outside, with a term that
    /// is exactly 0 at each break so f stays continuous.
    ///
    /// The zone is symmetric on purpose: with the curves parting only on the
    /// right, x = −1 would show F = G, which is more than "f and g agree on
    /// this stretch" can promise.
    func f(_ x: Double) -> Double {
        if x > splitPoint {
            return shared(x) + bumpAmplitude * sin(bumpFreq * (x - splitPoint))
        }
        if x < -splitPoint {
            return shared(x) + bumpAmplitude * sin(bumpFreq * (x + splitPoint))
        }
        return shared(x)
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
            return TFICase(shared: { sin($0) }, splitPoint: 0.6,
                           bumpAmplitude: 0.4, bumpFreq: 3)
        case .line:
            // The fastest oscillation of the three: the vertical gap between
            // the curves swings quickly, so the rate at which F and G separate
            // is easy to watch.
            return TFICase(shared: { $0 }, splitPoint: 0.5,
                           bumpAmplitude: 0.3, bumpFreq: 4)
        case .cosine:
            return TFICase(shared: { cos($0) }, splitPoint: 0.4,
                           bumpAmplitude: -0.35, bumpFreq: 2.5)
        }
    }
}

// MARK: - Definite-integral presets

/// A function together with an antiderivative, so the view can show both sides
/// of ∫ₐᵇ f = F(b) − F(a) at once - the numbers a question asks for, and the
/// region they measure.
private struct IntegralCase {
    let integrand: String        // "t²"
    let antiderivative: String   // "t³/3"
    let f: (Double) -> Double
    let F: (Double) -> Double
}

enum IntegralPreset: String, CaseIterable, Identifiable {
    case square, linear, shifted, cosine

    var id: Self { self }

    var displayName: String {
        switch self {
        case .square:  return "t²"
        case .linear:  return "2t"
        case .shifted: return "t − 1"
        case .cosine:  return "cos t"
        }
    }

    fileprivate var definition: IntegralCase {
        switch self {
        case .square:
            return IntegralCase(integrand: "t²", antiderivative: "t³/3",
                                f: { $0 * $0 }, F: { pow($0, 3) / 3 })
        case .linear:
            return IntegralCase(integrand: "2t", antiderivative: "t²",
                                f: { 2 * $0 }, F: { $0 * $0 })
        case .shifted:
            // Negative before t = 1: the area below the axis is subtracted,
            // which is what makes F decrease there.
            return IntegralCase(integrand: "t − 1", antiderivative: "t²/2 − t",
                                f: { $0 - 1 }, F: { $0 * $0 / 2 - $0 })
        case .cosine:
            return IntegralCase(integrand: "cos t", antiderivative: "sin t",
                                f: { cos($0) }, F: { sin($0) })
        }
    }
}

// MARK: - View

struct TFIView: View {

    /// Two things live here: a concrete ∫ₐᵇ f with its value, and the F-versus-G
    /// comparison. The questions ask for numbers, so the definite integral is
    /// what opens first.
    enum Mode: String, CaseIterable, Identifiable {
        case definite = "∫ₐᵇ f"
        case compare  = "F vs G"
        var id: Self { self }
    }

    @State private var mode: Mode = .definite
    @State private var preset: TFIPreset
    @State private var target: Double = 0.2
    @State private var graphSize: CGFloat = 300

    // Definite-integral mode
    @State private var intPreset: IntegralPreset = .square
    @State private var lower: Double = 1
    @State private var upper: Double = 2

    private let baseScale: Double = 90
    private var scale: Double {
        (mode == .definite ? 34 : baseScale) * Double(graphSize) / 300
    }

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
        VStack(spacing: 10) {

            // Both subtitles are kept to one line: a subtitle that wraps in one
            // mode and not the other moves the whole plot when you switch.
            VizHeader("Fundamental Theorem of Calculus",
                      subtitle: mode == .definite
                        ? "∫ₐᵇ f, as a shaded area."
                        : "Area collected so far, as a function of x.")

            Picker("", selection: $mode) {
                ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(width: graphSize)

            if mode == .definite { definiteStage } else { compareStage }
        }
        .padding()
        .adaptivePlot($graphSize, max: 300)
    }

    // MARK: - Definite integral

    private var intCase: IntegralCase { intPreset.definition }
    private var integralValue: Double { intCase.F(upper) - intCase.F(lower) }

    private var definiteStage: some View {
        VStack(spacing: 10) {
            IntegralExpression(lhs: "",
                               lower: fmt(lower), upper: fmt(upper),
                               integrand: "\(intCase.integrand) dt  =  ?",
                               color: .orange, scale: 0.8)
                .frame(height: 44)

            ZStack {
                GridDrawing(step: scale)
                    .stroke(Color.secondary.opacity(0.25), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal)
                    .stroke(Color.primary.opacity(0.7), lineWidth: 1)
                AxisDrawing(axis: .vertical)
                    .stroke(Color.primary.opacity(0.7), lineWidth: 1)

                AreaUnderCurve(from: lower, to: upper, f: intCase.f, scale: scale)
                    .fill(Color.orange.opacity(0.28))

                FunctionDrawing(f: intCase.f, integrF: { _ in 0 }, scale: scale)
                    .stroke(Color.orange, lineWidth: 2)

                verticalRule(at: lower, color: .primary.opacity(0.45), dash: [4, 3])
                verticalRule(at: upper, color: .primary.opacity(0.45), dash: [4, 3])
            }
            .frame(width: graphSize, height: graphSize)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(alignment: .topLeading) { definiteHUD }

            Picker("Integrand", selection: $intPreset) {
                ForEach(IntegralPreset.allCases) { Text($0.displayName).tag($0) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(width: graphSize)

            HStack(spacing: 8) {
                VizSlider(label: "a", value: $lower, range: -2...3, step: 0.1,
                          accent: .orange, format: "%.2f")
                VizSlider(label: "b", value: $upper, range: -2...3, step: 0.1,
                          accent: .orange, format: "%.2f")
            }
            .frame(width: graphSize)
        }
    }

    /// The tools for the evaluation, not the evaluation itself: an antiderivative
    /// and the two bounds. Printing F(b) − F(a) and its value answered the
    /// questions outright, which left nothing to work out.
    private var definiteHUD: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("F(t) = \(intCase.antiderivative)")
                .foregroundStyle(.orange)
            Text("∫ = F(b) − F(a)")
                .foregroundStyle(.secondary)
            if integralValue < 0 {
                Text("region below the axis")
                    .foregroundStyle(.pink)
            }
        }
        .font(.system(size: 11, weight: .semibold, design: .monospaced))
        .padding(8)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .padding(8)
    }

    private func fmt(_ v: Double) -> String {
        abs(v - v.rounded()) < 0.005 ? String(Int(v.rounded())) : String(format: "%.2f", v)
    }

    // MARK: - F versus G

    private var compareStage: some View {
        VStack(spacing: 10) {
            HStack(spacing: 18) {
                IntegralExpression(lhs: "F(x) =", lower: "0", upper: "x",
                                   integrand: "f(t) dt", color: .red, scale: 0.72)
                IntegralExpression(lhs: "G(x) =", lower: "0", upper: "x",
                                   integrand: "g(t) dt", color: .blue, scale: 0.72)
            }
            .frame(height: 44)

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

                verticalRule(at: current.splitPoint,
                             color: .secondary.opacity(0.5), dash: [2, 3])
                verticalRule(at: -current.splitPoint,
                             color: .secondary.opacity(0.5), dash: [2, 3])
                verticalRule(at: target,
                             color: .primary.opacity(0.4), dash: [4, 3])
            }
            .frame(width: graphSize, height: graphSize)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(alignment: .topLeading) { hud }
            .overlay(alignment: .topTrailing) { legend }

            Picker("Function pair", selection: $preset) {
                ForEach(TFIPreset.allCases) { option in
                    Text(option.displayName).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(width: graphSize)

            VizSlider(label: "x", value: $target, range: -1.6...1.6, step: 0.1, accent: .orange,
                      caption: abs(target) <= current.splitPoint
                        ? "f and g agree over the whole stretch from 0 to x: the two regions coincide."
                        : "The stretch from 0 to x leaves the agreement zone, so F and G drift apart.")
                .frame(width: graphSize)
        }
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
        VStack(alignment: .trailing, spacing: 4) {
            legendItem(.red, "f(x)")
            legendItem(.blue, "g(x)")
        }
        .padding(8)
    }

    private func legendItem(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 6) {
            Text(label).font(.caption2).foregroundStyle(color)
            Rectangle().fill(color).frame(width: 16, height: 3)
        }
    }

    /// Live readout, pinned to the graph itself (not the scroll flow below it)
    /// so it never scrolls out of view while dragging x.
    private var hud: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("F(x) = \(F, specifier: "%.3f")")
                .foregroundStyle(.red)
            Text("G(x) = \(G, specifier: "%.3f")")
                .foregroundStyle(.blue)
            HStack(spacing: 4) {
                Image(systemName: areEqual ? "checkmark.circle.fill" : "xmark.circle.fill")
                Text(areEqual ? "F = G" : "F ≠ G")
            }
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(areEqual ? .green : .orange)
        }
        .font(.system(size: 13, weight: .semibold, design: .monospaced))
        .padding(8)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .padding(8)
    }
}

#Preview {
    ScrollView { TFIView() }
}
