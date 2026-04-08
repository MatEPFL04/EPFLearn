//
//  MVTView.swift
//  EPFLearn
//
//  Created by Mat on 05.04.2026.
//

import SwiftUI

struct sections: Shape {
    var step: CGFloat
    let f: @Sendable (Double) -> Double
    let fIntegr: @Sendable (Double) -> Double
    let scale: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        for x in stride(from: rect.minX, to: rect.maxX, by: step) {
          
            path.move(to: CGPoint(x:x, y: rect.midY))
            let xMath = (x - rect.width / 2) / scale
            let xNextMath = (x + step - rect.width / 2) / scale
            let integrValue = fIntegr(xNextMath) - fIntegr(xMath)
            let Dx = xNextMath - xMath
            let target = integrValue / Dx
            var rightC = xMath
            for c in stride(from: x, to: x + step, by: 0.01) {
                let cMath = (c - rect.width/2) / scale
                if abs(f(cMath) - target) < 0.1 {
                    rightC = cMath
                }
            }
            let y = -f(xMath) + rect.height/2
            path.addLine(to: CGPoint(x: x, y: y))
            
            let yRightC = -f(rightC) + rect.height / 2
            guard yRightC >= 0 && yRightC <= rect.height else { continue }
            
            //adding the derivative at the first point
    

            path.move(to: CGPoint(x: x, y: rect.midY))
            path.addLine(to: CGPoint(x: x, y: rect.minY))
            path.move(to: CGPoint(x: x, y: rect.midY))
            path.addLine(to: CGPoint(x: x, y: yRightC))
            path.addLine(to: CGPoint(x: x + step, y: yRightC))
            path.addLine(to: CGPoint(x: x + step, y: rect.midY))
            path.closeSubpath()
        }
        return path
    }
}
struct MeanThmView: View {
    
    @State private var scale: Double = 80
    @State private var slope = 1.0;
    @State private var offset = 3.0;
    @State private var step = 50.0

    let graphSize: CGFloat = 300  // ← une seule source de vérité
    
    var graphRect: CGRect {
        CGRect(x: 0, y: 0, width: graphSize, height: graphSize)
    }
    
    func f(_ x: Double) -> Double { 50 * cos(3*x) + 9 * x + 80 }
    func fPrime(_ x: Double) -> Double { 50 * sin(3*x)/3 + 9 * pow(x,2)/2 + 80*x }
    
    var body: some View {
        VStack {
            ZStack {
                // Couche nette par-dessus
                GridDrawing(step: 10)
                    .stroke(Color.blue.opacity(0.5), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal).stroke(Color.blue.opacity(0.8), lineWidth: 1.5)
                AxisDrawing(axis: .vertical).stroke(Color.blue.opacity(0.8), lineWidth: 1.5)
                FunctionDrawing(f: { x in f(x) }, integrF: { x in fPrime(x)} , scale: scale)
                    .stroke(lineWidth: 1)
                sections(step: step, f: f, fIntegr: fPrime, scale: scale)
                    .fill(Color.blue.opacity(0.2))
                sections(step: step, f: f, fIntegr: fPrime, scale: scale)
                    .stroke(Color.blue, lineWidth: 1)
                
            }
            .frame(width: graphSize, height: graphSize)
            .clipped()
            
            Slider(value: $step, in: 1...50, label: { Text("sections")})
        }
        
        
    }
}


#Preview {
    MeanThmView()
}
