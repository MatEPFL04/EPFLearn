//
//  MeanThmView.swift
//  EPFLearn
//
//  Created by Mat on 05.04.2026.
//
 
import SwiftUI
 
struct SectionsShape: Shape {
    var step:    CGFloat
    let f:       @Sendable (Double) -> Double
    let fIntegr: @Sendable (Double) -> Double
    let scale:   Double
 
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cs = MathCoordinateSpace(rect: rect, scale: scale)
 
        for x in stride(from: rect.minX, to: rect.maxX, by: step) {
            let xMath     = cs.toMath(x: x)
            let xNextMath = cs.toMath(x: x + step)
            let dx        = xNextMath - xMath
 
            // Valeur moyenne de f sur [xMath, xNextMath] via la primitive
            let target = (fIntegr(xNextMath) - fIntegr(xMath)) / dx
 
            // Chercher c ∈ [xMath, xNextMath] tel que f(c) ≈ target (TVM)
            var cMath = xMath
            for c in stride(from: x, to: x + step, by: 0.01) {
                let candidate = cs.toMath(x: c)
                if abs(f(candidate) - target) < 0.1 { cMath = candidate }
            }
 
            let yRightC = cs.toScreen(y: f(cMath))
            guard yRightC >= rect.minY && yRightC <= rect.maxY else { continue }
 
            // Rectangle dont la hauteur est f(c) — aire exacte par le TVM
            path.move(to:    CGPoint(x: x,        y: rect.midY))
            path.addLine(to: CGPoint(x: x,        y: yRightC))
            path.addLine(to: CGPoint(x: x + step, y: yRightC))
            path.addLine(to: CGPoint(x: x + step, y: rect.midY))
            path.closeSubpath()
        }
        return path
    }
}
 
struct MeanThmView: View {
 
    @State private var scale: Double = 100
    @State private var step         = 50.0
 
    let graphSize: CGFloat = 300
 
    func f(_ x: Double) -> Double      {  cos(3 * x) }
    func fPrime(_ x: Double) -> Double { sin(3 * x) / 3 }
 
    var body: some View {
        VStack {
            ZStack {
                GridDrawing(step: 10)
                    .stroke(Color.blue.opacity(0.5), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal)
                    .stroke(Color.blue.opacity(0.8), lineWidth: 1.5)
                AxisDrawing(axis: .vertical)
                    .stroke(Color.blue.opacity(0.8), lineWidth: 1.5)
 
                FunctionDrawing(f: f, integrF: fPrime, scale: scale)
                    .stroke(lineWidth: 1)
 
                SectionsShape(step: step, f: f, fIntegr: fPrime, scale: scale)
                    .fill(Color.blue.opacity(0.2))
                SectionsShape(step: step, f: f, fIntegr: fPrime, scale: scale)
                    .stroke(Color.blue, lineWidth: 1)
            }
            .frame(width: graphSize, height: graphSize)
            .clipped()
 
            Slider(value: $step, in: 1...50, label: { Text("sections") })
        }
    }
}
 
#Preview {
    MeanThmView()
}
