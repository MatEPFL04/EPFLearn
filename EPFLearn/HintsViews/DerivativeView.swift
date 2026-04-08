//
//  DerivativeView.swift
//  EPFLearn
//
//  Created by Mat on 05.04.2026.
//

import SwiftUI

struct Slopeview: Shape {
    var xOffset: Double
    var xOffsetEnd: Double
    let f: @Sendable (Double) -> Double
    let derivative_f: @Sendable (Double) -> Double
    let scale: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let xMath_start = (rect.minX + xOffset - rect.width/2) / scale
        let yMath_start = -f(xMath_start) + rect.height/2
        let xMath_end = (rect.maxX - xOffsetEnd - rect.width/2) / scale
        let yMath_end = -f(xMath_end) + rect.height/2
        path.move(to: CGPoint(x: rect.minX + xOffset, y: yMath_start))
        path.addLine(to: CGPoint(x: rect.maxX - xOffsetEnd, y: yMath_end))
        
        return path
    }
}
struct DerivateView: View {
    
    @State private var scale: Double = 80
    @State private var xOffset = 0.0;
    @State private var xOffsetEnd = 0.0;
    @State private var step = 50.0

    let graphSize: CGFloat = 300  // ← une seule source de vérité
    
    func f(_ x: Double) -> Double { 50 * cos(3*x) + 9 * x + 80 }
    func fPrime(_ x: Double) -> Double { 50 * sin(3*x)/3 + 9 * pow(x,2)/2 + 80*x }
    func derivativeF(_ x: Double) -> Double { -50 * 3 * sin(3*x) + 9}
    var body: some View {
        VStack {
            ZStack {
                // Couche nette par-dessus
                GridDrawing(step: 10)
                    .stroke(Color.blue.opacity(0.5), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal).stroke(Color.blue.opacity(0.8), lineWidth: 1.5)
                AxisDrawing(axis: .vertical).stroke(Color.blue.opacity(0.8), lineWidth: 1.5)
                FunctionDrawing(f: f, integrF: fPrime , scale: scale)
                    .stroke(lineWidth: 1)
                Slopeview(xOffset: xOffset, xOffsetEnd: xOffsetEnd, f: f, derivative_f: derivativeF, scale: scale)
                    .stroke(lineWidth: 1)
                
                // Point start
                let xScreenStart = xOffset  // déjà en pixels depuis minX
                let xMathStart = (xScreenStart - graphSize/2) / scale
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .position(
                        x: xScreenStart,
                        y: -f(xMathStart) + graphSize/2
                    )

                // Point end
                let xScreenEnd = graphSize - xOffsetEnd  // rect.maxX - xOffsetEnd
                let xMathEnd = (xScreenEnd - graphSize/2) / scale
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .position(
                        x: xScreenEnd,
                        y: -f(xMathEnd) + graphSize/2
                    )
                
                let slope = derivativeF(xMathStart)
                let tangentFunction = { (x: Double) in
                    f(xMathStart) + slope * (x - xMathStart)
                }
                let tangentDerivative = { (x: Double) in
                    slope
                }
                FunctionDrawing(f: tangentFunction, integrF: tangentDerivative , scale: scale)
                    .stroke(lineWidth: 1)
                
                
            }
            .frame(width: graphSize, height: graphSize)
            .clipped()
            
            Slider(value: $xOffset, in: 0...500)
            Slider(value: $xOffsetEnd, in: 0...500)

        }
        
        
    }
}

#Preview {
    DerivateView()
}
