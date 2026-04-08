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
        var path = Path()
        
        // Démarre sur l'axe
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        
        // Suit la courbe jusqu'à a
        for x in stride(from: rect.minX, to: rect.minX + a, by: 0.5) {
            let xMath = (x - rect.width / 2) / scale
            let y = -f(xMath) + rect.height / 2
            path.addLine(to: CGPoint(x: x, y: y))
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
     // ← une seule source de vérité
    
    // f et g identiques pour x < 0, divergent après
    func f(_ x: Double) -> Double {
        x <= 0 ? 80 * sin(x) : 80 * sin(x) + 30 * sin(3 * x)
    }
    func fIntegr(_ x: Double) -> Double {
        x <= 0 ? -80 * cos(x) : -80 * cos(x) - 10 * cos(3 * x)
    }

    func g(_ x: Double) -> Double {
        80 * sin(x)
    }
    func gIntegr(_ x: Double) -> Double {
        -80 * cos(x)
    }
    // Intégrale de minX jusqu'à a en coordonnées math
    var aMinXMath: Double { (0 - graphSize/2) / scale }  // bord gauche en math
    var aMath: Double { (a - graphSize/2) / scale }        // curseur en math

    var integralF: Double {
        if aMath <= 0 {
            // les deux bornes sont dans la branche gauche
            return fIntegrG(aMath) - fIntegrG(aMinXMath)
        } else if aMinXMath >= 0 {
            // les deux bornes sont dans la branche droite
            return fIntegrD(aMath) - fIntegrD(aMinXMath)
        } else {
            // on traverse x=0
            return fIntegrG(0) - fIntegrG(aMinXMath) + fIntegrD(aMath) - fIntegrD(0)
        }
    }
    var integralG: Double {
        gIntegr(aMath) - gIntegr(aMinXMath)
    }

    func fIntegrG(_ x: Double) -> Double { -80 * cos(x) }
    func fIntegrD(_ x: Double) -> Double { -80 * cos(x) - 10 * cos(3 * x) }
    
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
}
