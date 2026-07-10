import SwiftUI

struct EpsilonBand: Shape {
    let limit:   Double  // en math
    let epsilon: Double  // en math
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
    let limit: Double  // en math
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
 
// MARK: - Suites
 
struct SuiteDefinition: Identifiable {
    let id:        Int
    let name:      String
    let f:         (Int) -> Double
    let limit:     Double  // limite si convergente, centre de bande sinon
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
 
    /// Maps discrete index n (1...totalN) to screen x — origin at left edge
    func xScreen(_ n: Int) -> CGFloat {
        CGFloat(n - 1) / CGFloat(totalN - 1) * graphSize
    }
 
    /// Rang critique : premier n à partir duquel tous les termes restent dans la bande
    var critN: Int? {
        guard suite.converges else { return nil }
        for n in 1...totalN {
            if (n...totalN).allSatisfy({ abs(suite.f($0) - suite.limit) < epsilon }) { return n }
        }
        return nil
    }
 
    /// Pour une suite divergente : tous les termes visibles sont-ils dans la bande ?
    var divergentAllIn: Bool {
        guard !suite.converges else { return false }
        return (1...totalN).allSatisfy { abs(suite.f($0) - suite.limit) < epsilon }
    }
 
    var body: some View {
        let cs = MathCoordinateSpace(size: graphSize, scale: scale)
 
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
 
                // Bande ε
                let bandColor: Color = suite.converges ? .green : .red
                EpsilonBand(limit: suite.limit, epsilon: epsilon, scale: scale)
                    .fill(bandColor.opacity(0.10))
                EpsilonBand(limit: suite.limit, epsilon: epsilon, scale: scale)
                    .stroke(bandColor.opacity(0.7), style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
 
                // Ligne L
                LimitLine(limit: suite.limit, scale: scale)
                    .stroke(Color.secondary.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [3, 4]))
 
                // Ligne verticale rang N
                if let cn = critN {
                    CritNLine(critN: cn, totalN: totalN)
                        .stroke(Color.orange.opacity(0.7), style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                }
 
                // Segments de connexion
                Path { path in
                    for n in 1...totalN {
                        let pt = CGPoint(x: xScreen(n), y: cs.toScreen(y: suite.f(n)))
                        n == 1 ? path.move(to: pt) : path.addLine(to: pt)
                    }
                }
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
 
                // Points
                ForEach(1...totalN, id: \.self) { n in
                    let inside = abs(suite.f(n) - suite.limit) < epsilon
                    let isCrit = critN == n
                    Circle()
                        .fill(inside ? Color.green : Color.red)
                        .frame(width: isCrit ? 12 : 8, height: isCrit ? 12 : 8)
                        .overlay(isCrit ? Circle().stroke(Color.orange, lineWidth: 2) : nil)
                        .position(x: xScreen(n), y: cs.toScreen(y: suite.f(n)))
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
 
            // Slider ε
            HStack {
                Text("ε = \(epsilon, specifier: "%.2f")")
                    .font(.system(size: 13, design: .monospaced))
                    .frame(width: 70, alignment: .leading)
                Slider(value: $epsilon, in: 0.02...1.2, step: 0.01)
            }
 
            // Badge statut
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
        .preferredColorScheme(.dark)
}
