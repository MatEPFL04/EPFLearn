//
//  TaylorView.swift
//  LearnViz
//
//  Taylor polynomials around a movable centre. The lower orders stay on screen
//  as ghosts so the family is visible at once, and the region between f and T
//  is shaded so the error has a shape rather than a second set of axes.
//

import SwiftUI

private func factorial(_ n: Int) -> Double {
    n <= 1 ? 1 : Double(n) * factorial(n - 1)
}

// MARK: - Typeset polynomial

/// One term of the polynomial, kept as data so it can be laid out rather than
/// concatenated into a string.
struct PolyTerm: Identifiable {
    let id: Int
    let sign: String            // "", "+" or "−"
    let coefficient: String?    // nil when it is an implicit 1
    let denominator: String?    // nil when the term is not a fraction
    let variable: String?       // nil for the constant term
    let exponent: Int?          // nil for exponent 1
}

/// Renders  T₃(x) = x − 0.167x³  with raised exponents, wrapping to a second
/// line when the polynomial gets long. The stacked-fraction path is kept for
/// the case where a term does carry a denominator, but the view no longer
/// switches typography depending on the centre.
struct PolynomialDisplay: View {
    let order: Int
    let terms: [PolyTerm]
    var shiftNote: String? = nil
    var color: Color = .orange
    var size: CGFloat = 17

    private var body1: Font { .system(size: size, design: .serif) }
    private var small: Font { .system(size: size * 0.62, design: .serif) }

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            FlowLayout(spacing: 5, lineSpacing: 8) {
                head
                ForEach(terms) { term in
                    termView(term)
                }
            }
            if let shiftNote {
                Text(shiftNote)
                    .font(.system(size: size * 0.72, design: .serif))
                    .italic()
                    .foregroundStyle(.secondary)
            }
        }
        .foregroundStyle(color)
    }

    private var head: some View {
        (
            Text("T").font(body1).italic()
            + Text("\(order)").font(small).baselineOffset(-size * 0.22)
            + Text("(x) =").font(body1).italic()
        )
    }

    @ViewBuilder
    private func termView(_ term: PolyTerm) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            if !term.sign.isEmpty {
                Text(term.sign).font(body1)
            }
            if let denominator = term.denominator {
                // Fraction: align the middle of the fraction bar with the baseline
                VStack(spacing: 1) {
                    numeratorView(term)
                    Rectangle()
                        .frame(height: 0.9)
                        .frame(minWidth: size * 0.6)
                    Text(denominator).font(small)
                }
                .alignmentGuide(.firstTextBaseline) { d in
                    // Position so the fraction bar sits on the baseline
                    d[VerticalAlignment.center]
                }
                .fixedSize()
            } else {
                // Non-fraction: just the numerator view with natural baseline
                numeratorView(term)
            }
        }
    }

    @ViewBuilder
    private func numeratorView(_ term: PolyTerm) -> some View {
        buildTermText(term)
    }

    private func buildTermText(_ term: PolyTerm) -> Text {
        var result = Text("")

        if let coefficient = term.coefficient {
            result = result + Text(coefficient).font(body1)
        }

        if let variable = term.variable {
            result = result + Text(variable).font(body1).italic()

            if let exponent = term.exponent {
                result = result + Text("\(exponent)")
                    .font(small)
                    .fontWeight(.regular)
                    .baselineOffset(size * 0.35)
            }
        }

        return result
    }
}

/// Left-to-right layout that wraps, so a long polynomial breaks onto a second
/// line instead of being squeezed unreadable.
struct FlowLayout: Layout {
    var spacing: CGFloat = 6
    var lineSpacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, lineHeight: CGFloat = 0, widest: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += lineHeight + lineSpacing
                lineHeight = 0
            }
            x += size.width + spacing
            widest = max(widest, x - spacing)
            lineHeight = max(lineHeight, size.height)
        }
        return CGSize(width: min(widest, maxWidth), height: y + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize,
                       subviews: Subviews, cache: inout ()) {
        var x: CGFloat = 0, y: CGFloat = 0, lineHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.width, x > 0 {
                x = 0
                y += lineHeight + lineSpacing
                lineHeight = 0
            }
            view.place(at: CGPoint(x: bounds.minX + x, y: bounds.minY + y),
                       proposal: ProposedViewSize(size))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

// MARK: - Functions

private struct TaylorFunction {
    let name: String
    let f: (Double) -> Double
    /// k-th derivative of f at x. Having it for any x, not just 0, is what
    /// lets the centre move.
    let derivative: (Int, Double) -> Double
    let domain: ClosedRange<Double>
}

enum TaylorPreset: String, CaseIterable, Identifiable {
    case sine
    case cosine
    case exponential
    case logarithm

    var id: Self { self }

    var displayName: String {
        switch self {
        case .sine:        return "sin(x)"
        case .cosine:      return "cos(x)"
        case .exponential: return "eˣ"
        case .logarithm:   return "ln(1+x)"
        }
    }

    fileprivate var function: TaylorFunction {
        switch self {
        case .sine:
            return TaylorFunction(
                name: displayName,
                f: { sin($0) },
                // Differentiating sin k times shifts the phase by k quarter turns.
                derivative: { k, x in sin(x + Double(k) * .pi / 2) },
                domain: -100...100
            )
        case .cosine:
            return TaylorFunction(
                name: displayName,
                f: { cos($0) },
                derivative: { k, x in cos(x + Double(k) * .pi / 2) },
                domain: -100...100
            )
        case .exponential:
            return TaylorFunction(
                name: displayName,
                f: { exp($0) },
                derivative: { _, x in exp(x) },
                domain: -100...100
            )
        case .logarithm:
            return TaylorFunction(
                name: displayName,
                f: { x in x > -1 ? log(1 + x) : .nan },
                derivative: { k, x in
                    guard x > -1 else { return .nan }
                    if k == 0 { return log(1 + x) }
                    let sign: Double = (k % 2 == 1) ? 1 : -1
                    return sign * factorial(k - 1) / pow(1 + x, Double(k))
                },
                domain: -0.98...100
            )
        }
    }

    /// Centres worth landing on exactly, so the coefficients come out clean.
    var snapPoints: [Double] {
        stride(from: -6, through: 6, by: 1).map { Double($0) }
    }
}

// MARK: - Curves

/// Draws a curve but lifts the pen instead of joining two points that jump too
/// far apart. Stops the fake vertical spikes near asymptotes and domain edges.
private struct BreakingCurve: Shape {
    let f: (Double) -> Double
    let scale: Double

    func path(in rect: CGRect) -> Path {
        let cs = MathCoordinateSpace(rect: rect, scale: scale)
        var path = Path()
        var previousY: CGFloat?
        let jumpThreshold: CGFloat = 24

        for px in stride(from: rect.minX, to: rect.maxX, by: 1.0) {
            let raw = f(cs.toMath(x: px))
            guard raw.isFinite else { previousY = nil; continue }
            let y = cs.toScreen(x: 0, y: raw).y
            guard y > rect.minY - 400 && y < rect.maxY + 400 else {
                previousY = nil
                continue
            }
            if let prev = previousY, abs(y - prev) < jumpThreshold {
                path.addLine(to: CGPoint(x: px, y: y))
            } else {
                path.move(to: CGPoint(x: px, y: y))
            }
            previousY = y
        }
        return path
    }
}

/// The band between f and its Taylor polynomial. Giving the error an area
/// rather than a second set of axes keeps everything in one picture.
private struct ErrorRibbon: Shape {
    let f: (Double) -> Double
    let g: (Double) -> Double
    let scale: Double

    func path(in rect: CGRect) -> Path {
        let cs = MathCoordinateSpace(rect: rect, scale: scale)
        var path = Path()
        var run: [(CGFloat, CGFloat, CGFloat)] = []

        func flush() {
            guard run.count > 1 else { run.removeAll(); return }
            path.move(to: CGPoint(x: run[0].0, y: run[0].1))
            for p in run.dropFirst() { path.addLine(to: CGPoint(x: p.0, y: p.1)) }
            for p in run.reversed() { path.addLine(to: CGPoint(x: p.0, y: p.2)) }
            path.closeSubpath()
            run.removeAll()
        }

        let limit = rect.height * 2
        for px in stride(from: rect.minX, to: rect.maxX, by: 2.0) {
            let x = cs.toMath(x: px)
            let a = f(x), b = g(x)
            guard a.isFinite, b.isFinite else { flush(); continue }
            let yA = cs.toScreen(x: 0, y: a).y
            let yB = cs.toScreen(x: 0, y: b).y
            guard abs(yA - rect.midY) < limit, abs(yB - rect.midY) < limit else {
                flush(); continue
            }
            run.append((px, yA, yB))
        }
        flush()
        return path
    }
}

// MARK: - View

struct TaylorView: View {

    @State private var preset: TaylorPreset
    @State private var order = 3
    @State private var center = 0.0
    @State private var graphSize: CGFloat = 320

    private let baseScale: Double = 25
    private var scale: Double { baseScale * Double(graphSize) / 300 }
    private var plotHeight: CGFloat { graphSize * 0.72 }

    init(_ initial: TaylorPreset = .sine) {
        _preset = State(initialValue: initial)
    }

    private var fn: TaylorFunction { preset.function }
    private var halfWidth: Double { Double(graphSize) / 2 / scale }

    private var centerRange: ClosedRange<Double> {
        let lo = max(fn.domain.lowerBound, -halfWidth + 0.2)
        let hi = min(fn.domain.upperBound, halfWidth - 0.2)
        return lo...hi
    }

    // MARK: Maths

    private func taylor(_ x: Double, order k: Int) -> Double {
        var sum = 0.0
        for i in 0...k {
            let d = fn.derivative(i, center)
            guard d.isFinite else { return .nan }
            sum += d * pow(x - center, Double(i)) / factorial(i)
        }
        return sum
    }

    // MARK: Snapping

    /// Pulls the slider onto a nearby whole number. Without this, landing
    /// exactly on 1 by dragging is a matter of luck, and those centres are the
    /// ones whose coefficients come out clean.
    private var snappedCenter: Binding<Double> {
        Binding(
            get: { center },
            set: { raw in
                let tolerance = (centerRange.upperBound - centerRange.lowerBound) * 0.022
                let nearest = preset.snapPoints
                    .filter { centerRange.contains($0) }
                    .min { abs($0 - raw) < abs($1 - raw) }
                if let nearest, abs(nearest - raw) < tolerance {
                    center = nearest
                } else {
                    center = raw
                }
            }
        )
    }

    /// A whole number reads better than "1.00" once the slider has snapped.
    private func centreLabel(_ a: Double) -> String {
        if abs(a) < 1e-6 { return "0" }
        if abs(a - a.rounded()) < 1e-6 { return String(Int(a.rounded())) }
        return String(format: "%.2f", a)
    }

    private var isCentred: Bool { abs(center) < 0.005 }

    // MARK: Body

    var body: some View {
        VStack(spacing: 14) {
            
            Text("Taylor Polynomials").font(.headline)


            plot

            Picker("Function", selection: $preset) {
                ForEach(TaylorPreset.allCases) { option in
                    Text(option.displayName).tag(option)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(width: graphSize)
            .onChange(of: preset) { _, _ in
                center = min(max(center, centerRange.lowerBound), centerRange.upperBound)
            }

            PolynomialDisplay(
                order: order,
                terms: polynomialTerms,
                // A blank line rather than nil: the block keeps the same height
                // whether or not the substitution note is needed, so the layout
                // does not jump as the centre leaves 0.
                shiftNote: isCentred ? " " : "u = x − \(centreLabel(center))"
            )
            .frame(width: graphSize)

            OrderSelector(order: $order, range: 1...6)
                .frame(width: graphSize)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Centre a = \(centreLabel(center))")
                    Spacer()
                    Button("reset to 0") { center = 0 }
                        .font(.caption2)
                        .disabled(isCentred)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                // No step: a continuous slider does not tick as it moves. The
                // snapping is handled in the binding instead.
                Slider(value: snappedCenter, in: centerRange)
                    .tint(.orange)
            }
            .frame(width: graphSize)
        }
        .padding(.horizontal)
        .adaptivePlot($graphSize)
    }

    // MARK: Plot

    private var plot: some View {
        ZStack {
            GridDrawing(step: scale)
                .stroke(Color.secondary.opacity(0.22), lineWidth: 0.5)
            AxisDrawing(axis: .horizontal)
                .stroke(Color.primary.opacity(0.7), lineWidth: 1)
            AxisDrawing(axis: .vertical)
                .stroke(Color.primary.opacity(0.7), lineWidth: 1)

            ErrorRibbon(f: fn.f, g: { taylor($0, order: order) }, scale: scale)
                .fill(Color.orange.opacity(0.16))

            BreakingCurve(f: fn.f, scale: scale)
                .stroke(Color.blue, lineWidth: 2)
            BreakingCurve(f: { taylor($0, order: order) }, scale: scale)
                .stroke(Color.orange, lineWidth: 2)

            centreMarker
        }
        .frame(width: graphSize, height: plotHeight)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var geometry: MathCoordinateSpace {
        MathCoordinateSpace(
            rect: CGRect(x: 0, y: 0, width: graphSize, height: plotHeight),
            scale: scale
        )
    }

    private var centreMarker: some View {
        let fx = fn.f(center)
        let p = geometry.toScreen(x: center, y: fx.isFinite ? fx : 0)
        return Circle()
            .fill(Color.orange)
            .frame(width: 9, height: 9)
            .position(p)
    }

    // MARK: Polynomial terms

    /// One coefficient style whatever the centre. The number of decimals
    /// follows the order of magnitude, otherwise 1/120 prints as "0.01" and
    /// 1/720 as "0.00".
    private func decimalString(_ value: Double) -> String {
        let v = abs(value)
        switch v {
        case 100...:   return String(format: "%.1f", v)
        case 1..<100:  return String(format: "%.2f", v)
        case 0.01..<1: return String(format: "%.3f", v)
        default:       return String(format: "%.4f", v)
        }
    }

    private var polynomialTerms: [PolyTerm] {
        let variable = isCentred ? "x" : "u"
        var result: [PolyTerm] = []

        for k in 0...order {
            let d = fn.derivative(k, center)
            guard d.isFinite else { continue }
            let coefficient = d / factorial(k)
            guard abs(coefficient) > 1e-9 else { continue }

            let sign = coefficient < 0 ? "−" : (result.isEmpty ? "" : "+")
            let variablePart: String? = k == 0 ? nil : variable
            let exponent: Int? = k <= 1 ? nil : k

            // The only exception kept: a 1 in front of a power stays implicit,
            // so the display never reads "1.00x".
            var magnitude: String? = decimalString(coefficient)
            if k > 0, abs(abs(coefficient) - 1) < 1e-9 { magnitude = nil }

            result.append(PolyTerm(
                id: k,
                sign: sign,
                coefficient: magnitude,
                denominator: nil,   // never a stacked fraction any more
                variable: variablePart,
                exponent: exponent
            ))
        }
        return result
    }
}

// MARK: - Order selector

/// Tappable buttons rather than a stepped Slider: no haptic ticks, and every
/// order is visible at once.
private struct OrderSelector: View {
    @Binding var order: Int
    let range: ClosedRange<Int>

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Order")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: 6) {
                ForEach(Array(range), id: \.self) { k in
                    Button {
                        order = k
                    } label: {
                        Text("\(k)")
                            .font(.system(size: 14,
                                          weight: order == k ? .semibold : .regular,
                                          design: .serif))
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(order == k
                                          ? Color.orange.opacity(0.25)
                                          : Color.secondary.opacity(0.12))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.orange.opacity(order == k ? 0.9 : 0),
                                            lineWidth: 1)
                            )
                            .foregroundStyle(order == k ? Color.orange : Color.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    ScrollView { TaylorView() }
        .preferredColorScheme(.dark)
}
