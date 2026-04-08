//
//  TAFView.swift
//  EPFLearn
//
//  Created by Mat on 07.04.2026.
//

import SwiftUI
   

struct TAFView: View {
    
    @State private var selectedFunction = 0
    @State private var a: Double = -1.0
    @State private var b: Double = 1.0
    let graphSize: CGFloat = 300
    let scale: Double = 100
    
    func xScreen(_ xMath: Double) -> CGFloat { CGFloat(xMath * scale) + graphSize/2 }
    func yScreen(_ yMath: Double) -> CGFloat { CGFloat(-yMath * scale) + graphSize/2 }
    
    static func f1(_ x: Double) -> Double { sin(2 * .pi * x) }
    static func f2(_ x: Double) -> Double { -pow(x, 2) + 1 }
    static func f3(_ x: Double) -> Double { cos(.pi / 2 * x) }
    static func f4(_ x: Double) -> Double { pow(x, 3) - x }
    
    let functions: [(Double) -> Double] = [f1, f2, f3, f4]
    
    func functionName(_ i: Int) -> String {
        switch i {
        case 0: return "sin(2πx)"
        case 1: return "-x² + 1"
        case 2: return "cos(πx/2)"
        case 3: return "x³ - x"
        default: return ""
        }
    }
    
    // Dérivée numérique
    func derivative(_ f: (Double) -> Double, at x: Double) -> Double {
        let h = 0.0001
        return (f(x + h) - f(x - h)) / (2 * h)
    }
    
    // Tous les points C dans ]a, b[ où f'(c) ≈ pente AB
    func findAllC(f: (Double) -> Double, a: Double, b: Double) -> [Double] {
        guard b > a + 0.01 else { return [] }
        let slope = (f(b) - f(a)) / (b - a)
        var results: [Double] = []
        let steps = 500
        let step = (b - a) / Double(steps)
        for i in 0...steps {
            let x = a + Double(i) * step
            if abs(derivative(f, at: x) - slope) < 0.05 {
                // Éviter les doublons
                if results.last.map({ abs($0 - x) > 0.05 }) ?? true {
                    results.append(x)
                }
            }
        }
        return results
    }
    
    enum Functions: Int, CaseIterable {
        case f1 = 0, f2 = 1, f3 = 2, f4 = 3
    }
    
    var body: some View {
        
        let f = functions[selectedFunction]
        let aPoint = (a, f(a))
        let bPoint = (b, f(b))
        let slope = (f(b) - f(a)) / (b - a)
        let cPoints = findAllC(f: f, a: a, b: b)
        
        VStack(spacing: 12) {
            
            ZStack {
                Color.white
                GridDrawing(step: 10)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal)
                    .stroke(Color.blue.opacity(0.6), lineWidth: 1)
                AxisDrawing(axis: .vertical)
                    .stroke(Color.blue.opacity(0.6), lineWidth: 1)
                
                // Courbe f
                FunctionDrawing(
                    f: { x in CGFloat(f(x) * scale) },
                    integrF: { x in 0 },
                    scale: scale
                )
                .stroke(Color.black, lineWidth: 1.5)
                
                // Sécante AB
                Path { path in
                    let x0 = xScreen(a - 0.5)
                    let y0 = yScreen(f(a) + slope * (a - 0.5 - a))
                    let x1 = xScreen(b + 0.5)
                    let y1 = yScreen(f(a) + slope * (b + 0.5 - a))
                    path.move(to: CGPoint(x: x0, y: y0))
                    path.addLine(to: CGPoint(x: x1, y: y1))
                }
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 1.2, dash: [5, 3]))
                
                // Point A
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
                    .position(x: xScreen(aPoint.0), y: yScreen(aPoint.1))
                Text("A")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.blue)
                    .position(x: xScreen(aPoint.0) - 14, y: yScreen(aPoint.1) - 8)
                
                // Point B
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
                    .position(x: xScreen(bPoint.0), y: yScreen(bPoint.1))
                Text("B")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.blue)
                    .position(x: xScreen(bPoint.0) + 14, y: yScreen(bPoint.1) - 8)
                
                // Points C + tangentes parallèles
                ForEach(Array(cPoints.enumerated()), id: \.offset) { _, c in
                    let fc = f(c)
                    
                    // Tangente en C (parallèle à AB)
                    Path { path in
                        let x0 = xScreen(c - 0.4)
                        let y0 = yScreen(fc + slope * (-0.4))
                        let x1 = xScreen(c + 0.4)
                        let y1 = yScreen(fc + slope * (0.4))
                        path.move(to: CGPoint(x: x0, y: y0))
                        path.addLine(to: CGPoint(x: x1, y: y1))
                    }
                    .stroke(Color.red, lineWidth: 1.2)
                    
                    // Point C
                    Circle()
                        .fill(Color.red)
                        .frame(width: 9, height: 9)
                        .position(x: xScreen(c), y: yScreen(fc))
                    Text("C")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.red)
                        .position(x: xScreen(c) + 14, y: yScreen(fc) - 8)
                }
            }
            .frame(width: graphSize, height: graphSize)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Sliders A et B
            VStack(spacing: 6) {
                HStack {
                    Text("a = \(a, specifier: "%.2f")")
                        .font(.system(size: 12, design: .monospaced))
                        .frame(width: 80, alignment: .leading)
                    Slider(value: $a, in: -1.4...1.4, step: 0.01)
                        .onChange(of: a) { if a >= b - 0.1 { b = a + 0.1 } }
                }
                HStack {
                    Text("b = \(b, specifier: "%.2f")")
                        .font(.system(size: 12, design: .monospaced))
                        .frame(width: 80, alignment: .leading)
                    Slider(value: $b, in: -1.4...1.4, step: 0.01)
                        .onChange(of: b) { if b <= a + 0.1 { a = b - 0.1 } }
                }
            }
            .padding(.horizontal)
            
            // Picker
            Picker("Fonction", selection: $selectedFunction) {
                ForEach(Functions.allCases, id: \.self) { type in
                    Text(functionName(type.rawValue)).tag(type.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
        }
    }
}

#Preview {
    TAFView()
}
