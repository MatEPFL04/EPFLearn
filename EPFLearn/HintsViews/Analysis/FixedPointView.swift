//
//  FixedPointView.swift
//  EPFLearn
//
//  Created by Mat on 07.04.2026.
//
import SwiftUI

struct FixedPointView: View {
    
    @State private var selectedFunction = 0
    let graphSize: CGFloat = 300
    let scale: Double = 100
    
    // Points A et B fixes en coordonnées math
    let A = (0.0, 1.0)  // au dessus diagonale : 0.5 > -1
    let B = (1.0, 0.0)   // en dessous diagonale : 0.5 < 1

    // Cercle A
    
    
    func xScreen(_ xMath: Double) -> CGFloat { CGFloat(xMath * scale) + graphSize/2 }
    func yScreen(_ yMath: Double) -> CGFloat { CGFloat(-yMath * scale) + graphSize/2 }
    
    static func f1(_ x: Double) -> Double { return -x + 1 }
    static func f2(_ x: Double) -> Double { return -pow(x,2) + 1 }
    static func f3(_ x: Double) -> Double { return cos(.pi / 2 * x) }
    static func f4(_ x: Double) -> Double { return 1 - x + 0.6 * 2 * sin(3 * .pi * x) }
    
    static func functionName(_ i: Int) -> String {
        switch i {
        case 0:
            return "first function"
        case 1:
            return "second function"
        case 2:
            return "third function"
        case 3:
            return "fourth function"
        default:
            return ""
        }
         
    }
    
    let functions: [(Double) -> Double] = [f1,f2,f3,f4]
    
    enum Functions: Int, CaseIterable {
        case f1 = 0
        case f2 = 1
        case f3 = 2
        case f4 = 3
    }
    
    var body: some View {
        
        ZStack {
            GridDrawing(step: 10)
                .stroke(Color.blue.opacity(0.3), lineWidth: 0.5)
            AxisDrawing(axis: .horizontal)
                .stroke(Color.blue.opacity(0.6), lineWidth: 1)
            AxisDrawing(axis: .vertical)
                .stroke(Color.blue.opacity(0.6), lineWidth: 1)
            
            // Diagonale y = x
            FunctionDrawing(f: { x in x }, integrF: { x in pow(x,2)/2 }, scale: scale)
                .stroke(Color.gray.opacity(1), style: StrokeStyle(lineWidth: 1, dash: [4,3]))
            FunctionDrawing(f: { x in (functions[selectedFunction](x)) }, integrF: { x in pow(x,2)/2 }, scale: scale)
                .stroke(lineWidth: 1)
           
            
            // Point A (-1, 0.5) — au dessus
            Circle()
                .fill(Color.blue)
                .frame(width: 10, height: 10)
                .position(x: xScreen(A.0), y: yScreen(A.1))
            Text("A")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.blue)
                .position(x: xScreen(A.0) - 14, y: yScreen(A.1) - 8)
            
            // Point B (1, 0.5) — en dessous
            Circle()
                .fill(Color.blue)
                .frame(width: 10, height: 10)
                .position(x: xScreen(B.0), y: yScreen(B.1))
            Text("B")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.blue)
                .position(x: xScreen(B.0) + 14, y: yScreen(B.1) - 8)
            
           
        }
        .frame(width: graphSize, height: graphSize)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .pickerStyle(.segmented)
        
        Picker("Function: ", selection: $selectedFunction) {
            ForEach(Functions.allCases, id: \.self) { type in
                let i = type.rawValue
                Text("\(FixedPointView.functionName(i))").tag(i)
            }
        }.pickerStyle(.menu)
        
    }
}

#Preview {
    FixedPointView()
        .preferredColorScheme(.dark)
}
