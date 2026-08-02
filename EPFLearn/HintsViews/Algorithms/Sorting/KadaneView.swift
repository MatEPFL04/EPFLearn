//
//  KadaneView.swift
//  EPFLearn
//
//  Created by Mat on 28.06.2026.
//

import SwiftUI


struct KadaneFrame {
    var array: [Int]
    var lo: Int          // fenêtre courante
    var hi: Int
    var pivot: Int       // élément examiné
    var curSum: Int      // somme de la fenêtre courante
    var bestSum: Int     // meilleure somme trouvée
    var bestLo: Int      // meilleur sous-tableau
    var bestHi: Int
}

enum Kadane {
    static func run(_ input: [Int]) -> [KadaneFrame] {
        let a = input
        var frames: [KadaneFrame] = []
        guard !a.isEmpty else { return frames }

        var curLo = 0, curSum = 0
        var bestLo = 0, bestHi = 0, bestSum = a[0]
        var started = false

        frames.append(KadaneFrame(array: a, lo: 0, hi: -1, pivot: -1,
                                  curSum: 0, bestSum: a[0], bestLo: -1, bestHi: -1))

        for j in a.indices {
            if curSum <= 0 {
                curLo = j
                curSum = a[j]          // on repart de zéro
            } else {
                curSum += a[j]         // on prolonge
            }

            if !started || curSum > bestSum {
                bestSum = curSum
                bestLo = curLo
                bestHi = j
                started = true
            }

            frames.append(KadaneFrame(array: a, lo: curLo, hi: j, pivot: j,
                                      curSum: curSum, bestSum: bestSum,
                                      bestLo: bestLo, bestHi: bestHi))
        }
        return frames
    }
}

// Rendu avec baseline AU MILIEU : les valeurs négatives descendent sous l'axe.
struct KadaneBars: View {
    let frame: KadaneFrame

    var body: some View {
        Canvas { ctx, size in
            let a = frame.array
            guard !a.isEmpty else { return }
            let maxAbs = CGFloat(a.map { abs($0) }.max() ?? 1)
            let scale = maxAbs == 0 ? 1 : (size.height / 2 - 10) / maxAbs
            let delta = size.width / CGFloat(a.count)
            let baseline = size.height / 2

            var axis = Path()
            axis.move(to: CGPoint(x: 0, y: baseline))
            axis.addLine(to: CGPoint(x: size.width, y: baseline))
            ctx.stroke(axis, with: .color(.primary.opacity(0.2)), lineWidth: 1)

            for (i, elm) in a.enumerated() {
                let x = delta * (CGFloat(i) + 0.5)
                let top = baseline - CGFloat(elm) * scale
                var p = Path()
                p.move(to: CGPoint(x: x, y: baseline))
                p.addLine(to: CGPoint(x: x, y: top))

                let inBest = frame.bestLo >= 0 && i >= frame.bestLo && i <= frame.bestHi
                let inCur  = i >= frame.lo && i <= frame.hi
                let color: Color =
                    i == frame.pivot ? .orange :
                    inBest           ? .green  :
                    inCur            ? .blue   :
                    .gray.opacity(0.3)

                ctx.stroke(p, with: .color(color.opacity(0.5)), lineWidth: max(3, delta + 2))
                ctx.stroke(p, with: .color(color), lineWidth: max(1, delta - 1.5))
            }
        }
    }
}

struct KadaneView: View {

    enum Shape: String, CaseIterable {
        case random    = "Random"
        case allNeg    = "All negative"
        case allPos    = "All positive"
        case oneSpike  = "One spike"
        case twoBlocks = "Two blocks"
    }

    @State private var array: [Int] = []
    @State private var frames: [KadaneFrame] = []
    @State private var step: Double = 0
    @State private var shape: Shape = .random
    @State private var n: Int = 20
    @State private var offset: Double = 0

    static func makeArray(n: Int, shape: Shape) -> [Int] {
        switch shape {
        case .random:
            return (0..<n).map { _ in Bool.random() ? Int.random(in: -9 ... -1) : Int.random(in: 1...9) }
        case .allNeg:
            return (0..<n).map { _ in Int.random(in: -9 ... -1) }
        case .allPos:
            return (0..<n).map { _ in Int.random(in: 1...9) }
        case .oneSpike:
            var a = (0..<n).map { _ in Int.random(in: -9 ... -2) }
            a[n/2] = 20
            return a
        case .twoBlocks:
            return (0..<n).map { i in
                if i < n/3 { return Int.random(in: 2...9) }
                else if i < 2*n/3 { return Int.random(in: -9 ... -3) }
                else { return Int.random(in: 2...9) }
            }
        }
    }

    private var maxStep: Int { max(0, frames.count - 1) }
    private var frame: KadaneFrame {
        frames.isEmpty
            ? KadaneFrame(array: array, lo: 0, hi: -1, pivot: -1,
                          curSum: 0, bestSum: 0, bestLo: -1, bestHi: -1)
            : frames[min(Int(step), frames.count - 1)]
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Kadane").font(.caption).bold()
                Spacer()
                Text("sum: \(frame.curSum)   best: \(frame.bestSum)")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }

            KadaneBars(frame: frame)
                .frame(height: 200)
                .padding(.vertical, 6)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.gray.opacity(0.2)))

            if maxStep > 0 {
                VStack(spacing: 4) {
                    Slider(value: $step, in: 0...Double(maxStep), step: 1)
                    Text("Step \(Int(step)) / \(maxStep)")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 12) {
                Button("New") { reset() }.buttonStyle(.bordered)
                Button("Run") { run() }.buttonStyle(.borderedProminent)
            }

            Picker("Shape", selection: $shape) {
                ForEach(Shape.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.menu)
            .onChange(of: shape) { reset() }

            Text("Elements: \(n)")
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.secondary)
            Slider(
                value: Binding(get: { Double(n) }, set: { n = Int($0) }),
                in: 5...50, step: 1
            )
            .onChange(of: n) { reset() }
            if shape == .random {
                Text("Offset C: \(Int(offset))")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                Slider(value: $offset, in: -10...10, step: 1)
                    .onChange(of: offset) {
                        array = array.map { $0 + Int(offset) }
                        frames = []     
                        step = 0
                    }
            }
        }
        .padding()
        .onAppear { if array.isEmpty { reset() } }
    }

    private func run() {
        frames = Kadane.run(array)
        step = 0
    }

    private func reset() {
        array = Self.makeArray(n: n, shape: shape)
        frames = []
        step = 0
    }
}

#Preview {
    KadaneView().preferredColorScheme(.dark)
}
