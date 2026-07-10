//
//  TAFView.swift
//  EPFLearn
//
//  Created by Mat on 07.04.2026.
//

//  Created by Mat on 07.04.2026.
//
 
import SwiftUI
 
struct TAFView: View {
 
    @State private var selectedFunction = 0
    @State private var a: Double = -1.0
    @State private var b: Double =  1.0
 
    let graphSize: CGFloat = 300
    let scale: Double      = 100
 
    // MARK: - Functions
 
    static func f1(_ x: Double) -> Double { sin(2 * .pi * x) }
    static func f2(_ x: Double) -> Double { -pow(x, 2) + 1 }
    static func f3(_ x: Double) -> Double { cos(.pi / 2 * x) }
    static func f4(_ x: Double) -> Double { pow(x, 3) - x }
 
    let functions: [(Double) -> Double] = [f1, f2, f3, f4]
 
    func functionName(_ i: Int) -> String {
        ["sin(2πx)", "-x² + 1", "cos(πx/2)", "x³ - x"][i]
    }
 
    enum Functions: Int, CaseIterable { case f1, f2, f3, f4 }
 
    // MARK: - Math helpers
 
    func derivative(_ f: (Double) -> Double, at x: Double) -> Double {
        let h = 0.0001
        return (f(x + h) - f(x - h)) / (2 * h)
    }
 
    func findAllC(f: (Double) -> Double, a: Double, b: Double) -> [Double] {
        guard b > a + 0.01 else { return [] }
        let slope = (f(b) - f(a)) / (b - a)
        var results: [Double] = []
        let step = (b - a) / 500.0
        for i in 0...500 {
            let x = a + Double(i) * step
            guard abs(derivative(f, at: x) - slope) < 0.05 else { continue }
            if results.last.map({ abs($0 - x) > 0.05 }) ?? true {
                results.append(x)
            }
        }
        return results
    }
 
    // MARK: - Body
 
    var body: some View {
        let cs      = MathCoordinateSpace(size: graphSize, scale: scale)
        let f       = functions[selectedFunction]
        let slope   = (f(b) - f(a)) / (b - a)
        let cPoints = findAllC(f: f, a: a, b: b)
 
        VStack(spacing: 12) {
            ZStack {
                GridDrawing(step: 10)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal)
                    .stroke(Color.blue.opacity(0.6), lineWidth: 1)
                AxisDrawing(axis: .vertical)
                    .stroke(Color.blue.opacity(0.6), lineWidth: 1)
 
                // Courbe f
                FunctionDrawing(f: f, integrF: { _ in 0 }, scale: scale)
                    .stroke(Color.primary, lineWidth: 1.5)
 
                // Sécante AB
                Path { path in
                    let ext = 0.5
                    path.move(to:    cs.toScreen(x: a - ext, y: f(a) + slope * (-ext)))
                    path.addLine(to: cs.toScreen(x: b + ext, y: f(a) + slope * (b + ext - a)))
                }
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 1.2, dash: [5, 3]))
 
                // Point A
                pointMarker(cs: cs, x: a, y: f(a), label: "A", color: .blue, labelOffset: CGSize(width: -14, height: -8))
 
                // Point B
                pointMarker(cs: cs, x: b, y: f(b), label: "B", color: .blue, labelOffset: CGSize(width: 14, height: -8))
 
                // Points C + tangentes parallèles
                ForEach(Array(cPoints.enumerated()), id: \.offset) { _, c in
                    let ext = 0.4
                    Path { path in
                        path.move(to:    cs.toScreen(x: c - ext, y: f(c) + slope * (-ext)))
                        path.addLine(to: cs.toScreen(x: c + ext, y: f(c) + slope * (ext)))
                    }
                    .stroke(Color.red, lineWidth: 1.2)
 
                    pointMarker(cs: cs, x: c, y: f(c), label: "C", color: .red, labelOffset: CGSize(width: 14, height: -8))
                }
            }
            .frame(width: graphSize, height: graphSize)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
 
            // Sliders
            VStack(spacing: 6) {
                labeledSlider(label: "a", value: $a) { if a >= b - 0.1 { b = a + 0.1 } }
                labeledSlider(label: "b", value: $b) { if b <= a + 0.1 { a = b - 0.1 } }
            }
            .padding(.horizontal)
 
            Picker("Fonction", selection: $selectedFunction) {
                ForEach(Functions.allCases, id: \.self) { type in
                    Text(functionName(type.rawValue)).tag(type.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
        }
    }
 
    // MARK: - Subviews
 
    @ViewBuilder
    private func pointMarker(cs: MathCoordinateSpace, x: Double, y: Double,
                              label: String, color: Color,
                              labelOffset: CGSize) -> some View {
        Circle()
            .fill(color)
            .frame(width: 10, height: 10)
            .position(cs.toScreen(x: x, y: y))
        Text(label)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(color)
            .position(x: cs.toScreen(x: x) + labelOffset.width,
                      y: cs.toScreen(y: y) + labelOffset.height)
    }
 
    @ViewBuilder
    private func labeledSlider(label: String, value: Binding<Double>,
                                onChange: @escaping () -> Void) -> some View {
        HStack {
            Text("\(label) = \(value.wrappedValue, specifier: "%.2f")")
                .font(.system(size: 12, design: .monospaced))
                .frame(width: 80, alignment: .leading)
            Slider(value: value, in: -1.4...1.4, step: 0.01)
                .onChange(of: value.wrappedValue) { onChange() }
        }
    }
}
 
#Preview {
    TAFView()
        .preferredColorScheme(.dark)
}
