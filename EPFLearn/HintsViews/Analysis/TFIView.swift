//
//  TFIView.swift
//  EPFLearn
//
//  Created by Mat on 06.04.2026.
//

import SwiftUI

struct integrUpToA: Shape {
    var a: Double
    let f: @Sendable (Double) -> Double
    let scale: Double
    
    func path(in rect: CGRect) -> Path {
        let cs = MathCoordinateSpace(rect: rect, scale: scale)
        var path = Path()

        // Démarre sur l'axe à gauche
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))

        // Suit la courbe de midX jusqu'à a (en pixels)
        for x in stride(from: rect.minX, to: rect.minX + a, by: 0.5) {
            path.addLine(to: cs.toScreen(x: cs.toMath(x: x), y: f(cs.toMath(x: x))))
        }

        // Ferme sur l'axe
        path.addLine(to: CGPoint(x: rect.minX + a, y: rect.midY))
        path.closeSubpath()
        return path
    }
}
struct TFIView: View {
    
    @State private var scale: Double = 90.0
    @State private var xOffset = 0.0;
    @State private var xOffsetEnd = 0.0;

    @State private var a = 0.0
    
    let graphSize: CGFloat = 250
    
    func f(_ x: Double) -> Double {
        x <= 0 ? sin(x) : sin(x) + 0.4 * sin(3 * x)
    }
    func fIntegrG(_ x: Double) -> Double { -cos(x) }
    func fIntegrD(_ x: Double) -> Double { -cos(x) - (0.4/3) * cos(3 * x) }
    func fIntegr(_ x: Double) -> Double {
        x <= 0 ? fIntegrG(x) : fIntegrD(x)
    }

    func g(_ x: Double) -> Double { sin(x) }
    func gIntegr(_ x: Double) -> Double { -cos(x) }
    
    var cs: MathCoordinateSpace { MathCoordinateSpace(size: graphSize, scale: scale) }

    var xStartMath: Double { cs.toMath(x: 0) }
    var xEndMath:   Double { cs.toMath(x: a) }
    
    var integralF: Double {
        let xStart = xStartMath
        let xEnd   = xEndMath
        if xEnd <= 0 {
            return fIntegrG(xEnd) - fIntegrG(xStart)
        } else if xStart >= 0 {
            return fIntegrD(xEnd) - fIntegrD(xStart)
        } else {
            return fIntegrG(0) - fIntegrG(xStart) + fIntegrD(xEnd) - fIntegrD(0)
        }
    }
    
    var integralG: Double {
        gIntegr(xEndMath) - gIntegr(xStartMath)
    }
   
    
    var body: some View {
        VStack {
            ZStack {
                
                // Couche nette par-dessus
                GridDrawing(step: 10)
                    .stroke(Color.blue.opacity(0.5), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal).stroke(Color.blue.opacity(0.8), lineWidth: 1.5)
                AxisDrawing(axis: .vertical).stroke(Color.blue.opacity(0.8), lineWidth: 1.5)
                FunctionDrawing(f: f, integrF: fIntegr , scale: scale)
                    .stroke(lineWidth: 1)
                integrUpToA(a: a, f: f, scale: scale)
                    .fill(Color.blue.opacity(0.2))
                
            }
            .frame(width: graphSize, height: graphSize)
            .clipped()
            
            ZStack {
                // Couche nette par-dessus
                GridDrawing(step: 10)
                    .stroke(Color.blue.opacity(0.5), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal).stroke(Color.blue.opacity(0.8), lineWidth: 1.5)
                AxisDrawing(axis: .vertical).stroke(Color.blue.opacity(0.8), lineWidth: 1.5)
                FunctionDrawing(f: g, integrF: gIntegr, scale: scale)
                    .stroke(lineWidth: 1)
                integrUpToA(a: a, f: g, scale: scale)
                    .fill(Color.blue.opacity(0.2))
                
            }
            .frame(width: graphSize, height: graphSize)
            .clipped()
            
            Slider(value: $a, in: 0...graphSize)

            Text("F(x) = \(integralF, specifier: "%.2f")")
            Text("G(x) = \(integralG, specifier: "%.2f")")
        }
    }
}

#Preview {
    TFIView()
        .preferredColorScheme(.dark)
}
