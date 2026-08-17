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
    
    @State private var selectedFunction = 0
    @State private var graphSize: CGFloat = 300
    /// Where the gap f(x) − x is being read. The sign of that gap, and the fact
    /// that it changes sign, is the whole theorem - so it is the thing the view
    /// now lets you move.
    @State private var cursor: Double = 0.15
    // The oscillating preset (index 3) swings well past ±1.5 in y, so it needs
    // a wider view than the other presets to keep its peaks from being cropped.
    // The oscillating preset still swings wider than the others, so it gets a
    // slightly wider window - enough for its peaks, not so much that the unit
    // box shrinks away.
    private var baseScale: Double {
        switch selectedFunction {
        case 1:  return 80
        case 4:  return 70   // reaches y = -1.5, so the frame has to go past it
        default: return 100
        }
    }
    private var scale: Double { baseScale * Double(graphSize) / 300 }
    
    init(_ selectedFunction: Int = 0) {
        _selectedFunction = State(initialValue: selectedFunction)
    }
    
    func xScreen(_ xMath: Double) -> CGFloat { CGFloat(xMath * scale) + graphSize/2 }
    func yScreen(_ yMath: Double) -> CGFloat { CGFloat(-yMath * scale) + graphSize/2 }
    
    // MARK: - Presets de fonctions
    static func f3(_ x: Double) -> Double { cos(.pi / 2 * x) }
    static func f4(_ x: Double) -> Double { 1 - x + 0.7 * sin(3 * .pi * x) }
    static func f5(_ x: Double) -> Double { x < 0.5 ? 0.9 : 0.1 } // Discontinuité franche
    static func f6(_ x: Double) -> Double { pow(x, 2) } // Cas rajouté f(x) = x²
    /// Continuous and strictly decreasing, yet with no fixed point in [0, 1]:
    /// the gap −2x − 0.5 runs from −0.5 down to −2.5 across the box without ever
    /// reaching 0, and the one x with f(x) = x sits at −0.25, just outside it.
    static func f7(_ x: Double) -> Double { -x - 0.5 }

    let functions: [(Double) -> Double] = [f3, f4, f5, f6, f7]

    static func functionName(_ i: Int) -> String {
        switch i {
        case 0: return "f(x) = cos(πx/2)"
        case 1: return "f(x) = 1 − x + 0.7 sin(3πx)"
        case 2: return "f(x) = 0.9 then 0.1 (jump)"
        case 3: return "f(x) = x²"
        case 4: return "f(x) = −x − 0.5"
        default: return ""
        }
    }
    
    enum Functions: Int, CaseIterable {
        case cosine = 0, oscillating = 1, jump = 2, square = 3, decreasingOff = 4
    }
    
    // MARK: - Moteur de recherche d'intersections (Points fixes : f(x) = x)
    func findFixedPoints() -> [Double] {
        let f = functions[selectedFunction]
        var points: [Double] = []
        
        // Traitement analytique pour la discontinuité pour éviter les artéfacts graphiques
        if selectedFunction == 2 { return [] }
        
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
    
    // MARK: - The gap f(x) − x

    private var cursorValue: Double { functions[selectedFunction](cursor) }
    private var gap: Double { cursorValue - cursor }
    private var gapColor: Color {
        abs(gap) < 0.02 ? .red : (gap > 0 ? .green : .pink)
    }
    private var gapText: String { String(format: "%+.2f", gap) }
    private var gapCaption: String {
        if abs(gap) < 0.02 { return "f(x) − x ≈ 0: this x is a fixed point." }
        return gap > 0
            ? "f(x) − x > 0: the curve is above the diagonal here."
            : "f(x) − x < 0: the curve is below the diagonal here."
    }

    var body: some View {
        let fixedPoints = findFixedPoints()
        
        VStack(spacing: 9) {
            
            // The function is named by the picker at the foot of the view, so
            // the subtitle says what a fixed point is instead of repeating the
            // formula next to a second "f(x) = ".
            VizHeader("Fixed Point Theorem",
                      subtitle: "Where the curve meets the line y = x.")
            
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


                // The gap f(x) − x at the cursor: green above the diagonal, red
                // below. Sliding it across a sign change is the proof.
                Path { p in
                    p.move(to: CGPoint(x: xScreen(cursor), y: yScreen(cursor)))
                    p.addLine(to: CGPoint(x: xScreen(cursor), y: yScreen(cursorValue)))
                }
                .stroke(gapColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))

                Circle()
                    .fill(gapColor)
                    .frame(width: 8, height: 8)
                    .position(x: xScreen(cursor), y: yScreen(cursorValue))

                Circle()
                    .strokeBorder(Color.orange, lineWidth: 1.5)
                    .frame(width: 8, height: 8)
                    .position(x: xScreen(cursor), y: yScreen(cursor))

                Text(gapText)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(gapColor)
                    .padding(.horizontal, 5).padding(.vertical, 2)
                    .background(.thinMaterial, in: Capsule())
                    .position(x: xScreen(cursor),
                              y: min(yScreen(cursor), yScreen(cursorValue)) - 14)

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
                    Text("No fixed point in [0, 1]: the curve never reaches the diagonal there.")
                        .font(.caption.bold())
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(6)
                        .background(Color(.systemBackground).opacity(0.85))
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.red.opacity(0.3), lineWidth: 1))
                        .frame(width: graphSize - 40)
                        .position(x: graphSize / 2, y: 40)
                }

                if selectedFunction == 2 {
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
            
            VizSlider(label: "x", value: $cursor, range: 0...1, step: 0.05, accent: .orange,
                      valueText: String(format: "%.2f", cursor),
                      caption: gapCaption)
                .frame(width: graphSize)

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
        .adaptivePlot($graphSize, max: 300)
    }
}

#Preview {
    FixedPointView()
}
