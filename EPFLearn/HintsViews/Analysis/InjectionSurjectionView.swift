//
//  InjectionSurjectionView.swift
//  EPFLearn
//

import SwiftUI

// MARK: - Model

private struct MapCase: Identifiable {
    let id: Int
    let chip: String              // wheel label
    let formula: String
    let domainLabel: String
    let codomainLabel: String
    let f: (Double) -> Double
    let domain: ClosedRange<Double>     // domain (bounded for display)
    let codomain: ClosedRange<Double>   // codomain
    let injective: Bool
    let surjective: Bool
}

private let mapCases: [MapCase] = [
    MapCase(id: 0, chip: "x²  on ℝ", formula: "f(x) = x²",
            domainLabel: "ℝ", codomainLabel: "ℝ",
            f: { $0 * $0 }, domain: -4...4, codomain: -4...4,
            injective: false, surjective: false),

    MapCase(id: 1, chip: "x²  on ℝ₊", formula: "f(x) = x²",
            domainLabel: "ℝ₊", codomainLabel: "ℝ₊",
            f: { $0 * $0 }, domain: 0...4, codomain: 0...4,
            injective: true, surjective: true),

    MapCase(id: 2, chip: "x³", formula: "f(x) = x³",
            domainLabel: "ℝ", codomainLabel: "ℝ",
            f: { $0 * $0 * $0 }, domain: -4...4, codomain: -4...4,
            injective: true, surjective: true),

    MapCase(id: 3, chip: "eˣ", formula: "f(x) = eˣ",
            domainLabel: "ℝ", codomainLabel: "ℝ",
            f: { exp($0) }, domain: -4...4, codomain: -4...4,
            injective: true, surjective: false),

    MapCase(id: 4, chip: "x³ − 3x", formula: "f(x) = x³ − 3x",
            domainLabel: "ℝ", codomainLabel: "ℝ",
            f: { $0 * $0 * $0 - 3 * $0 }, domain: -4...4, codomain: -4...4,
            injective: false, surjective: true),

    MapCase(id: 5, chip: "sin(x)", formula: "f(x) = sin(x)",
            domainLabel: "ℝ", codomainLabel: "[−1, 1]",
            f: { sin($0) }, domain: -4...4, codomain: -1...1,
            injective: false, surjective: true),
]

// MARK: - View

struct InjectionSurjectionView: View {

    @State private var selectedCase: Int = 0
    @State private var level: Double = 1.0        // height of the horizontal line

    @State private var graphSize: CGFloat = 300

    private let baseScale: Double = 36
    private var scale: Double { baseScale * Double(graphSize) / 300 }

    private var current: MapCase { mapCases[selectedCase] }
    private var cs: MathCoordinateSpace { MathCoordinateSpace(size: graphSize, scale: scale) }

    // MARK: Preimages of `level` - sweep + bisection on sign changes

    private func preimages(of y: Double, in c: MapCase) -> [Double] {
        let lo = c.domain.lowerBound, hi = c.domain.upperBound
        let steps = 1200
        let dx = (hi - lo) / Double(steps)
        var roots: [Double] = []
        var xPrev = lo
        var vPrev = c.f(lo) - y
        if abs(vPrev) < 1e-9 { roots.append(lo) }

        for i in 1...steps {
            let x = lo + dx * Double(i)
            let v = c.f(x) - y
            if vPrev == 0 || v == 0 || vPrev * v < 0 {
                var a = xPrev, b = x, fa = vPrev
                for _ in 0..<40 {
                    let m = (a + b) / 2
                    let fm = c.f(m) - y
                    if fa * fm <= 0 { b = m } else { a = m; fa = fm }
                }
                let root = (a + b) / 2
                if !roots.contains(where: { abs($0 - root) < 1e-4 }) { roots.append(root) }
            }
            xPrev = x; vPrev = v
        }
        return roots
    }

    private var roots: [Double] { preimages(of: level, in: current) }

    private var verdict: (text: String, color: Color, icon: String) {
        switch roots.count {
        case 0:  return ("0 preimage → surjectivity fails here", .orange, "exclamationmark.triangle.fill")
        case 1:  return ("1 preimage → this y is fine", .green, "checkmark.circle.fill")
        default: return ("\(roots.count) preimages → injectivity fails here", .red, "xmark.circle.fill")
        }
    }

    /// Sampled image of f - used to paint the codomain ruler.
    private var imageSet: [(Double, Double)] {
        var ys: [Double] = []
        let lo = current.domain.lowerBound, hi = current.domain.upperBound
        for i in 0...400 {
            ys.append(current.f(lo + (hi - lo) * Double(i) / 400))
        }
        var segments: [(Double, Double)] = []
        var startY = ys[0], prevY = ys[0]
        var increasing = true
        for y in ys.dropFirst() {
            let nowIncreasing = y >= prevY
            if nowIncreasing != increasing {
                segments.append((min(startY, prevY), max(startY, prevY)))
                startY = prevY
                increasing = nowIncreasing
            }
            prevY = y
        }
        segments.append((min(startY, prevY), max(startY, prevY)))
        return segments
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: 10) {

            Text("Injectivity & Surjectivity").font(.headline)

            Text("\(current.formula),   \(current.domainLabel) → \(current.codomainLabel)")
                .font(.system(size: 14, weight: .medium, design: .monospaced))

            ZStack {
                GridDrawing(step: CGFloat(scale) / 2)
                    .stroke(Color.blue.opacity(0.18), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal).stroke(Color.blue.opacity(0.6), lineWidth: 1)
                AxisDrawing(axis: .vertical).stroke(Color.blue.opacity(0.6), lineWidth: 1)

                // Codomain on the left edge: green = hit, red = gap.
                codomainRuler

                // Domain on the bottom edge.
                Path { p in
                    let a = cs.toScreen(x: current.domain.lowerBound, y: 0)
                    let b = cs.toScreen(x: current.domain.upperBound, y: 0)
                    p.move(to: CGPoint(x: a.x, y: graphSize - 6))
                    p.addLine(to: CGPoint(x: b.x, y: graphSize - 6))
                }
                .stroke(Color.purple.opacity(0.7), style: StrokeStyle(lineWidth: 4, lineCap: .round))

                // Graph, restricted to the domain
                Path { p in
                    let lo = current.domain.lowerBound, hi = current.domain.upperBound
                    var started = false
                    for i in 0...600 {
                        let x = lo + (hi - lo) * Double(i) / 600
                        let y = current.f(x)
                        guard abs(y) < 6 else { started = false; continue }
                        let pt = cs.toScreen(x: x, y: y)
                        if started { p.addLine(to: pt) } else { p.move(to: pt); started = true }
                    }
                }
                .stroke(Color.accentColor, lineWidth: 2.5)

                // Horizontal line y = level
                Path { p in
                    let yS = cs.toScreen(x: 0, y: level).y
                    p.move(to: CGPoint(x: 0, y: yS))
                    p.addLine(to: CGPoint(x: graphSize, y: yS))
                }
                .stroke(verdict.color.opacity(0.9), style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))

                // Intersections + drop lines down to the x-axis (the preimages)
                ForEach(Array(roots.enumerated()), id: \.offset) { _, r in
                    let pt = cs.toScreen(x: r, y: level)
                    Path { p in
                        p.move(to: pt)
                        p.addLine(to: CGPoint(x: pt.x, y: cs.toScreen(x: 0, y: 0).y))
                    }
                    .stroke(verdict.color.opacity(0.45), style: StrokeStyle(lineWidth: 1, dash: [2, 3]))

                    Circle()
                        .fill(verdict.color)
                        .frame(width: 9, height: 9)
                        .position(pt)
                }
            }
            .frame(width: graphSize, height: graphSize)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Picker("Function", selection: $selectedCase) {
                ForEach(mapCases) { c in
                    Text(c.chip).tag(c.id)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(width: graphSize)

            VStack(alignment: .leading, spacing: 4) {
                Text("y = \(level, specifier: "%.2f")")
                    .font(.caption).foregroundStyle(.secondary)
                Slider(value: $level,
                       in: current.codomain.lowerBound...current.codomain.upperBound)
            }
            .frame(width: graphSize - 40)

            HStack(spacing: 5) {
                Image(systemName: verdict.icon)
                    .font(.system(size: 11))
                    .foregroundStyle(verdict.color)
                Text(verdict.text)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(verdict.color)
            }
            .frame(width: graphSize)

            HStack(spacing: 8) {
                badge("Injective", current.injective)
                badge("Surjective", current.surjective)
                badge("Bijective", current.injective && current.surjective)
            }
            .frame(width: graphSize)
        }
        .padding()
        .adaptivePlot($graphSize)
        .animation(.easeInOut(duration: 0.25), value: selectedCase)
        .onChange(of: selectedCase) { _, _ in
            // Keep the horizontal line inside the new codomain.
            level = min(max(level, current.codomain.lowerBound), current.codomain.upperBound)
        }
    }

    /// Vertical bar on the left: the codomain, painted according to the image of f.
    private var codomainRuler: some View {
        Canvas { ctx, _ in
            let steps = 120
            let lo = current.codomain.lowerBound, hi = current.codomain.upperBound
            let segs = imageSet
            for i in 0..<steps {
                let y = lo + (hi - lo) * Double(i) / Double(steps)
                let yNext = lo + (hi - lo) * Double(i + 1) / Double(steps)
                let reached = segs.contains { y >= $0.0 - 1e-6 && y <= $0.1 + 1e-6 }
                var p = Path()
                p.move(to: CGPoint(x: 6, y: cs.toScreen(x: 0, y: y).y))
                p.addLine(to: CGPoint(x: 6, y: cs.toScreen(x: 0, y: yNext).y))
                ctx.stroke(p,
                           with: .color(reached ? .green.opacity(0.85) : .red.opacity(0.7)),
                           style: StrokeStyle(lineWidth: 4))
            }
        }
    }

    private func badge(_ label: String, _ ok: Bool) -> some View {
        HStack(spacing: 3) {
            Image(systemName: ok ? "checkmark" : "xmark")
                .font(.system(size: 9, weight: .bold))
            Text(label).font(.system(size: 10, weight: .medium))
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background((ok ? Color.green : Color.red).opacity(0.15))
        .foregroundStyle(ok ? Color.green : Color.red)
        .clipShape(Capsule())
    }
}

#Preview {
    ScrollView { InjectionSurjectionView() }
}
