import SwiftUI

// MARK: - Distribution model

/// Discrete-law families offered to the user.
enum DistributionShape: String, CaseIterable, Identifiable {
    case uniform    = "Uniform"
    case bell       = "Bell"
    case decreasing = "Decreasing"
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
private let kLeft: CGFloat = 14, kRight: CGFloat = 14, kTop: CGFloat = 26, kBottom: CGFloat = 42

private func xForValue(_ v: Double, count n: Int, width: CGFloat) -> CGFloat {
    let plotW = width - kLeft - kRight
    let slot = plotW / CGFloat(max(n, 1))
    return kLeft + (CGFloat(v) - 0.5) * slot
}

private func chartBox<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
    content()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.primary.opacity(0.06)))
}

// MARK: - Independent view 1: theoretical PMF

/// Pure theoretical chart: blue probability bars + indigo E[X] balance point.
struct TheoreticalPMFChart: View {
    let probabilities: [Double]
    let mean: Double
    let editable: Bool
    let onEdit: (CGPoint, CGSize) -> Void

    private var n: Int { probabilities.count }

    var body: some View {
        chartBox {
            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    Canvas { ctx, size in draw(ctx, size: size) }
                    if editable {
                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { v in onEdit(v.location, geo.size) }
                            )
                    }
                }
            }
        }
    }

    private func draw(_ ctx: GraphicsContext, size: CGSize) {
        let plotW = size.width - kLeft - kRight
        let plotH = size.height - kTop - kBottom
        guard plotW > 0, plotH > 0, n > 0 else { return }

        let slot  = plotW / CGFloat(n)
        let maxP  = max(probabilities.max() ?? 1, 0.0001)
        let axisY = kTop + plotH

        var axis = Path()
        axis.move(to: CGPoint(x: kLeft, y: axisY))
        axis.addLine(to: CGPoint(x: kLeft + plotW, y: axisY))
        ctx.stroke(axis, with: .color(.secondary.opacity(0.35)), lineWidth: 1)

        for i in 0..<n {
            let p = probabilities[i]
            let cx = kLeft + (CGFloat(i) + 0.5) * slot
            let barW = slot * 0.6
            let h = CGFloat(p / maxP) * plotH * 0.92
            if h > 0.5 {
                let r = CGRect(x: cx - barW / 2, y: axisY - h, width: barW, height: h)
                ctx.fill(Path(roundedRect: r, cornerSize: CGSize(width: 4, height: 4)),
                         with: .linearGradient(
                            Gradient(colors: [Color.blue.opacity(0.9), Color.blue.opacity(0.35)]),
                            startPoint: CGPoint(x: cx, y: axisY - h),
                            endPoint: CGPoint(x: cx, y: axisY)))
            }
            if n <= 15 {
                ctx.draw(Text("\(i + 1)").font(.system(size: 10)).foregroundStyle(.secondary),
                         at: CGPoint(x: cx, y: axisY + 12))
            }
            if n <= 10 {
                let pct = p >= 0.1 ? "\(Int((p * 100).rounded()))%" : String(format: "%.1f%%", p * 100)
                ctx.draw(Text(pct).font(.system(size: 9, weight: .medium)).foregroundStyle(.blue),
                         at: CGPoint(x: cx, y: axisY - h - 8))
            }
        }

        // E[X]: line + balance-point triangle
        let mx = kLeft + (CGFloat(mean) - 0.5) * slot
        var line = Path()
        line.move(to: CGPoint(x: mx, y: kTop + 4))
        line.addLine(to: CGPoint(x: mx, y: axisY))
        ctx.stroke(line, with: .color(.indigo), style: StrokeStyle(lineWidth: 2))

        var tri = Path()
        let tw: CGFloat = 9
        tri.move(to: CGPoint(x: mx, y: axisY + 2))
        tri.addLine(to: CGPoint(x: mx - tw, y: axisY + 14))
        tri.addLine(to: CGPoint(x: mx + tw, y: axisY + 14))
        tri.closeSubpath()
        ctx.fill(tri, with: .color(.indigo))

        // Keep the label pinned to the top edge, clear of the bars.
        ctx.draw(Text("E[X] = \(String(format: "%.2f", mean))")
                    .font(.system(size: 11, weight: .semibold)).foregroundStyle(.indigo),
                 at: CGPoint(x: min(max(mx, 34), size.width - 34), y: 11))
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
                                .frame(width: 2, height: max(0, plotH - 6))
                                .position(x: mx, y: kTop + 6 + max(0, plotH - 6) / 2)
                            Diamond()
                                .fill(Color.orange)
                                .frame(width: 11, height: 11)
                                .position(x: mx, y: kTop + plotH)
                            Text("X̄ₙ = \(String(format: "%.2f", em))")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.orange)
                                .position(x: min(max(mx, 40), geo.size.width - 40), y: 11)
                        }
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                        .allowsHitTesting(false)
                        .animation(.easeInOut(duration: 0.45), value: empiricalMean)
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
                        .font(.system(size: 12)).foregroundStyle(.secondary),
                     at: CGPoint(x: size.width / 2, y: kTop + plotH / 2))
            return
        }

        let slot = plotW / CGFloat(n)
        let maxC = max(counts.max() ?? 1, 1)

        for i in 0..<n {
            let c = counts[i]
            let cx = kLeft + (CGFloat(i) + 0.5) * slot
            let barW = slot * 0.6
            let h = CGFloat(Double(c) / Double(maxC)) * plotH * 0.92
            if h > 0.5 {
                let r = CGRect(x: cx - barW / 2, y: axisY - h, width: barW, height: h)
                ctx.fill(Path(roundedRect: r, cornerSize: CGSize(width: 4, height: 4)),
                         with: .linearGradient(
                            Gradient(colors: [Color.orange.opacity(0.9), Color.orange.opacity(0.35)]),
                            startPoint: CGPoint(x: cx, y: axisY - h),
                            endPoint: CGPoint(x: cx, y: axisY)))
            }
            if n <= 15 {
                ctx.draw(Text("\(i + 1)").font(.system(size: 10)).foregroundStyle(.secondary),
                         at: CGPoint(x: cx, y: axisY + 12))
            }
            if n <= 10 && c > 0 {
                ctx.draw(Text("\(c)").font(.system(size: 9, weight: .medium)).foregroundStyle(.orange),
                         at: CGPoint(x: cx, y: axisY - h - 8))
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

    @State private var count: Double = 6           // number of values (slider 2…20)
    @State private var shape: DistributionShape = .bell
    @State private var skew: Double = 0.5          // law shape 0…1
    @State private var rawWeights: [Double] = []   // "Free" mode (draggable bars)

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
            VStack(alignment: .leading, spacing: 24) {
                intro
                theoreticalSection
                Divider()
                empiricalSection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear(perform: regeneratePool)
        .onChange(of: count) { _, _ in regeneratePool() }
        .onChange(of: skew)  { _, _ in regeneratePool() }
        .onChange(of: shape) { oldValue, newValue in
            if newValue == .custom { rawWeights = weights(for: oldValue) }
            regeneratePool()
        }
        .onChange(of: rawWeights) { _, _ in regeneratePool() }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Expectation").font(.largeTitle.bold())
            Text("The expectation E[X] is the average of the values weighted by their probabilities: it is the balance point of the distribution.")
                .font(.callout).foregroundStyle(.secondary)
            Text("E[X] = Σ xᵢ · P(X = xᵢ)")
                .font(.system(.callout, design: .monospaced))
                .padding(.horizontal, 12).padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.indigo.opacity(0.10)))
        }
    }

    // MARK: Theoretical section

    private var theoreticalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Theoretical law").font(.headline)

            TheoreticalPMFChart(
                probabilities: probabilities,
                mean: theoreticalMean,
                editable: shape == .custom
            ) { loc, size in
                editBar(at: loc, in: size)
            }
            .frame(height: 240)

            Text("Blue bars: P(X = i).  Indigo line: E[X], the balance point.")
                .font(.caption).foregroundStyle(.secondary)

            controls
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Label("Number of values", systemImage: "number")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text("\(n)")
                        .font(.subheadline.monospacedDigit().weight(.semibold))
                        .padding(.horizontal, 10).padding(.vertical, 3)
                        .background(Capsule().fill(Color.blue.opacity(0.15)))
                        .foregroundStyle(.blue)
                }
                Slider(value: $count, in: 2...20, step: 1).tint(.blue)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Probability law").font(.subheadline.weight(.medium))
                Picker("Law", selection: $shape) {
                    ForEach(DistributionShape.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)

                if shape == .bell || shape == .decreasing {
                    HStack(spacing: 10) {
                        Image(systemName: "slider.horizontal.3").foregroundStyle(.secondary)
                        Slider(value: $skew, in: 0...1).tint(.indigo)
                    }
                    Text(shape == .bell ? "Moves the peak of the bell left or right."
                                        : "Controls the decay rate.")
                        .font(.caption).foregroundStyle(.secondary)
                } else if shape == .custom {
                    Text("Drag the bars on the chart above to set each probability.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: Empirical section

    private var empiricalSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Empirical estimate").font(.headline)
            Text("Repeat the experiment many times and count the outcomes. The histogram's balance point X̄ₙ approaches E[X] as the number of draws grows (law of large numbers).")
                .font(.callout).foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Label("Draws", systemImage: "die.face.5")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text("\(usedDraws)")
                        .font(.subheadline.monospacedDigit().weight(.semibold))
                        .padding(.horizontal, 10).padding(.vertical, 3)
                        .background(Capsule().fill(Color.orange.opacity(0.18)))
                        .foregroundStyle(.orange)
                }
                Slider(value: $draws, in: 0...Double(maxDraws), step: 1).tint(.orange)
            }

            Button {
                if draws < 1 { draws = 100 }
                withAnimation(.easeInOut(duration: 0.45)) { regeneratePool() }
            } label: {
                Label("Resample", systemImage: "die.face.5.fill")
            }
            .buttonStyle(.bordered)

            EmpiricalHistogramChart(
                counts: counts,
                total: usedDraws,
                empiricalMean: empiricalMean
            )
            .frame(height: 240)

            Text("Orange bars: observed counts.  Orange marker: X̄ₙ, the empirical mean.")
                .font(.caption).foregroundStyle(.secondary)

            convergenceChart
                .frame(height: 170)

            HStack(spacing: 12) {
                statBox(title: "E[X]", value: fmt(theoreticalMean), color: .indigo)
                statBox(title: "X̄ₙ",  value: empiricalMean.map(fmt) ?? "—", color: .orange)
                statBox(title: "Gap",  value: empiricalMean.map { fmt(abs($0 - theoreticalMean)) } ?? "—", color: .gray)
            }
        }
    }

    private func statBox(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.title3.monospacedDigit().weight(.semibold)).foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 12).fill(color.opacity(0.10)))
    }

    // MARK: Convergence chart (running mean → E[X])

    private var convergenceChart: some View {
        chartBox {
            Canvas { ctx, size in drawConvergence(ctx, size: size) }
        }
    }

    private func drawConvergence(_ ctx: GraphicsContext, size: CGSize) {
        let left: CGFloat = 34, right: CGFloat = 12, top: CGFloat = 14, bottom: CGFloat = 26
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
            ctx.draw(Text(fmt(v)).font(.system(size: 9)).foregroundStyle(.secondary),
                     at: CGPoint(x: left - 6, y: yy), anchor: .trailing)
        }

        let my = yPix(mean)
        var ml = Path(); ml.move(to: CGPoint(x: left, y: my)); ml.addLine(to: CGPoint(x: left + plotW, y: my))
        ctx.stroke(ml, with: .color(.indigo), style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
        ctx.draw(Text("E[X]").font(.system(size: 9, weight: .semibold)).foregroundStyle(.indigo),
                 at: CGPoint(x: left + plotW - 4, y: my - 8), anchor: .trailing)

        guard N >= 1 else {
            ctx.draw(Text("Increase the number of draws").font(.system(size: 11)).foregroundStyle(.secondary),
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

        ctx.draw(Text("1").font(.system(size: 9)).foregroundStyle(.secondary),
                 at: CGPoint(x: left, y: top + plotH + 12), anchor: .leading)
        ctx.draw(Text("draws: \(N)").font(.system(size: 9)).foregroundStyle(.secondary),
                 at: CGPoint(x: left + plotW, y: top + plotH + 12), anchor: .trailing)
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

    private func fmt(_ v: Double) -> String { String(format: "%.2f", v) }

    private func syncWeights() {
        if rawWeights.count != n { rawWeights = Array(repeating: 1, count: n) }
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
        let idx   = Int((loc.x - kLeft) / slot)
        guard idx >= 0, idx < n else { return }
        syncWeights()
        let h = max(0, min(plotH, axisY - loc.y))
        rawWeights[idx] = Double(h / plotH) + 0.001
    }
}

#Preview {
    ExpectationView()
}
