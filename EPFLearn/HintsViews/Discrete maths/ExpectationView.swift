import SwiftUI

// MARK: - Distribution model

/// Discrete-law families offered to the user.
enum DistributionShape: String, CaseIterable, Identifiable {
    case uniform    = "Uniform"
    case bell       = "Bell"
    case decreasing = "Decay"
    case custom     = "Free"
    var id: Self { self }
}

// Shared chart geometry: the axis, the value labels under it and the E[X]
// caption above are all positioned from these.
private let kLeft: CGFloat = 12, kRight: CGFloat = 12, kTop: CGFloat = 20, kBottom: CGFloat = 30

private func chartBox<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
    content()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.gray.opacity(0.2)))
}

// MARK: - Independent view 1: theoretical PMF

/// Pure theoretical chart: blue probability bars + green E[X] balance point.
///
/// `barFractions` is what gets drawn (0…1 of the plot height) and is kept
/// separate from `probabilities`, which is only used for the % labels. In free
/// mode the two differ: the bar must follow the finger, while the probability
/// it represents is renormalised so the law still sums to 1.
struct TheoreticalPMFChart: View {
    let probabilities: [Double]
    let barFractions: [Double]
    let mean: Double
    var firstValue: Int = 1
    let editable: Bool
    let onEdit: (CGPoint, CGSize) -> Void
    var onEditEnd: () -> Void = {}

    private var n: Int { probabilities.count }

    var body: some View {
        chartBox {
            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    Canvas { ctx, size in draw(ctx, size: size) }
                    // Always attached, whatever the current law: the first drag
                    // is what switches the chart into free mode. Requiring the
                    // user to pick "Free" first made the bars look inert.
                    Color.clear
                        .contentShape(Rectangle())
                        // minimumDistance 0 fires on touch-down, before any
                        // movement, which is what lets the parent freeze the
                        // ScrollView in time. Bars are dragged vertically -
                        // the exact direction the scroll would otherwise claim.
                        .highPriorityGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { v in onEdit(v.location, geo.size) }
                                .onEnded { _ in onEditEnd() }
                        )
                }
            }
        }
    }

    private func draw(_ ctx: GraphicsContext, size: CGSize) {
        let plotW = size.width - kLeft - kRight
        let plotH = size.height - kTop - kBottom
        guard plotW > 0, plotH > 0, n > 0 else { return }

        let slot  = plotW / CGFloat(n)
        let axisY = kTop + plotH

        var axis = Path()
        axis.move(to: CGPoint(x: kLeft, y: axisY))
        axis.addLine(to: CGPoint(x: kLeft + plotW, y: axisY))
        ctx.stroke(axis, with: .color(.secondary.opacity(0.35)), lineWidth: 1)

        // Faint ceiling in free mode, so the drag has a visible range.
        if editable {
            var top = Path()
            top.move(to: CGPoint(x: kLeft, y: kTop))
            top.addLine(to: CGPoint(x: kLeft + plotW, y: kTop))
            ctx.stroke(top, with: .color(.blue.opacity(0.18)),
                       style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
        }

        for i in 0..<n {
            let cx = kLeft + (CGFloat(i) + 0.5) * slot
            let barW = slot * 0.6
            let frac = min(max(barFractions.indices.contains(i) ? barFractions[i] : 0, 0), 1)
            let h = CGFloat(frac) * plotH

            // Hit target stays visible even at zero, otherwise a bar dragged to
            // the floor can never be grabbed again.
            if editable && h < 3 {
                let r = CGRect(x: cx - barW / 2, y: axisY - 3, width: barW, height: 3)
                ctx.fill(Path(roundedRect: r, cornerSize: CGSize(width: 1.5, height: 1.5)),
                         with: .color(.blue.opacity(0.25)))
            } else if h > 0.5 {
                let r = CGRect(x: cx - barW / 2, y: axisY - h, width: barW, height: h)
                ctx.fill(Path(roundedRect: r, cornerSize: CGSize(width: 3, height: 3)),
                         with: .color(.blue))
            }
            if n <= 15 {
                ctx.draw(Text("\(firstValue + i)").font(.system(size: 9)).foregroundStyle(.secondary),
                         at: CGPoint(x: cx, y: axisY + 10))
            }
            if n <= 10, probabilities.indices.contains(i) {
                let p = probabilities[i]
                let pct = p >= 0.1 ? "\(Int((p * 100).rounded()))%" : String(format: "%.1f%%", p * 100)
                ctx.draw(Text(pct).font(.system(size: 8.5, weight: .medium)).foregroundStyle(.blue),
                         at: CGPoint(x: cx, y: max(kTop + 5, axisY - h - 7)))
            }
        }

        // E[X]: line + balance-point triangle
        let mx = kLeft + (CGFloat(mean) - CGFloat(firstValue) + 0.5) * slot
        var line = Path()
        line.move(to: CGPoint(x: mx, y: kTop + 2))
        line.addLine(to: CGPoint(x: mx, y: axisY))
        ctx.stroke(line, with: .color(.green), style: StrokeStyle(lineWidth: 2))

        var tri = Path()
        let tw: CGFloat = 8
        tri.move(to: CGPoint(x: mx, y: axisY + 2))
        tri.addLine(to: CGPoint(x: mx - tw, y: axisY + 12))
        tri.addLine(to: CGPoint(x: mx + tw, y: axisY + 12))
        tri.closeSubpath()
        ctx.fill(tri, with: .color(.green))

        // Keep the label pinned to the top edge, clear of the bars.
        ctx.draw(Text("E[X] = \(String(format: "%.2f", mean))")
                    .font(.system(size: 10.5, weight: .semibold)).foregroundStyle(.green),
                 at: CGPoint(x: min(max(mx, 32), size.width - 32), y: 9))
    }
}

// MARK: - Main view

/// Interactive view about expectation.
///
/// One idea: E[X] = Σ xᵢ·P(X = xᵢ) weights each value by how likely it is, so
/// it is not the midpoint of the values. Drag the bars to reshape the law and
/// watch the green marker move off the middle.
///
/// The empirical half (sampling draws, X̄ₙ → E[X], law of large numbers) was
/// removed on purpose: it is not part of the first-year syllabus here.
struct ExpectationView: View {

    /// Set in challenge mode so the run can grade the law the student shapes.
    var onReading: ((ChallengeReading) -> Void)? = nil

    @State private var count: Double = 6           // number of values (2…10)
    @State private var shape: DistributionShape = .bell
    @State private var skew: Double = 0.5          // law shape 0…1
    @State private var rawWeights: [Double] = []   // "Free" mode, already 0…1
    @State private var isDragging = false

    /// Outcomes are labelled 1…n by default (a die), or 0…n−1 (a coin paying
    /// 0 or 1, an indicator variable). Without the second option E[X] can never
    /// come out below 1, so a 0/1 experiment could not be checked here at all.
    @State private var startAtZero = false
    private var firstValue: Int { startAtZero ? 0 : 1 }

    private var n: Int { max(2, Int(count.rounded())) }

    private var probabilities: [Double] {
        let w = weights(for: shape)
        let total = w.reduce(0, +)
        guard total > 0 else { return Array(repeating: 1.0 / Double(n), count: n) }
        return w.map { $0 / total }
    }

    /// What the blue bars actually draw. In free mode this is the raw dragged
    /// height, so the bar tracks the finger; elsewhere the tallest bar fills
    /// the plot, which reads better when probabilities are small.
    private var barFractions: [Double] {
        if shape == .custom {
            let w = rawWeights.count == n ? rawWeights : Array(repeating: 0.5, count: n)
            return w.map { min(max($0, 0), 1) }
        }
        let probs = probabilities
        let maxP = max(probs.max() ?? 1, 0.0001)
        return probs.map { $0 / maxP * 0.9 }
    }

    private var reading: ExpectationReading {
        ExpectationReading(values: (0..<n).map { firstValue + $0 },
                           probabilities: probabilities,
                           mean: theoreticalMean)
    }

    private var theoreticalMean: Double {
        probabilities.enumerated().reduce(0) { $0 + Double(firstValue + $1.offset) * $1.element }
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                intro
                theoreticalSection
            }
            .padding(14)
        }
        // Frozen the instant a finger lands on the bars, released when it
        // lifts. Without this the vertical drag scrolls the page instead.
        .scrollDisabled(isDragging)
        .onAppear(perform: syncWeights)
        .onChange(of: reading, initial: true) { _, new in
            onReading?(.expectation(new))
        }
        .onChange(of: count) { _, _ in syncWeights() }
        .onChange(of: shape) { oldValue, newValue in
            // Guarded by isDragging: when the drag itself flips the law to
            // free, editBar has already written the dragged bar and this
            // reseeding would wipe it out on the very next frame.
            if newValue == .custom, !isDragging {
                rawWeights = normalisedForDragging(weights(for: oldValue))
            }
            syncWeights()
        }
    }

    private var intro: some View {
        VizHeader("Expectation", subtitle: "E[X] = Σ xᵢ · P(X = xᵢ)", mono: true)
    }

    // MARK: Theoretical section

    private var theoreticalSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Theoretical law")
                    .font(.system(.caption, design: .monospaced)).foregroundStyle(.secondary)
                Spacer()
                Label("drag the bars", systemImage: "hand.draw")
                    .font(.system(.caption2, design: .monospaced)).foregroundStyle(.blue)
            }

            TheoreticalPMFChart(
                probabilities: probabilities,
                barFractions: barFractions,
                mean: theoreticalMean,
                firstValue: firstValue,
                editable: shape == .custom,
                onEdit: { loc, size in editBar(at: loc, in: size) },
                onEditEnd: { isDragging = false }
            )
            .frame(height: 150)

            expectationBreakdown

            controls
        }
    }

    /// The definition, written out on the law currently on screen. Without it
    /// E[X] is just a marker sliding around; with it the weighting is visible.
    private var expectationBreakdown: some View {
        let probs = probabilities
        let terms = probs.enumerated()
            .map { i, p in "\(firstValue + i)×\(String(format: "%.2f", p))" }
            .joined(separator: " + ")
        let mid = (Double(firstValue) + Double(firstValue + n - 1)) / 2.0
        return VStack(alignment: .leading, spacing: 4) {
            Text("E[X] = \(terms)")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 8) {
                Text("= \(fmt(theoreticalMean))")
                    .font(.system(.footnote, design: .monospaced).weight(.bold))
                    .foregroundStyle(.green)
                Text(abs(theoreticalMean - mid) < 0.005
                     ? "midpoint \(fmt(mid)): matches, because this law happens to be symmetric"
                     : "midpoint of the values is \(fmt(mid)): not the same thing")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.green.opacity(0.08)))
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            VizSlider(label: "outcomes", value: $count, range: 2...10, step: 1,
                      accent: .blue, valueText: "\(n)")

            Picker("Outcome values", selection: $startAtZero) {
                Text("values 1…\(n)").tag(false)
                Text("values 0…\(n - 1)").tag(true)
            }
            .pickerStyle(.menu)
            .labelsHidden()

            Picker("Probability law", selection: $shape) {
                ForEach(DistributionShape.allCases) { distribution in
                    Text(distribution.rawValue).tag(distribution)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()

            if shape == .bell || shape == .decreasing {
                VizSlider(label: shape == .bell ? "peak" : "decay",
                          value: $skew, range: 0...1, accent: .green,
                          caption: shape == .bell ? "Moves the peak of the bell."
                                                  : "Controls the decay rate.")
            }
        }
    }

    private func weights(for shape: DistributionShape) -> [Double] {
        switch shape {
        case .uniform:
            return Array(repeating: 1, count: n)
        case .bell:
            let c = 1 + skew * Double(n - 1)
            let sigma = max(0.8, Double(n) / 5)
            return (1...n).map { i in exp(-pow(Double(i) - c, 2) / (2 * sigma * sigma)) }
        case .decreasing:
            let r = 0.35 + skew * 0.6
            return (1...n).map { i in pow(r, Double(i - 1)) }
        case .custom:
            if rawWeights.count == n { return rawWeights }
            return Array(repeating: 1, count: n)
        }
    }

    /// Free-mode weights double as bar heights, so they must land in 0…1 with
    /// the tallest bar near the top when a preset is handed over.
    private func normalisedForDragging(_ w: [Double]) -> [Double] {
        let m = max(w.max() ?? 1, 0.0001)
        return w.map { min(max($0 / m * 0.85, 0.01), 1) }
    }

    private func fmt(_ v: Double) -> String { String(format: "%.2f", v) }

    private func syncWeights() {
        if rawWeights.count != n {
            rawWeights = normalisedForDragging(Array(repeating: 1, count: n))
        }
    }

    private func editBar(at loc: CGPoint, in size: CGSize) {
        let plotW = size.width - kLeft - kRight
        let plotH = size.height - kTop - kBottom
        guard plotW > 0, plotH > 0 else { return }
        let slot  = plotW / CGFloat(n)
        let axisY = kTop + plotH
        // Clamped, not guarded: dragging past the last bar or above the ceiling
        // should keep editing rather than silently stop.
        let idx = min(max(Int((loc.x - kLeft) / slot), 0), n - 1)

        // Set before anything else: it is what freezes the ScrollView, and it
        // must be true from the very first touch-down event.
        isDragging = true

        // Dragging any law turns it into a free one, seeded from the curve
        // that was on screen, so the bars never jump when editing starts.
        if shape != .custom || rawWeights.count != n {
            rawWeights = normalisedForDragging(weights(for: shape))
            shape = .custom
        }
        guard rawWeights.count == n else { return }
        let h = max(0, min(plotH, axisY - loc.y))
        rawWeights[idx] = min(max(Double(h / plotH), 0), 1)
    }
}

#Preview {
    ExpectationView()
}
