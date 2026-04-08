//
//  ConvergenceView.swift
//  EPFLearn
//
//  Created by Mat on 07.04.2026.
//

import SwiftUI

// MARK: - Shapes

struct EpsilonBand: Shape {
    let limitScreen: Double
    let epsilonScreen: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let yTop = -(limitScreen + epsilonScreen) + rect.height / 2
        let yBot = -(limitScreen - epsilonScreen) + rect.height / 2
        path.addRect(CGRect(x: rect.minX, y: yTop, width: rect.width, height: yBot - yTop))
        return path
    }
}

struct LimitLine: Shape {
    let limitScreen: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let y = -limitScreen + rect.height / 2
        path.move(to: CGPoint(x: rect.minX, y: y))
        path.addLine(to: CGPoint(x: rect.maxX, y: y))
        return path
    }
}

struct CritNLine: Shape {
    let critN: Int
    let totalN: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let x = rect.minX + CGFloat(critN - 1) / CGFloat(totalN - 1) * rect.width
        path.move(to: CGPoint(x: x, y: rect.minY))
        path.addLine(to: CGPoint(x: x, y: rect.maxY))
        return path
    }
}

// MARK: - Suites

struct SuiteDefinition: Identifiable {
    let id: Int
    let name: String
    let f: (Int) -> Double
    let limit: Double       // vraie limite si converges, centre de bande sinon
    let converges: Bool
}

private let suites: [SuiteDefinition] = [
    SuiteDefinition(id: 0, name: "1/n",           f: { 1.0 / Double($0) },                              limit: 0, converges: true),
    SuiteDefinition(id: 1, name: "(-1)ⁿ/n",       f: { ($0 % 2 == 0 ? 1.0 : -1.0) / Double($0) },     limit: 0, converges: true),
    SuiteDefinition(id: 2, name: "sin(n)/n",       f: { sin(Double($0)) / Double($0) },                 limit: 0, converges: true),
    SuiteDefinition(id: 3, name: "2ⁿ/(2ⁿ+1)",     f: { let p = pow(2.0, Double($0)); return p/(p+1) }, limit: 1, converges: true),
    SuiteDefinition(id: 4, name: "(n²+1)/(n²+n)", f: { let n = Double($0); return (n*n+1)/(n*n+n) },   limit: 1, converges: true),
    SuiteDefinition(id: 5, name: "(-1)ⁿ",         f: { $0 % 2 == 0 ? 1.0 : -1.0 },                    limit: 0, converges: false),
]

// MARK: - View

struct ConvergenceView: View {

    @State private var selectedSuite = 0
    @State private var epsilon: Double = 0.25

    let graphSize: CGFloat = 300
    let totalN = 40
    let scale: Double = 120.0

    var suite: SuiteDefinition { suites[selectedSuite] }

    func xScreen(_ n: Int) -> CGFloat {
        CGFloat(n - 1) / CGFloat(totalN - 1) * graphSize
    }

    func yScreen(_ v: Double) -> CGFloat {
        CGFloat(-v * scale) + graphSize / 2
    }

    // Rang critique : seulement si la suite converge vraiment
    var critN: Int? {
        guard suite.converges else { return nil }
        let L = suite.limit
        for n in 1...totalN {
            if (n...totalN).allSatisfy({ abs(suite.f($0) - L) < epsilon }) { return n }
        }
        return nil
    }

    // Pour une suite divergente : est-ce que TOUS les termes visibles sont dans la bande ?
    // (pour montrer visuellement que ce n'est jamais le cas pour ε < 1)
    var divergentAllIn: Bool {
        guard !suite.converges else { return false }
        return (1...totalN).allSatisfy { abs(suite.f($0) - suite.limit) < epsilon }
    }

    var body: some View {
        VStack(spacing: 14) {

            Picker("Suite", selection: $selectedSuite) {
                ForEach(suites) { s in Text(s.name).tag(s.id) }
            }
            .pickerStyle(.segmented)

            ZStack {
                GridDrawing(step: 10)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal)
                    .stroke(Color.blue.opacity(0.7), lineWidth: 1.5)
                AxisDrawing(axis: .vertical)
                    .stroke(Color.blue.opacity(0.7), lineWidth: 1.5)

                // Bande ε — toujours affichée
                let bandColor: Color = suite.converges ? .green : .red
                EpsilonBand(limitScreen: suite.limit * scale, epsilonScreen: epsilon * scale)
                    .fill(bandColor.opacity(0.10))
                EpsilonBand(limitScreen: suite.limit * scale, epsilonScreen: epsilon * scale)
                    .stroke(bandColor.opacity(0.7), style: StrokeStyle(lineWidth: 1, dash: [5, 3]))

                // Ligne L
                LimitLine(limitScreen: suite.limit * scale)
                    .stroke(Color.secondary.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [3, 4]))

                // Ligne verticale rang N (suites convergentes uniquement)
                if let cn = critN {
                    CritNLine(critN: cn, totalN: totalN)
                        .stroke(Color.orange.opacity(0.7), style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                }

                // Segments de connexion
                Path { path in
                    for n in 1...totalN {
                        let pt = CGPoint(x: xScreen(n), y: yScreen(suite.f(n)))
                        n == 1 ? path.move(to: pt) : path.addLine(to: pt)
                    }
                }
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)

                // Points
                ForEach(1...totalN, id: \.self) { n in
                    let inside = abs(suite.f(n) - suite.limit) < epsilon
                    let isCrit = critN == n
                    let color: Color = inside ? .green : .red
                    Circle()
                        .fill(color)
                        .frame(width: isCrit ? 12 : 8, height: isCrit ? 12 : 8)
                        .overlay(isCrit ? Circle().stroke(Color.orange, lineWidth: 2) : nil)
                        .position(x: xScreen(n), y: yScreen(suite.f(n)))
                }

                // Label N=
                if let cn = critN {
                    Text("N=\(cn)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.orange)
                        .position(x: xScreen(cn), y: 12)
                }

                // Labels bande
                let labelColor: Color = suite.converges ? .green : .red
                Text(suite.converges ? "L+ε" : "0+ε")
                    .font(.system(size: 10)).foregroundStyle(labelColor)
                    .position(x: 22, y: yScreen(suite.limit + epsilon) - 8)
                Text(suite.converges ? "L−ε" : "0−ε")
                    .font(.system(size: 10)).foregroundStyle(labelColor)
                    .position(x: 22, y: yScreen(suite.limit - epsilon) + 10)
                Text(suite.converges ? "L" : "0")
                    .font(.system(size: 10)).foregroundStyle(.secondary)
                    .position(x: 10, y: yScreen(suite.limit) - 8)
            }
            .frame(width: graphSize, height: graphSize)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .clipped()

            // Slider ε
            HStack {
                Text("ε = \(epsilon, specifier: "%.2f")")
                    .font(.system(size: 13, design: .monospaced))
                    .frame(width: 70, alignment: .leading)
                Slider(value: $epsilon, in: 0.02...1.2, step: 0.01)
            }

            // Badge
            Group {
                if !suite.converges {
                    if divergentAllIn {
                        Text("ε ≥ 1 : la bande capture tout — mais ça marche pour n'importe quelle « limite »")
                            .font(.system(size: 12)).foregroundStyle(.secondary)
                    } else {
                        Text("Pour ε < 1, il reste toujours des termes hors de la bande — aucun N ne convient")
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
                    Text("Rang N non visible — diminue ε")
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
}
