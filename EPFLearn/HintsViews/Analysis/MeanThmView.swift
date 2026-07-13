//
//  MeanThmView.swift
//  EPFLearn
//
//  Created by Mat on 05.04.2026.
//

import SwiftUI

// MARK: - Modèle de fonction

private struct MeanThmFunction {
    let name:   String
    let f:      (Double) -> Double
    let fPrime: (Double) -> Double
}

private let availableFunctions: [MeanThmFunction] = [
    MeanThmFunction(
        name:   "cos(3x)",
        f:      { x in cos(3 * x) },
        fPrime: { x in sin(3 * x) / 3 }
    ),
    MeanThmFunction(
        name:   "sin(x)",
        f:      { x in sin(x) },
        fPrime: { x in -cos(x) }
    ),
    MeanThmFunction(
        name:   "x² / 4",
        f:      { x in pow(x, 2) / 4 },
        fPrime: { x in pow(x, 3) / 12 }
    ),
    MeanThmFunction(
        name:   "0.5x + sin(2x)",
        f:      { x in 0.5 * x + sin(2 * x) },
        fPrime: { x in pow(x, 2) / 4 - cos(2 * x) / 2 }
    ),
]

// MARK: - SectionsShape

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

// MARK: - MeanThmView

struct MeanThmView: View {

    @State private var sectionCount: Double = 6
    @State private var selectedIndex        = 0

    let scale:     Double  = 100
    let graphSize: CGFloat = 300

    var body: some View {
        let fn = availableFunctions[selectedIndex]
        let step = graphSize / CGFloat(sectionCount)

        VStack(spacing: 14) {

            Text("Mean Value Theorem (integral form)")
                .font(.caption)
                .foregroundStyle(.secondary)

            ZStack {
                GridDrawing(step: 10)
                    .stroke(Color.blue.opacity(0.5), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal)
                    .stroke(Color.blue.opacity(0.8), lineWidth: 1.5)
                AxisDrawing(axis: .vertical)
                    .stroke(Color.blue.opacity(0.8), lineWidth: 1.5)

                FunctionDrawing(f: fn.f, integrF: fn.fPrime, scale: scale)
                    .stroke(lineWidth: 1.5)

                SectionsShape(step: step, f: fn.f, fIntegr: fn.fPrime, scale: scale)
                    .fill(Color.blue.opacity(0.2))
                SectionsShape(step: step, f: fn.f, fIntegr: fn.fPrime, scale: scale)
                    .stroke(Color.blue, lineWidth: 1)
            }
            .frame(width: graphSize, height: graphSize)
            .clipped()

            Picker("Function", selection: $selectedIndex) {
                ForEach(availableFunctions.indices, id: \.self) { i in
                    Text(availableFunctions[i].name).tag(i)
                }
            }
            .pickerStyle(.menu)
            .frame(width: graphSize)

            // Slider volontairement plus étroit que l'écran : un slider qui
            // touche les bords entre en conflit avec le geste de retour
            // (swipe depuis le bord) quand on arrive d'une autre page.
            VStack(alignment: .leading, spacing: 4) {
                Text("Number of sections: \(Int(sectionCount))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Slider(value: $sectionCount, in: 2...60, step: 1)
            }
            .frame(width: graphSize - 40)
        }
        .padding()
    }
}

#Preview {
    MeanThmView()
        .preferredColorScheme(.dark)
}
