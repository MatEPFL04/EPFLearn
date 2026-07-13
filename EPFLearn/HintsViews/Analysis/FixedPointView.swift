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
    let graphSize: CGFloat = 300
    let scale: Double = 100
    
    // Points A et B recalculés depuis la fonction sélectionnée§§§
    var A: (Double, Double) { (0.0, functions[selectedFunction](0.0)) }
    var B: (Double, Double) { (1.0, functions[selectedFunction](1.0)) }

    // Cercle A
    
    
    func xScreen(_ xMath: Double) -> CGFloat { CGFloat(xMath * scale) + graphSize/2 }
    func yScreen(_ yMath: Double) -> CGFloat { CGFloat(-yMath * scale) + graphSize/2 }
    
    static func f1(_ x: Double) -> Double { return -x + 1 }
    static func f2(_ x: Double) -> Double { return -pow(x,2) + 1 }
    static func f3(_ x: Double) -> Double { return cos(.pi / 2 * x) }
    static func f4(_ x: Double) -> Double { return 1 - x + 0.6 * 2 * sin(3 * .pi * x) }
    static func f5(_ x: Double) -> Double { return x <= 1.2 ? (-x + 1) : (-x + 1) + 1.5 }
    static func f6(_ x: Double) -> Double { return x < 0.5 ? 0.9 : 0.1 }
    
    static func functionName(_ i: Int) -> String {
        switch i {
        case 0:
            return "f(x) = 1 − x"
        case 1:
            return "f(x) = 1 − x²"
        case 2:
            return "f(x) = cos(πx/2)"
        case 3:
            return "f(x) = 1 − x + sin oscillation"
        case 4:
            return "discontinuity inside [a,b]"
        default:
            return ""
        }
    }
    
    let functions: [(Double) -> Double] = [f1,f2,f3,f4,f6]

    enum Functions: Int, CaseIterable {
        case f1 = 0
        case f2 = 1
        case f3 = 2
        case f4 = 3
        case f6 = 4
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
            BreakingFunctionDrawing(f: { x in (functions[selectedFunction](x)) }, scale: scale)
                .stroke(lineWidth: 1)
           
            
            // Point A
            Circle()
                .fill(Color.blue)
                .frame(width: 10, height: 10)
                .position(x: xScreen(A.0), y: yScreen(A.1))
            Text("A")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.blue)
                .position(x: xScreen(A.0) - 14, y: yScreen(A.1) - 8)
            
            // Point B
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
        .padding(6)
        .background(Color(.systemBackground))
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
