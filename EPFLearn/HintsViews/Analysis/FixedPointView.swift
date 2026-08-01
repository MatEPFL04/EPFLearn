//
//  FixedPointView.swift
//  EPFLearn
//
//  Created by Mat on 07.04.2026.
//

import SwiftUI

struct BreakingFunctionDrawing: Shape {
    let f: @Sendable (Double) -> Double
    let scale: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        var previousY: CGFloat? = nil
        let jumpThreshold: CGFloat = 15
        
        for x in stride(from: rect.minX, to: rect.maxX, by: 0.5) {
            let xMath = (x - rect.width/2) / scale
            let y = -CGFloat(f(xMath) * scale) + rect.height / 2
            
            if let prevY = previousY, abs(y - prevY) < jumpThreshold {
                path.addLine(to: CGPoint(x: x, y: y))
            } else {
                path.move(to: CGPoint(x: x, y: y))
            }
            previousY = y
        }
        return path
    }
}

struct FixedPointView: View {
    
    @State private var selectedFunction = 1
    @State private var graphSize: CGFloat = 300
    private let baseScale: Double = 100
    private var scale: Double { baseScale * Double(graphSize) / 300 }
    
    init(_ selectedFunction: Int = 1) {
        _selectedFunction = State(initialValue: selectedFunction)
    }
    
    // Points de contrôle de l'intervalle d'étude [0, 1]
    var A: (Double, Double) { (0.0, functions[selectedFunction](0.0)) }
    var B: (Double, Double) { (1.0, functions[selectedFunction](1.0)) }

    func xScreen(_ xMath: Double) -> CGFloat { CGFloat(xMath * scale) + graphSize/2 }
    func yScreen(_ yMath: Double) -> CGFloat { CGFloat(-yMath * scale) + graphSize/2 }
    
    // MARK: - Presets de fonctions
    static func f1(_ x: Double) -> Double { -x + 1 }
    static func f2(_ x: Double) -> Double { -pow(x,2) + 1 }
    static func f3(_ x: Double) -> Double { cos(.pi / 2 * x) }
    static func f4(_ x: Double) -> Double { 1 - x + 0.6 * 2 * sin(3 * .pi * x) }
    static func f5(_ x: Double) -> Double { x < 0.5 ? 0.9 : 0.1 } // Discontinuité franche
    static func f6(_ x: Double) -> Double { pow(x, 2) } // Cas rajouté f(x) = x²

    let functions: [(Double) -> Double] = [f1, f2, f3, f4, f5, f6]

    static func functionName(_ i: Int) -> String {
        switch i {
        case 0: return "f(x) = 1 − x"
        case 1: return "f(x) = 1 − x²"
        case 2: return "f(x) = cos(πx/2)"
        case 3: return "f(x) = 1 − x + sin osc"
        case 4: return "Discontinuity"
        case 5: return "f(x) = x²"
        default: return ""
        }
    }
    
    enum Functions: Int, CaseIterable {
        case f1 = 0, f2 = 1, f3 = 2, f4 = 3, f5 = 4, f6 = 5
    }
    
    // MARK: - Moteur de recherche d'intersections (Points fixes : f(x) = x)
    func findFixedPoints() -> [Double] {
        let f = functions[selectedFunction]
        var points: [Double] = []
        
        // Traitement analytique pour la discontinuité pour éviter les artéfacts graphiques
        if selectedFunction == 4 { return [] }
        
        let steps = 400
        let minX = -1.5
        let maxX = 1.5
        let step = (maxX - minX) / Double(steps)
        
        for i in 0..<steps {
            let x1 = minX + Double(i) * step
            let x2 = x1 + step
            let y1 = f(x1) - x1
            let y2 = f(x2) - x2
            
            // Changement de signe détecté (Théorème des Valeurs Intermédiaires numérique)
            if y1 * y2 <= 0 {
                let exactX = x1 - y1 * (x2 - x1) / (y2 - y1) // Approximation linéaire
                if points.last.map({ abs($0 - exactX) > 0.05 }) ?? true {
                    points.append(exactX)
                }
            }
        }
        return points
    }
    
    var body: some View {
        let fixedPoints = findFixedPoints()
        
        VStack(spacing: 14) {
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Fixed Point Theorem").font(.headline)
                Text("f(x) = \(FixedPointView.functionName(selectedFunction))")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            
            ZStack {
                GridDrawing(step: 10)
                    .stroke(Color.blue.opacity(0.15), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal)
                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                AxisDrawing(axis: .vertical)
                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                
                // Diagonale y = x (Ligne de référence des points fixes)
                FunctionDrawing(f: { x in x }, integrF: { x in pow(x,2)/2 }, scale: scale)
                    .stroke(Color.orange.opacity(0.6), style: StrokeStyle(lineWidth: 1.2, dash: [4,3]))
                
                // Tracé de la fonction active
                BreakingFunctionDrawing(f: { x in functions[selectedFunction](x) }, scale: scale)
                    .stroke(Color.primary, lineWidth: 2)
                
                // Encadrement visuel de l'intervalle d'étude [0, 1] (Boîte unité)
                // Encadrement visuel de l'intervalle d'étude [0, 1] (Boîte unité)
                Path { path in
                    path.move(to: CGPoint(x: xScreen(0), y: yScreen(0)))
                    path.addLine(to: CGPoint(x: xScreen(1), y: yScreen(0)))
                    path.addLine(to: CGPoint(x: xScreen(1), y: yScreen(1)))
                    path.addLine(to: CGPoint(x: xScreen(0), y: yScreen(1)))
                    path.closeSubpath() // Correction ici
                }
                .stroke(Color.purple.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [2, 2])) // Correction ici

                
                // Bornes aux extrémités de l'intervalle : Point A (x = 0)
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                    .position(x: xScreen(A.0), y: yScreen(A.1))
                Text("f(0)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.blue)
                    .position(x: xScreen(A.0) - 18, y: yScreen(A.1))
                
                // Point B (x = 1)
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                    .position(x: xScreen(B.0), y: yScreen(B.1))
                Text("f(1)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.blue)
                    .position(x: xScreen(B.0) + 18, y: yScreen(B.1))
                
                // Affichage dynamique et interactif des Points Fixes (Intersections Rouges)
                ForEach(fixedPoints, id: \.self) { pt in
                    Circle()
                        .stroke(Color.red, lineWidth: 2)
                        .background(Circle().fill(Color.red.opacity(0.6)))
                        .frame(width: 6, height: 6)
                        .position(x: xScreen(pt), y: yScreen(pt))
                }
                
                // Cas d'école de la discontinuité : Alerte si aucun point fixe n'est trouvé
                if selectedFunction == 4 {
                    Text("No Fixed Point! (Broken Continuity)")
                        .font(.caption.bold())
                        .foregroundStyle(.red)
                        .padding(6)
                        .background(Color(.systemBackground).opacity(0.85))
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.red.opacity(0.3), lineWidth: 1))
                        .position(x: graphSize / 2, y: 40)
                }
            }
            .frame(width: graphSize, height: graphSize)
            .padding(6)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.15), lineWidth: 1))
            
            // Légende interactive explicative selon la configuration affichée
            Group {
                if selectedFunction == 4 {
                    Text("The jump discontinuity allows the function to bypass the diagonal without crossing it.")
                } else if selectedFunction == 5 {
                    Text("Two fixed points exist right on the edges of the box: x = 0 and x = 1.")
                } else {
                    Text("Fixed points (\(fixedPoints.count)) appear where the curve meets the orange diagonal.")
                }
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 10)
            .frame(height: 30)
            
            Picker("Function", selection: $selectedFunction) {
                ForEach(Functions.allCases, id: \.self) { type in
                    let i = type.rawValue
                    Text("\(FixedPointView.functionName(i))").tag(i)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(width: graphSize)
        }
        .padding()
        .adaptivePlot($graphSize)
    }
}

#Preview {
    FixedPointView()
        .preferredColorScheme(.dark)
}
