//  ConvergenceView.swift
//  EPFLearn
//

import SwiftUI
import Combine


struct EpsilonBand: Shape {
    let limit:   Double
    let epsilon: Double
    let scale:   Double

    func path(in rect: CGRect) -> Path {
        let cs   = MathCoordinateSpace(rect: rect, scale: scale)
        let yTop = cs.toScreen(y: limit + epsilon)
        let yBot = cs.toScreen(y: limit - epsilon)
        var path = Path()
        path.addRect(CGRect(x: rect.minX, y: yTop, width: rect.width, height: yBot - yTop))
        return path
    }
}

struct LimitLine: Shape {
    let limit: Double
    let scale: Double

    func path(in rect: CGRect) -> Path {
        let cs = MathCoordinateSpace(rect: rect, scale: scale)
        var path = Path()
        path.move(to:    CGPoint(x: rect.minX, y: cs.toScreen(y: limit)))
        path.addLine(to: CGPoint(x: rect.maxX, y: cs.toScreen(y: limit)))
        return path
    }
}

struct CritNLine: Shape {
    let critN:  Int
    let totalN: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let x = rect.minX + CGFloat(critN - 1) / CGFloat(totalN - 1) * rect.width
        path.move(to:    CGPoint(x: x, y: rect.minY))
        path.addLine(to: CGPoint(x: x, y: rect.maxY))
        return path
    }
}

struct SuiteDefinition: Identifiable {
    let id:        Int
    let name:      String
    let f:         (Int) -> Double
    let limit:     Double
    let converges: Bool
}

private let suites: [SuiteDefinition] = [
    SuiteDefinition(id: 0, name: "1/n",       f: { 1.0 / Double($0) },                          limit: 0, converges: true),
    SuiteDefinition(id: 1, name: "(-1)ⁿ/n",   f: { ($0 % 2 == 0 ? 1.0 : -1.0) / Double($0) }, limit: 0, converges: true),
    SuiteDefinition(id: 2, name: "sin(n)/n",  f: { sin(Double($0)) / Double($0) },              limit: 0, converges: true),
    SuiteDefinition(id: 3, name: "(-1)ⁿ",     f: { $0 % 2 == 0 ? 1.0 : -1.0 },                 limit: 0, converges: false),
]

struct ConvergenceView: View {

    @State private var selectedSuite = 0
    // Linear slider position in [0, 1] — mapped to epsilon on a log scale below.
    @State private var sliderPosition: Double = 0.55

    let graphSize: CGFloat = 300
    let totalN = 40
    let scale: Double = 120.0

    // Log-scale mapping: epsilon ranges from epsMin to epsMax,
    // but small epsilon values get proportionally more slider room.
    let epsMin = 0.01
    let epsMax = 1.2

    var epsilon: Double {
        exp(log(epsMin) + sliderPosition * (log(epsMax) - log(epsMin)))
    }

    var suite: SuiteDefinition { suites[selectedSuite] }

    func xScreen(_ n: Int) -> CGFloat {
        CGFloat(n - 1) / CGFloat(totalN - 1) * graphSize
    }

    var critN: Int? {
        guard suite.converges else { return nil }
        var n = totalN
        while n >= 1 {
            if abs(suite.f(n) - suite.limit) >= epsilon { return n < totalN ? n + 1 : nil }
            n -= 1
        }
        return 1
    }

    var divergentAllIn: Bool {
        guard !suite.converges else { return false }
        return (1...totalN).allSatisfy { abs(suite.f($0) - suite.limit) < epsilon }
    }

    var body: some View {
        let cs = MathCoordinateSpace(size: graphSize, scale: scale)

        VStack(spacing: 14) {

            Text("uₙ = \(suite.name)")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundStyle(.secondary)

            Picker("Sequence", selection: $selectedSuite) {
                ForEach(suites) { s in
                    Text(s.name).tag(s.id)
                }
            }
            .pickerStyle(.menu)
            .frame(width: graphSize)

            ZStack {
                GridDrawing(step: 10)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal)
                    .stroke(Color.blue.opacity(0.7), lineWidth: 1.5)
                AxisDrawing(axis: .vertical)
                    .stroke(Color.blue.opacity(0.7), lineWidth: 1.5)

                let bandColor: Color = suite.converges ? .green : .red
                EpsilonBand(limit: suite.limit, epsilon: epsilon, scale: scale)
                    .fill(bandColor.opacity(0.10))
                EpsilonBand(limit: suite.limit, epsilon: epsilon, scale: scale)
                    .stroke(bandColor.opacity(0.7), style: StrokeStyle(lineWidth: 1, dash: [5, 3]))

                LimitLine(limit: suite.limit, scale: scale)
                    .stroke(Color.secondary.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [3, 4]))

                if let cn = critN {
                    CritNLine(critN: cn, totalN: totalN)
                        .stroke(Color.orange.opacity(0.7), style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                }

                Path { path in
                    for n in 1...totalN {
                        let pt = CGPoint(x: xScreen(n), y: cs.toScreen(y: suite.f(n)))
                        n == 1 ? path.move(to: pt) : path.addLine(to: pt)
                    }
                }
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)

                ForEach(1...totalN, id: \.self) { n in
                    let inside = abs(suite.f(n) - suite.limit) < epsilon
                    let isCrit = critN == n
                    Circle()
                        .fill(inside ? Color.green : Color.red)
                        .frame(width: isCrit ? 12 : 8, height: isCrit ? 12 : 8)
                        .overlay(isCrit ? Circle().stroke(Color.orange, lineWidth: 2) : nil)
                        .position(x: xScreen(n), y: cs.toScreen(y: suite.f(n)))
                }

                if let cn = critN {
                    Text("N=\(cn)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.orange)
                        .position(x: xScreen(cn), y: 12)
                }

                let labelColor: Color = suite.converges ? .green : .red
                Text(suite.converges ? "L+ε" : "0+ε")
                    .font(.system(size: 10)).foregroundStyle(labelColor)
                    .position(x: 22, y: cs.toScreen(y: suite.limit + epsilon) - 8)
                Text(suite.converges ? "L−ε" : "0−ε")
                    .font(.system(size: 10)).foregroundStyle(labelColor)
                    .position(x: 22, y: cs.toScreen(y: suite.limit - epsilon) + 10)
                Text(suite.converges ? "L" : "0")
                    .font(.system(size: 10)).foregroundStyle(.secondary)
                    .position(x: 10, y: cs.toScreen(y: suite.limit) - 8)
            }
            .frame(width: graphSize, height: graphSize)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .drawingGroup()

            HStack {
                Text("ε = \(epsilon, specifier: "%.3f")")
                    .font(.system(size: 13, design: .monospaced))
                    .frame(width: 80, alignment: .leading)
                Slider(value: $sliderPosition, in: 0...1)
            }

            Group {
                if !suite.converges {
                    if divergentAllIn {
                        Text("ε ≥ 1: the band captures everything, but this would work for any \"limit\"")
                            .font(.system(size: 12)).foregroundStyle(.secondary)
                    } else {
                        Text("Some terms are always outside the band, no N works")
                            .font(.system(size: 12)).foregroundStyle(.red.opacity(0.8))
                    }
                } else if let cn = critN {
                    HStack(spacing: 8) {
                        Text("N = \(cn)")
                            .font(.system(size: 13, weight: .medium))
                            .padding(.horizontal, 10).padding(.vertical, 3)
                            .background(Color.green.opacity(0.12))
                            .foregroundStyle(.green)
                            .clipShape(Capsule())
                        Text("∀n ≥ \(cn),  |uₙ − L| < ε")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("Rank N not visible, increase ε")
                        .font(.system(size: 12)).foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }
}

#Preview {
    ConvergenceView()
        .preferredColorScheme(.dark)
}
