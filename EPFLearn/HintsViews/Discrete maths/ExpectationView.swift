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

/// Small diamond marker used for the empirical mean.
struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        p.closeSubpath()
        return p
    }
}

// Shared chart geometry so the two independent charts line up identically.
private let kLeft: CGFloat = 12, kRight: CGFloat = 12, kTop: CGFloat = 20, kBottom: CGFloat = 30

private func xForValue(_ v: Double, count n: Int, width: CGFloat) -> CGFloat {
    let plotW = width - kLeft - kRight
    let slot = plotW / CGFloat(max(n, 1))
    return kLeft + (CGFloat(v) - 0.5) * slot
}

private func chartBox<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
    content()
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemGroupedBackground)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.primary.opacity(0.06)))
}

// MARK: - Independent view 1: theoretical PMF

/// Pure theoretical chart: blue probability bars + indigo E[X] balance point.
///
/// `barFractions` is what gets drawn (0…1 of the plot height) and is kept
/// separate from `probabilities`, which is only used for the % labels. In free
/// mode the two differ: the bar must follow the finger, while the probability
/// it represents is renormalised so the law still sums to 1.
struct TheoreticalPMFChart: View {
    let probabilities: [Double]
    let barFractions: [Double]
    let mean: Double
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
                ctx.fill(Path(roundedRect: r, cornerSize: CGSize(width: 4, height: 4)),
                         with: .linearGradient(
                            Gradient(colors: [Color.blue.opacity(0.9), Color.blue.opacity(0.35)]),
                            startPoint: CGPoint(x: cx, y: axisY - h),
                            endPoint: CGPoint(x: cx, y: axisY)))
            }
            if n <= 15 {
                ctx.draw(Text("\(i + 1)").font(.system(size: 9)).foregroundStyle(.secondary),
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
        let mx = kLeft + (CGFloat(mean) - 0.5) * slot
        var line = Path()
        line.move(to: CGPoint(x: mx, y: kTop + 2))
        line.addLine(to: CGPoint(x: mx, y: axisY))
        ctx.stroke(line, with: .color(.indigo), style: StrokeStyle(lineWidth: 2))

        var tri = Path()
        let tw: CGFloat = 8
        tri.move(to: CGPoint(x: mx, y: axisY + 2))
        tri.addLine(to: CGPoint(x: mx - tw, y: axisY + 12))
        tri.addLine(to: CGPoint(x: mx + tw, y: axisY + 12))
        tri.closeSubpath()
        ctx.fill(tri, with: .color(.indigo))

        // Keep the label pinned to the top edge, clear of the bars.
        ctx.draw(Text("E[X] = \(String(format: "%.2f", mean))")
                    .font(.system(size: 10.5, weight: .semibold)).foregroundStyle(.indigo),
                 at: CGPoint(x: min(max(mx, 32), size.width - 32), y: 9))
    }
}

// MARK: - Independent view 2: empirical histogram

/// Pure empirical chart: orange histogram of observed counts + animated X̄ₙ marker.
struct EmpiricalHistogramChart: View {
    let counts: [Int]
    let total: Int
    let empiricalMean: Double?

    private var n: Int { counts.count }

    var body: some View {
        chartBox {
            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    Canvas { ctx, size in draw(ctx, size: size) }

                    if let em = empiricalMean {
                        let plotH = geo.size.height - kTop - kBottom
                        let mx = xForValue(em, count: n, width: geo.size.width)
                        ZStack(alignment: .topLeading) {
                            Rectangle()
                                .fill(Color.orange.opacity(0.9))
                                .frame(width: 2, height: max(0, plotH - 4))
                                .position(x: mx, y: kTop + 4 + max(0, plotH - 4) / 2)
                            Diamond()
                                .fill(Color.orange)
                                .frame(width: 10, height: 10)
                                .position(x: mx, y: kTop + plotH)
                            Text("X̄ₙ = \(String(format: "%.2f", em))")
                                .font(.system(size: 10.5, weight: .bold))
                                .foregroundStyle(.orange)
                                .position(x: min(max(mx, 36), geo.size.width - 36), y: 9)
                        }
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                        .allowsHitTesting(false)
                        .animation(.easeInOut(duration: 0.4), value: empiricalMean)
                    }
                }
            }
        }
    }

    private func draw(_ ctx: GraphicsContext, size: CGSize) {
        let plotW = size.width - kLeft - kRight
        let plotH = size.height - kTop - kBottom
        guard plotW > 0, plotH > 0, n > 0 else { return }
        let axisY = kTop + plotH

        var axis = Path()
        axis.move(to: CGPoint(x: kLeft, y: axisY))
        axis.addLine(to: CGPoint(x: kLeft + plotW, y: axisY))
        ctx.stroke(axis, with: .color(.secondary.opacity(0.35)), lineWidth: 1)

        guard total > 0 else {
            ctx.draw(Text("Draw samples to build the histogram")
                        .font(.system(size: 11)).foregroundStyle(.secondary),
                     at: CGPoint(x: size.width / 2, y: kTop + plotH / 2))
            return
        }

        let slot = plotW / CGFloat(n)
        let maxC = max(counts.max() ?? 1, 1)

        for i in 0..<n {
            let c = counts[i]
            let cx = kLeft + (CGFloat(i) + 0.5) * slot
            let barW = slot * 0.6
            let h = CGFloat(Double(c) / Double(maxC)) * plotH * 0.9
            if h > 0.5 {
                let r = CGRect(x: cx - barW / 2, y: axisY - h, width: barW, height: h)
                ctx.fill(Path(roundedRect: r, cornerSize: CGSize(width: 4, height: 4)),
                         with: .linearGradient(
                            Gradient(colors: [Color.orange.opacity(0.9), Color.orange.opacity(0.35)]),
                            startPoint: CGPoint(x: cx, y: axisY - h),
                            endPoint: CGPoint(x: cx, y: axisY)))
            }
            if n <= 15 {
                ctx.draw(Text("\(i + 1)").font(.system(size: 9)).foregroundStyle(.secondary),
                         at: CGPoint(x: cx, y: axisY + 10))
            }
            if n <= 10 && c > 0 {
                ctx.draw(Text("\(c)").font(.system(size: 8.5, weight: .medium)).foregroundStyle(.orange),
                         at: CGPoint(x: cx, y: max(kTop + 5, axisY - h - 7)))
            }
        }
    }
}

// MARK: - Main view

/// Interactive view about expectation.
///
/// Teaching idea: when the law is known, E[X] = Σ xᵢ·P(X = xᵢ) is trivial to
/// compute. The interesting part is estimating E[X] empirically by repeating the
/// experiment: the sample mean X̄ₙ converges to E[X] (law of large numbers).
///
/// Two fully independent charts: a theoretical PMF (blue + indigo E[X]) and an
/// empirical histogram of the draws (orange + X̄ₙ). Nothing is overlaid.
struct ExpectationView: View {

    @State private var count: Double = 6           // number of values (2…20)
    @State private var shape: DistributionShape = .bell
    @State private var skew: Double = 0.5          // law shape 0…1
    @State private var rawWeights: [Double] = []   // "Free" mode, already 0…1
    @State private var isDragging = false

    @State private var pool: [Int] = []            // pool of draws (values 1…n)
    @State private var draws: Double = 0           // draws used 0…maxDraws

    private let maxDraws = 1000

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

    private var theoreticalMean: Double {
        probabilities.enumerated().reduce(0) { $0 + Double($1.offset + 1) * $1.element }
    }

    private var usedDraws: Int { min(Int(draws.rounded()), pool.count) }

    private var counts: [Int] {
        var c = Array(repeating: 0, count: n)
        for v in pool.prefix(usedDraws) where v >= 1 && v <= n { c[v - 1] += 1 }
        return c
    }

    private var empiricalMean: Double? {
        guard usedDraws > 0 else { return nil }
        return Double(pool.prefix(usedDraws).reduce(0, +)) / Double(usedDraws)
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                intro
                theoreticalSection
                Divider()
                empiricalSection
            }
            .padding(14)
        }
        // Frozen the instant a finger lands on the bars, released when it
        // lifts. Without this the vertical drag scrolls the page instead.
        .scrollDisabled(isDragging)
        .background(Color(.systemGroupedBackground))
        .onAppear(perform: regeneratePool)
        .onChange(of: count) { _, _ in regeneratePool() }
        .onChange(of: skew)  { _, _ in regeneratePool() }
        .onChange(of: shape) { oldValue, newValue in
            // Guarded by isDragging: when the drag itself flips the law to
            // free, editBar has already written the dragged bar and this
            // reseeding would wipe it out on the very next frame.
            if newValue == .custom, !isDragging {
                rawWeights = normalisedForDragging(weights(for: oldValue))
            }
            regeneratePool()
        }
        // Deliberately NOT observing rawWeights: resampling 1000 draws on every
        // frame of the drag is what made the bars feel stuck. The pool is
        // rebuilt once, when the finger lifts.
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Expectation").font(.title2.bold())
            Text("E[X] is the average of the values weighted by their probabilities: the balance point of the distribution.")
                .font(.footnote).foregroundStyle(.secondary)
            Text("E[X] = Σ xᵢ · P(X = xᵢ)")
                .font(.system(.footnote, design: .monospaced))
                .padding(.horizontal, 10).padding(.vertical, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.indigo.opacity(0.10)))
        }
    }

    // MARK: Theoretical section

    private var theoreticalSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Theoretical law").font(.headline)
                Spacer()
                Label(shape == .custom ? "drag the bars" : "drag to edit",
                      systemImage: "hand.draw")
                    .font(.caption2).foregroundStyle(.blue)
            }

            TheoreticalPMFChart(
                probabilities: probabilities,
                barFractions: barFractions,
                mean: theoreticalMean,
                editable: shape == .custom,
                onEdit: { loc, size in editBar(at: loc, in: size) },
                onEditEnd: {
                    isDragging = false
                    regeneratePool()
                }
            )
            .frame(height: 185)

            controls
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "number").font(.caption).foregroundStyle(.blue)
                Slider(value: $count, in: 2...20, step: 1).tint(.blue)
                Text("\(n)")
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .frame(width: 22, alignment: .trailing)
            }

            Picker("Probability law", selection: $shape) {
                ForEach(DistributionShape.allCases) { distribution in
                    Text(distribution.rawValue).tag(distribution)
                }
            }
            .pickerStyle(.segmented)

            if shape == .bell || shape == .decreasing {
                HStack(spacing: 10) {
                    Image(systemName: "slider.horizontal.3").font(.caption).foregroundStyle(.secondary)
                    Slider(value: $skew, in: 0...1).tint(.indigo)
                }
                Text(shape == .bell ? "Moves the peak of the bell."
                                    : "Controls the decay rate.")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
    }

    // MARK: Empirical section

    private var empiricalSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Empirical estimate").font(.headline)
            Text("Repeat the experiment and count the outcomes: X̄ₙ approaches E[X] as the number of draws grows.")
                .font(.footnote).foregroundStyle(.secondary)

            HStack(spacing: 10) {
                Image(systemName: "die.face.5").font(.caption).foregroundStyle(.orange)
                Slider(value: $draws, in: 0...Double(maxDraws), step: 10).tint(.orange)
                Text("\(usedDraws)")
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .frame(width: 34, alignment: .trailing)
                Button {
                    if draws < 1 { draws = 100 }
                    withAnimation(.easeInOut(duration: 0.4)) { regeneratePool() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            EmpiricalHistogramChart(
                counts: counts,
                total: usedDraws,
                empiricalMean: empiricalMean
            )
            .frame(height: 185)

            convergenceChart
                .frame(height: 130)

            HStack(spacing: 8) {
                statBox(title: "E[X]", value: fmt(theoreticalMean), color: .indigo)
                statBox(title: "X̄ₙ",  value: empiricalMean.map(fmt) ?? "—", color: .orange)
                statBox(title: "Gap",  value: empiricalMean.map { fmt(abs($0 - theoreticalMean)) } ?? "—", color: .gray)
            }
        }
    }

    private func statBox(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(title).font(.caption2).foregroundStyle(.secondary)
            Text(value).font(.subheadline.monospacedDigit().weight(.semibold)).foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.10)))
    }

    // MARK: Convergence chart (running mean → E[X])

    private var convergenceChart: some View {
        chartBox {
            Canvas { ctx, size in drawConvergence(ctx, size: size) }
        }
    }

    private func drawConvergence(_ ctx: GraphicsContext, size: CGSize) {
        let left: CGFloat = 30, right: CGFloat = 10, top: CGFloat = 12, bottom: CGFloat = 20
        let plotW = size.width - left - right
        let plotH = size.height - top - bottom
        guard plotW > 0, plotH > 0 else { return }

        let N = usedDraws
        let mean = theoreticalMean
        let yMin = 1.0, yMax = Double(n)

        func yPix(_ v: Double) -> CGFloat {
            let t = (v - yMin) / (yMax - yMin)
            return top + plotH * CGFloat(1 - t)
        }

        for v in [yMin, (yMin + yMax) / 2, yMax] {
            let yy = yPix(v)
            var g = Path()
            g.move(to: CGPoint(x: left, y: yy)); g.addLine(to: CGPoint(x: left + plotW, y: yy))
            ctx.stroke(g, with: .color(.secondary.opacity(0.15)), lineWidth: 1)
            ctx.draw(Text(fmt(v)).font(.system(size: 8.5)).foregroundStyle(.secondary),
                     at: CGPoint(x: left - 5, y: yy), anchor: .trailing)
        }

        let my = yPix(mean)
        var ml = Path(); ml.move(to: CGPoint(x: left, y: my)); ml.addLine(to: CGPoint(x: left + plotW, y: my))
        ctx.stroke(ml, with: .color(.indigo), style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
        ctx.draw(Text("E[X]").font(.system(size: 8.5, weight: .semibold)).foregroundStyle(.indigo),
                 at: CGPoint(x: left + plotW - 3, y: my - 7), anchor: .trailing)

        guard N >= 1 else {
            ctx.draw(Text("Increase the number of draws").font(.system(size: 10.5)).foregroundStyle(.secondary),
                     at: CGPoint(x: left + plotW / 2, y: top + plotH / 2))
            return
        }

        let prefix = Array(pool.prefix(N))
        let stride = max(1, N / 240)
        var running = 0
        var pts: [CGPoint] = []
        for k in 0..<N {
            running += prefix[k]
            if k % stride == 0 || k == N - 1 {
                let mk = Double(running) / Double(k + 1)
                let xx = left + plotW * CGFloat(Double(k) / Double(max(1, N - 1)))
                pts.append(CGPoint(x: xx, y: yPix(mk)))
            }
        }
        var poly = Path()
        if let first = pts.first { poly.move(to: first); for p in pts.dropFirst() { poly.addLine(to: p) } }
        ctx.stroke(poly, with: .color(.orange), style: StrokeStyle(lineWidth: 2, lineJoin: .round))

        ctx.draw(Text("draws: \(N)").font(.system(size: 8.5)).foregroundStyle(.secondary),
                 at: CGPoint(x: left + plotW, y: top + plotH + 9), anchor: .trailing)
    }

    // MARK: Logic

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

    private func regeneratePool() {
        syncWeights()
        let probs = probabilities
        guard probs.count == n else { pool = []; return }
        var cum: [Double] = []; var s = 0.0
        for p in probs { s += p; cum.append(s) }
        var result: [Int] = []; result.reserveCapacity(maxDraws)
        for _ in 0..<maxDraws {
            let u = Double.random(in: 0..<1)
            let idx = cum.firstIndex(where: { $0 >= u }) ?? (probs.count - 1)
            result.append(idx + 1)
        }
        pool = result
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
