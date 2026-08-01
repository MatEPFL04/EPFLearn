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
    @State private var b: Double =  1.0

    @State private var graphSize: CGFloat = 300
    private let baseScale: Double = 100
    private var scale: Double { baseScale * Double(graphSize) / 300 }
    
    init(_ selectedFunction: Int = 0) {
        _selectedFunction = State(initialValue: selectedFunction)
    }

    // MARK: - Functions

    static func f1(_ x: Double) -> Double { 0.5 * x + 0.2 }
    static func f2(_ x: Double) -> Double { pow(x, 3) - x }
    static func f3(_ x: Double) -> Double { cos(.pi * x) }
    static func f4(_ x: Double) -> Double { pow(x, 4) - pow(x, 2) }
    static func f5(_ x: Double) -> Double { abs(x) }

    let functions: [(Double) -> Double] = [Self.f1, Self.f2, Self.f3, Self.f4, Self.f5]

    func functionName(_ i: Int) -> String {
        ["0.5x + 0.2 (Affine)", "x³ - x", "cos(πx)", "x⁴ - x²", "|x|"][i]
    }

    enum Functions: Int, CaseIterable { case f1, f2, f3, f4, f5 }

    // MARK: - Math helpers

    func derivative(_ f: (Double) -> Double, at x: Double) -> Double {
        let h = 0.0001
        return (f(x + h) - f(x - h)) / (2 * h)
    }

    func findAllC(f: (Double) -> Double, a: Double, b: Double) -> [Double] {
        guard b > a + 0.01 else { return [] }
        let slope = (f(b) - f(a)) / (b - a)
        
        // Cas 1 : Fonction affine globale
        if selectedFunction == 0 {
            return [(a + b) / 2.0]
        }
        
        // Cas 2 : Valeur absolue |x| (Sharp Corner)
        if selectedFunction == 4 {
            // Si a et b sont du même côté de 0 (tous deux à droite ou tous deux à gauche)
            if (a > 0 && b > 0) || (a < 0 && b < 0) {
                return [(a + b) / 2.0] // On renvoie le milieu comme pour l'affine
            }
            // Si l'intervalle traverse 0, le théorème échoue -> aucun point c
            return []
        }
        
        // Recherche par balayage pour les fonctions lisses (f2, f3, f4)
        // IMPORTANT: chercher uniquement dans l'intervalle OUVERT ]a, b[
        var results: [Double] = []
        let step = (b - a) / 500.0
        let epsilon = 0.05 // Distance minimale des bornes pour garantir que c ∈ ]a,b[
        
        for i in 0...500 {
            let x = a + Double(i) * step
            
            // Exclure les points trop proches des bornes a et b
            guard x > a + epsilon && x < b - epsilon else { continue }
            guard abs(derivative(f, at: x) - slope) < 0.04 else { continue }
            
            if results.last.map({ abs($0 - x) > 0.1 }) ?? true {
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

        VStack(spacing: 14) {

            VStack(alignment: .leading, spacing: 2) {
                Text("Mean Value Theorem").font(.headline)
                Text("f(x) = \(functionName(selectedFunction))")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            ZStack {
                GridDrawing(step: 10)
                    .stroke(Color.blue.opacity(0.15), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal)
                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                AxisDrawing(axis: .vertical)
                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)

                // Courbe f
                FunctionDrawing(f: f, integrF: { _ in 0 }, scale: scale)
                    .stroke(Color.primary, lineWidth: 1.5)

                // Sécante AB
                Path { path in
                    let ext = 0.3
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

                    let labelText = (selectedFunction == 0 || selectedFunction == 4) ? "Every c \u{2208} ]a,b[" : "C"
                    pointMarker(cs: cs, x: c, y: f(c), label: labelText, color: .red, labelOffset: CGSize(width: 25, height: -10))
                }
                
                // Indicateur visuel explicite en cas d'échec du MVT dû à la non-dérivabilité
                if cPoints.isEmpty && selectedFunction == 4 {
                    Text("No point c found (Non-differentiable at x=0)")
                        .font(.caption.bold())
                        .foregroundStyle(.red)
                        .padding(6)
                        .background(Color(.systemBackground).opacity(0.8))
                        .cornerRadius(4)
                        .position(x: graphSize / 2, y: 30)
                }
            }
            .frame(width: graphSize, height: graphSize)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )

            Picker("Function f(x)", selection: $selectedFunction) {
                ForEach(Functions.allCases, id: \.self) { type in
                    Text(functionName(type.rawValue)).tag(type.rawValue)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(width: graphSize)

            // Sliders ajustés
            VStack(spacing: 10) {
                labeledSlider(label: "Bound a", value: $a) { if a >= b - 0.1 { b = a + 0.1 } }
                labeledSlider(label: "Bound b", value: $b) { if b <= a + 0.1 { a = b - 0.1 } }
            }
            .frame(width: graphSize - 40)
        }
        .padding()
        .adaptivePlot($graphSize)
    }

    // MARK: - Subviews

    @ViewBuilder
    private func pointMarker(cs: MathCoordinateSpace, x: Double, y: Double,
                              label: String, color: Color,
                              labelOffset: CGSize) -> some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .position(cs.toScreen(x: x, y: y))
        Text(label)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(color)
            .position(x: cs.toScreen(x: x) + labelOffset.width,
                      y: cs.toScreen(y: y) + labelOffset.height)
    }

    @ViewBuilder
    private func labeledSlider(label: String, value: Binding<Double>,
                                onChange: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(label) = \(value.wrappedValue, specifier: "%.2f")")
                .font(.caption)
                .foregroundStyle(.secondary)
            Slider(value: value, in: -1.4...1.4, step: 0.01)
                .onChange(of: value.wrappedValue) { onChange() }
        }
    }
}

#Preview {
    TAFView()
        .preferredColorScheme(.dark)
}
