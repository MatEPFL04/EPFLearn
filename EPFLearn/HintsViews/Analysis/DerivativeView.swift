//
//  DerivativeView.swift
//  EPFLearn
//
//  Created by Mat on 05.04.2026.
//

import SwiftUI

// MARK: - Modèle de fonction

private struct MathFunction {
    let name:       String
    let f:          (Double) -> Double
    let fPrime:     (Double) -> Double
    let derivative: (Double) -> Double
}

private let availableFunctions: [MathFunction] = [
    MathFunction(
        name:       "cos(x) + x/2",
        f:          { x in cos(x) + x / 2 },
        fPrime:     { x in sin(x) + pow(x, 2) / 4 },
        derivative: { x in -sin(x) + 0.5 }
    ),
    MathFunction(
        name:       "|x|",
        f:          { x in abs(x) },
        fPrime:     { x in x >= 0 ? pow(x, 2) / 2 : -pow(x, 2) / 2 },
        derivative: { x in x >= 0 ? 1.0 : -1.0 }
    ),
    MathFunction(
        name:       "x⁴ − 2x²",
        f:          { x in pow(x, 4) - 2 * pow(x, 2) },
        fPrime:     { x in pow(x, 5) / 5 - 2 * pow(x, 3) / 3 },
        derivative: { x in 4 * pow(x, 3) - 4 * x }
    ),
]

// MARK: - SlopeView

struct SlopeView: Shape {
    var xOffset:    Double
    var xOffsetEnd: Double
    let f:          @Sendable (Double) -> Double
    let scale:      Double

    func path(in rect: CGRect) -> Path {
        let cs = MathCoordinateSpace(rect: rect, scale: scale)
        var path = Path()
        let xMathStart = cs.toMath(x: rect.minX + xOffset)
        let xMathEnd   = cs.toMath(x: rect.maxX - xOffsetEnd)
        path.move(to:    cs.toScreen(x: xMathStart, y: f(xMathStart)))
        path.addLine(to: cs.toScreen(x: xMathEnd,   y: f(xMathEnd)))
        return path
    }
}

// MARK: - DerivateView

struct DerivateView: View {

    @State private var xOffset       = 0.0
    @State private var xOffsetEnd    = 0.0
    @State private var selectedIndex = 0

    let scale:     Double  = 10
    let graphSize: CGFloat = 300

    var body: some View {
        let fn = availableFunctions[selectedIndex]
        let cs = MathCoordinateSpace(size: graphSize, scale: scale)

        let xMathStart = cs.toMath(x: xOffset)
        let xMathEnd   = cs.toMath(x: graphSize - xOffsetEnd)

        let slope         = fn.derivative(xMathStart)
        let tangent:      (Double) -> Double = { x in fn.f(xMathStart) + slope * (x - xMathStart) }
        let tangentPrime: (Double) -> Double = { _ in slope }

        VStack(spacing: 12) {
            ZStack {
                GridDrawing(step: 10)
                    .stroke(Color.blue.opacity(0.5), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal)
                    .stroke(Color.blue.opacity(0.8), lineWidth: 1.5)
                AxisDrawing(axis: .vertical)
                    .stroke(Color.blue.opacity(0.8), lineWidth: 1.5)

                FunctionDrawing(f: fn.f, integrF: fn.fPrime, scale: scale)
                    .stroke(lineWidth: 1.5)

                SlopeView(xOffset: xOffset, xOffsetEnd: xOffsetEnd, f: fn.f, scale: scale)
                    .stroke(Color.orange, lineWidth: 1)

                FunctionDrawing(f: tangent, integrF: tangentPrime, scale: scale)
                    .stroke(Color.red, lineWidth: 1)

                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .position(cs.toScreen(x: xMathStart, y: fn.f(xMathStart)))

                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                    .position(cs.toScreen(x: xMathEnd, y: fn.f(xMathEnd)))
            }
            .frame(width: graphSize, height: graphSize)
            .clipped()

            Picker("Fonction", selection: $selectedIndex) {
                ForEach(availableFunctions.indices, id: \.self) { i in
                    Text(availableFunctions[i].name).tag(i)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            Slider(value: $xOffset,    in: 0...graphSize)
            Slider(value: $xOffsetEnd, in: 0...graphSize)
        }
    }
}

#Preview {
    DerivateView()
        .preferredColorScheme(.dark)
}
