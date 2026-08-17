

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
    // Fixed sample budget per slice. Stepping by a constant in maths space
    // instead would mean tens of thousands of evaluations per slice at low
    // subdivision counts.
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

/// Bars from the axis up to a chosen height of each slice, split by sign so a
/// slice contributing negatively can be drawn differently. Without the split,
/// a supremum below the axis adds ink while subtracting from the sum, and the
/// picture contradicts the number underneath it.
private struct StaircaseFill: Shape {
    let slices: [Slice]
    let level: (Slice) -> Double
    let scale: Double
    var negativePart: Bool? = nil
    /// Restricts the shape to some slices, so two staircases can be drawn in
    /// an order chosen slice by slice.
    var include: ((Slice) -> Bool)? = nil

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cs = MathCoordinateSpace(rect: rect, scale: scale)
        for slice in slices {
            let v = level(slice)
            guard v.isFinite else { continue }
            if let negativePart, negativePart ? v >= 0 : v < 0 { continue }
            if let include, !include(slice) { continue }
            let left  = cs.toScreen(x: slice.xStart, y: 0).x
            let right = cs.toScreen(x: slice.xEnd,   y: 0).x
            let top   = cs.toScreen(x: 0, y: v).y
            path.addRect(CGRect(x: left, y: min(top, rect.midY),
                                width: right - left, height: abs(top - rect.midY)))
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
///
/// Every boundary is drawn the same way. Highlighting only the cuts added by
/// the last refinement made the nesting explicit but striped the plot, one
/// bright rule every other slice - glaring wherever the bars run deep, as they
/// do over the half of a sine that sits below the axis.
private struct StaircaseSeparators: Shape {
    let slices: [Slice]
    let level: (Slice) -> Double
    let scale: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cs = MathCoordinateSpace(rect: rect, scale: scale)
        for slice in slices where slice.id != 0 {
            let v = level(slice)
            guard v.isFinite else { continue }
            let x = cs.toScreen(x: slice.xStart, y: 0).x
            let top = cs.toScreen(x: 0, y: v).y
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
    /// Refinement depth. sections = 2^level, so every increment splits each
    /// slice in two and the partitions form a nested chain.
    @State private var level: Int = 3
    @State private var graphSize: CGFloat = 300

    private static let minLevel = 0
    private static let maxLevel = 7

    static let lowerColor = Color.blue
    static let upperColor = Color.orange

    private let baseScale: Double = 10
    private var scale: Double { baseScale * Double(graphSize) / 300 }
    private var sections: Int { 1 << level }

    init(initial: DarbouxPreset = .sine) {
        _preset = State(initialValue: initial)
    }

    private var fn: DarbouxFunction { preset.function }

    private var bounds: (a: Double, b: Double) {
        let cs = MathCoordinateSpace(size: graphSize, scale: scale)
        return (cs.toMath(x: 0), cs.toMath(x: graphSize))
    }

    private func sums(_ slices: [Slice], dx: Double) -> (lower: Double, upper: Double) {
        (slices.reduce(0) { $0 + $1.low * dx },
         slices.reduce(0) { $0 + $1.high * dx })
    }

    // MARK: Body

    var body: some View {
        let (a, b) = bounds
        let slices = buildSlices(fn, from: a, to: b, count: sections)
        let dx = (b - a) / Double(sections)
        let now = sums(slices, dx: dx)
        let integral = fn.antiderivative.map { $0(b) - $0(a) }

        VStack(spacing: 9) {
            VizHeader("Darboux Sums", subtitle: "Lower and upper staircases squeeze the area from both sides.")
            
            plot(slices)

            ModeSelector(mode: $mode)
                .frame(width: graphSize)

            Picker("Function", selection: $preset) {
                ForEach(DarbouxPreset.allCases) { option in
                    Text(option.displayName).tag(option)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(width: graphSize)

            readout(lower: now.lower, upper: now.upper, integral: integral)

            note(gap: now.upper - now.lower, integral: integral, span: b - a)

            RefinementControl(level: $level,
                              range: DarbouxView.minLevel...DarbouxView.maxLevel,
                              sections: sections)
                .frame(width: graphSize)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .adaptivePlot($graphSize)
    }

    // MARK: Plot

    private func plot(_ slices: [Slice]) -> some View {
        // A separator runs along the outer edge of what is actually painted,
        // so in combined mode it follows whichever of the two bars reaches
        // further from the axis rather than always the lower one.
        let edge: (Slice) -> Double = {
            switch mode {
            case .lower: return { $0.low }
            case .upper: return { $0.high }
            case .both:  return { abs($0.low) >= abs($0.high) ? $0.low : $0.high }
            }
        }()
        // Which of the two bars reaches further from the axis on this slice.
        // The shorter one is painted last so both stay visible, and the strip
        // that shows through is exactly where the two sums disagree.
        let lowReachesFurther: (Slice) -> Bool = { abs($0.low) >= abs($0.high) }
        let highReachesFurther: (Slice) -> Bool = { abs($0.high) > abs($0.low) }

        return ZStack {
            GridDrawing(step: scale)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 0.5)
            AxisDrawing(axis: .horizontal)
                .stroke(Color.primary.opacity(0.7), lineWidth: 1)
            AxisDrawing(axis: .vertical)
                .stroke(Color.primary.opacity(0.7), lineWidth: 1)

            // Combined mode: each sum keeps its own colour. Filling the band
            // between the staircases instead would merge them into one block -
            // over a slice where the infimum is negative and the supremum
            // positive, the two bars are disjoint, one under the axis and one
            // above it, and a single fill across the whole band erases that.
            if mode == .both {
                StaircaseFill(slices: slices, level: { $0.low }, scale: scale,
                              include: lowReachesFurther)
                    .fill(DarbouxView.lowerColor.opacity(0.30))
                StaircaseFill(slices: slices, level: { $0.high }, scale: scale,
                              include: lowReachesFurther)
                    .fill(DarbouxView.upperColor.opacity(0.30))

                StaircaseFill(slices: slices, level: { $0.high }, scale: scale,
                              include: highReachesFurther)
                    .fill(DarbouxView.upperColor.opacity(0.30))
                StaircaseFill(slices: slices, level: { $0.low }, scale: scale,
                              include: highReachesFurther)
                    .fill(DarbouxView.lowerColor.opacity(0.30))
            }

            if mode == .lower {
                StaircaseFill(slices: slices, level: { $0.low }, scale: scale,
                              negativePart: false)
                    .fill(DarbouxView.lowerColor.opacity(0.34))
                // Below the axis, paler: the bar still reads as a contribution
                // that subtracts. Never outlined - StaircaseFill emits one
                // rectangle per slice, so stroking it draws both vertical
                // sides of every bar, and at sixty-odd sections that is a wall
                // of hatching on whichever half of the curve dips negative.
                StaircaseFill(slices: slices, level: { $0.low }, scale: scale,
                              negativePart: true)
                    .fill(DarbouxView.lowerColor.opacity(0.20))
            }

            if mode == .upper {
                StaircaseFill(slices: slices, level: { $0.high }, scale: scale,
                              negativePart: false)
                    .fill(DarbouxView.upperColor.opacity(0.34))
                StaircaseFill(slices: slices, level: { $0.high }, scale: scale,
                              negativePart: true)
                    .fill(DarbouxView.upperColor.opacity(0.20))
            }

            // Only while the bars are wide enough to tell apart. Past that the
            // rules would form a solid block of their own.
            if sections <= 32 {
                StaircaseSeparators(slices: slices, level: edge, scale: scale)
                    .stroke(Color.primary.opacity(0.22), lineWidth: 0.7)
            }

            if mode != .upper {
                StaircaseOutline(slices: slices, level: { $0.low }, scale: scale)
                    .stroke(DarbouxView.lowerColor, lineWidth: 1.2)
            }
            if mode != .lower {
                StaircaseOutline(slices: slices, level: { $0.high }, scale: scale)
                    .stroke(DarbouxView.upperColor, lineWidth: 1.2)
            }

            FunctionDrawing(f: fn.f, integrF: { _ in 0 }, scale: scale)
                .stroke(Color.primary, lineWidth: 1.5)
        }
        .frame(width: graphSize, height: graphSize)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .animation(.easeInOut(duration: 0.3), value: level)
    }

    // MARK: Readout

    /// The three numbers on their own do not say what is happening. On the
    /// Dirichlet comb in particular the screen is a solid black band and a
    /// reading of "S⁺ 30.00", with nothing to say whether the sum is large
    /// because the function is or because the gap simply never closes. One
    /// line of prose, keyed to the case on screen.
    private func note(gap: Double, integral: Double?, span: Double) -> some View {
        let integrable = integral != nil
        let text: String = integrable
            ? "Gap S⁺ − S⁻ = \(String(format: "%.2f", gap)). Each + halves every slice, and the gap shrinks with it: the two staircases close on the same number from either side, and that number is ∫f."
            : "Every slice, however short, holds both rationals and irrationals, so inf = 0 and sup = 1 on all of them. S⁻ stays 0 and S⁺ stays b − a = \(String(format: "%.2f", span)) at every depth: the gap never closes, and f is not Riemann integrable. The black band is the graph: the value jumps between 0 and 1 in every interval."

        return HStack(alignment: .top, spacing: 6) {
            Image(systemName: integrable ? "info.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 10))
                .foregroundStyle(integrable ? Color.secondary : Color.orange)
            Text(text)
                .font(.system(size: 10.5))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .frame(width: graphSize, alignment: .leading)
    }

    private func readout(lower: Double, upper: Double, integral: Double?) -> some View {
        HStack(spacing: 10) {
            Text("S⁻ \(lower, specifier: "%.2f")")
                .foregroundStyle(DarbouxView.lowerColor)
            Spacer(minLength: 4)
            if let integral {
                Text("∫f \(integral, specifier: "%.2f")")
                    .foregroundStyle(.primary)
            } else {
                Text("∫f undefined")
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 4)
            Text("S⁺ \(upper, specifier: "%.2f")")
                .foregroundStyle(DarbouxView.upperColor)
        }
        .font(.system(size: 13, design: .monospaced))
        .lineLimit(1)
        .minimumScaleFactor(0.65)
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .frame(width: graphSize)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Refinement control

/// Halving rather than a free section count. A slider from 2 to 80 walks
/// through partitions that are not nested - going from 2 slices to 3 discards
/// the midpoint - and then S⁺ is under no obligation to decrease. Refining is
/// the operation the theorem is about, so it is the operation the control
/// offers.
private struct RefinementControl: View {
    @Binding var level: Int
    let range: ClosedRange<Int>
    let sections: Int

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 12) {
                button("minus", enabled: level > range.lowerBound) {
                    level -= 1
                }

                Text("\(sections) sections")
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .frame(maxWidth: .infinity)

                button("plus", enabled: level < range.upperBound) {
                    level += 1
                }
            }

            // Each pip is one refinement, so the nesting has a visible length.
            HStack(spacing: 4) {
                ForEach(Array(range), id: \.self) { k in
                    Capsule()
                        .fill(k <= level ? Color.orange.opacity(0.8)
                                         : Color.secondary.opacity(0.2))
                        .frame(height: 3)
                }
            }
        }
    }

    private func button(_ symbol: String, enabled: Bool,
                        action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) { action() }
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 42, height: 30)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.12))
                )
                .foregroundStyle(enabled ? Color.orange : Color.secondary.opacity(0.4))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

// MARK: - Mode selector

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
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity)
                        .frame(height: 28)
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
        case .lower: return DarbouxView.lowerColor
        case .upper: return DarbouxView.upperColor
        case .both:  return Color.primary
        }
    }
}

#Preview {
    ScrollView { DarbouxView() }
}
