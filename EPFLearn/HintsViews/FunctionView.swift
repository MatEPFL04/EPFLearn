//
//  FunctionView.swift
//  EPFLearn
//
//  Created by Mat on 05.04.2026.
//

import SwiftUI

struct AxisDrawing: Shape {
    
    enum Axis { case horizontal, vertical }
    
    let axis: Axis
    func path(in rect: CGRect) -> Path {
        var path = Path()
        switch axis {
        case .horizontal:
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        case .vertical:
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        }
        return path
    }
}

struct GridDrawing: Shape {
    var step: CGFloat = 1
  
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        stride(from: rect.minX, through: rect.maxX, by: step).forEach { x in
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
        }
        // Lignes horizontales
        stride(from: rect.minY, through: rect.maxY, by: step).forEach { y in
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
        }
        
        return path
    }
}

struct Darboux: Shape {
    var step: CGFloat
    let f: @Sendable (Double) -> Double
    let isDarbouxInf: Bool
    let scale: Double
    func area(in rect: CGRect) -> CGFloat {
        var area = 0.0
        let searchDelta = 0.1
        for x in stride(from: rect.minX, to: rect.maxX, by: step) {
            let xMath = (x - rect.width/2) / scale
            var bestYet = f(xMath)
            for v in stride(from: x, to: x + step, by: searchDelta) {
                let vMath = (v - rect.width/2) / scale
                let new = f(vMath)
                if isDarbouxInf { bestYet = min(bestYet, new) }
                else { bestYet = max(bestYet, new) }
            }
            area += (step / scale) * bestYet
        }
        return area
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let searchDelta = 0.1
        
        for x in stride(from: rect.minX, to: rect.maxX, by: step) {//un intervalle dans la subdivision
            let xMath = (x - rect.width/2) / scale
            var bestYet = -f(xMath)  + rect.height/2
            for v in stride(from: x, to: x + step, by: searchDelta) {
                let vMath = (v - rect.width/2) / scale
                let new = -f(vMath)  + rect.height/2
                if isDarbouxInf { bestYet = max(bestYet, new) }
                else { bestYet = min(bestYet, new) }
                    
            }
            path.move(to: CGPoint(x:x, y: rect.midY))
            path.addLine(to: CGPoint(x: x, y: bestYet))
            path.addLine(to: CGPoint(x: x + step,y: bestYet))
            path.addLine(to: CGPoint(x: x + step,y: rect.midY))
        }
        return path
    }
}


struct FunctionDrawing: Shape {

    let f: @Sendable (Double) -> Double
    let integrF: @Sendable (Double) -> Double
    let scale: Double
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for x in stride(from: rect.minX, to: rect.maxX, by: 0.01) {
            let xMath = (x - rect.width/2) / scale
            let y = -f(xMath) + rect.height / 2
            if (x == 0) {
                path.move(to: CGPoint(x: x, y: y))
            } else { path.addLine(to: CGPoint(x: x, y: y) ) }
        }
        return path
    }
    
    func integralValue(in rect: CGRect) -> Double {
        let screenA = (rect.minX - rect.width / 2) / scale
        let screenB = (rect.maxX - rect.width / 2) / scale
        return integrF(screenB) - integrF(screenA)
    }
    
    
    static func make(_ type: MathFunctionType, scale: Double) -> FunctionDrawing {
        switch type {
        case .affine:
            return FunctionDrawing(
                f: { x in 2 * x + 5 },
                integrF: { x in 2 * pow(x,2)/2 + 5*x }, scale: scale
            )
        case .quadratic:
            return FunctionDrawing(
                f: { x in 3 * pow(x,2) },
                integrF: { x in 3 * pow(x,3)/3 }, scale: scale
            )
        case .cubic:
            return FunctionDrawing(
                f: { x in pow(x,3) },
                integrF: { x in pow(x,4)/4 }, scale: scale
            )
        case .sine:
            return FunctionDrawing(
                f: { x in 100 * sin(0.2 * x) },
                integrF: { x in -100 / 0.2 * cos(0.2 * x) }, scale: scale
            )
        case .cosine:
            return FunctionDrawing(
                f: { x in 100 * cos(0.2 *  x) },
                integrF: { x in 100 / 0.2 * sin(0.2 * x) }, scale: scale
            )
        }
    }
}

enum MathFunctionType: String, CaseIterable {
    case affine = "f(x) = 2x + 5"
    case quadratic = "f(x) = 3x²"
    case cubic = "f(x) = x³"
    case sine = "f(x) = 100sin(0.2x)"
    case cosine = "f(x) = 100cos(0.2x)"
}


struct FunctionView: View {
    @State private var scale: Double = 10
    @State private var slope = 1.0;
    @State private var offset = 3.0;
    @State private var subDivisionStep = 15.0
    @State private var selectedFunction = MathFunctionType.quadratic
    let hint: String
    
    let graphSize: CGFloat = 300  // ← une seule source de vérité
    
    var subDivSize: CGFloat {
        graphSize / subDivisionStep
    }
    var graphRect: CGRect {
        CGRect(x: 0, y: 0, width: graphSize, height: graphSize)
    }
    
    
    var body: some View {
        let currentFunction = FunctionDrawing.make(selectedFunction, scale: scale)
        let darbouxSup = Darboux(step: subDivisionStep, f: currentFunction.f, isDarbouxInf: false, scale: scale)
        let darbouxInf = Darboux(step: subDivisionStep, f: currentFunction.f, isDarbouxInf: true, scale: scale)
        Form {
            ZStack {
                // Couche nette par-dessus
                GridDrawing(step: 10)
                    .stroke(Color.blue.opacity(0.5), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal).stroke(Color.blue.opacity(0.8), lineWidth: 1.5)
                AxisDrawing(axis: .vertical).stroke(Color.blue.opacity(0.8), lineWidth: 1.5)
                
                currentFunction
                    .stroke(lineWidth: 1)
                
                darbouxSup
                    .stroke(Color.red, lineWidth: 1)
                darbouxInf
                    .stroke(Color.blue, lineWidth: 1)
            }
            .background(Color.white)
            .containerShape(.capsule)
            .frame(width: graphSize, height: graphSize)
            .clipped()
            
            Picker("Function: ", selection: $selectedFunction) {
                ForEach(MathFunctionType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }.pickerStyle(.menu)
            
            
            Section("Areas") {
                Text("integral: \(currentFunction.integralValue(in: graphRect), specifier: "%.2f")")
                Text("Darboux supremum: \(darbouxSup.area(in: graphRect), specifier: "%.2f")")
                Text("Darboux infinimum: \(darbouxInf.area(in: graphRect), specifier: "%.2f")")
            }
            
            Group {
                Text("subdivision size:  \(subDivSize)")
                Slider(value: $subDivisionStep, in: 1...100, step: 1)
            }
            
        }
        
    }
}


#Preview {
    FunctionView(hint: "Play with the subdivision and see when the result is precise")
}
