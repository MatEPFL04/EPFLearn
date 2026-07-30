////
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

    /// Pure math computation — no screen coordinates involved
    func area(from xStart: Double, to xEnd: Double, subdivisions: Int) -> Double {
        let dx = (xEnd - xStart) / Double(subdivisions)
        var total = 0.0
        for i in 0..<subdivisions {
            let xMath = xStart + Double(i) * dx
            var bestYet = f(xMath)
            for v in stride(from: xMath, to: xMath + dx, by: 0.001) {
                let new = f(v)
                bestYet = isDarbouxInf ? min(bestYet, new) : max(bestYet, new)
            }
            total += dx * bestYet
        }
        return total
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cs = MathCoordinateSpace(rect: rect, scale: scale)

        for x in stride(from: rect.minX, to: rect.maxX, by: step) {
            let xMath = cs.toMath(x: x)

            // Work in math space — clear min/max semantics
            var bestYet = f(xMath)
            for v in stride(from: x, to: x + step, by: 0.1) {
                let new = f(cs.toMath(x: v))
                bestYet = isDarbouxInf ? min(bestYet, new) : max(bestYet, new)
            }

            // Convert to screen only when drawing
            let yScreen = cs.toScreen(y: bestYet)
            path.move(to:    CGPoint(x: x,        y: rect.midY))
            path.addLine(to: CGPoint(x: x,        y: yScreen))
            path.addLine(to: CGPoint(x: x + step, y: yScreen))
            path.addLine(to: CGPoint(x: x + step, y: rect.midY))
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
        let cs = MathCoordinateSpace(rect: rect, scale: scale)
        for x in stride(from: rect.minX, to: rect.maxX, by: 0.01) {
            let point = cs.toScreen(x: cs.toMath(x: x), y: f(cs.toMath(x: x)))
            if x == rect.minX {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        return path
    }

    /// Returns the exact integral value over the visible x range
    func integralValue(in rect: CGRect) -> Double {
        let cs = MathCoordinateSpace(rect: rect, scale: scale)
        let xStart = cs.toMath(x: rect.minX)
        let xEnd   = cs.toMath(x: rect.maxX)
        return integrF(xEnd) - integrF(xStart)
    }

    static func make(_ type: MathFunctionType, scale: Double) -> FunctionDrawing {
        switch type {
        case .affine:
            return FunctionDrawing(
                f:      { x in 2 * x + 5 },
                integrF: { x in pow(x, 2) + 5 * x },
                scale: scale
            )
        case .cubic:
            return FunctionDrawing(
                f:      { x in 0.01 * pow(x, 3) },
                integrF: { x in 0.01 * pow(x, 4) / 4 },
                scale: scale
            )
        case .sine:
            return FunctionDrawing(
                f:      { x in  10 * sin(0.2 * x) },
                integrF: { x in -50 * cos(0.2 * x) },
                scale: scale
            )
        case .cosine:
            return FunctionDrawing(
                f:      { x in 10 * cos(0.2 * x) },
                integrF: { x in  50 * sin(0.2 * x) },
                scale: scale
            )

        case .dirichlet:
            let period = 0.01
            return FunctionDrawing(
                f: { x in
                    Int(floor(x / period)) % 2 == 0 ? 1.0 : 0.0
                },
                integrF: { _ in .nan },
                scale: scale
            )
        case .constant:
            return FunctionDrawing(
                f:      { _ in 5 },
                integrF: { x in 5 * x },
                scale: scale
            )
        }
    }
}

enum MathFunctionType: String, CaseIterable {
    case constant  = "f(x) = 5"
    case affine    = "f(x) = 2x + 5"
    case cubic     = "f(x) = x³"
    case sine      = "f(x) = sin(x)"
    case cosine    = "f(x) = cos(x)"
    case dirichlet = "f(x) = 1 if x ∈ ℚ, 0 otherwise"
}

struct DarbouxView: View {
    private let baseScale: Double = 10
    private var scale: Double { baseScale * Double(graphSize) / 300 }
    @State private var sectionCount: Double = 20
    @State private var selectedFunction = MathFunctionType.sine

    @State private var graphSize: CGFloat = 300

    var graphRect: CGRect {
        CGRect(x: 0, y: 0, width: graphSize, height: graphSize)
    }

    var mathRange: (from: Double, to: Double) {
        let cs = MathCoordinateSpace(size: graphSize, scale: scale)
        return (cs.toMath(x: 0), cs.toMath(x: graphSize))
    }
    
    init(initial: MathFunctionType = .sine) {
            _selectedFunction = State(initialValue: initial)
        }

    var body: some View {
        // step = largeur en pixels d'une subdivision, dérivée du nombre de
        // sections choisi par le slider — pas l'inverse. Sinon le slider
        // "descend" quand on veut plus de sections, ce qui est contre-intuitif.
        let step = graphSize / CGFloat(sectionCount)
        let currentFunction = FunctionDrawing.make(selectedFunction, scale: scale)
        let darbouxSup = Darboux(step: step, f: currentFunction.f, isDarbouxInf: false, scale: scale)
        let darbouxInf = Darboux(step: step, f: currentFunction.f, isDarbouxInf: true, scale: scale)

        VStack(spacing: 14) {

            Text("Darboux sums vs the Riemann integral")
                .font(.caption)
                .foregroundStyle(.secondary)

            ZStack {
                GridDrawing(step: 10)
                    .stroke(Color.blue.opacity(0.5), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal)
                    .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                AxisDrawing(axis: .vertical)
                    .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                currentFunction
                    .stroke(lineWidth: 1)
                darbouxSup
                    .stroke(Color.red, lineWidth: 1)
                darbouxInf
                    .stroke(Color.blue, lineWidth: 1)
            }
            .frame(width: graphSize, height: graphSize)
            .clipped()

            Picker("Function", selection: $selectedFunction) {
                ForEach(MathFunctionType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.menu)
            .frame(width: graphSize)

            VStack(alignment: .leading, spacing: 6) {
                let n = Int(sectionCount)
                if selectedFunction == .dirichlet {
                    Text("Integral: does not exist (f is not Riemann integrable)")
                        .foregroundStyle(.orange)
                } else {
                    Text("Integral: \(currentFunction.integralValue(in: graphRect), specifier: "%.2f")")
                }
                Text("Darboux sup: \(darbouxSup.area(from: mathRange.from, to: mathRange.to, subdivisions: n), specifier: "%.2f")")
                Text("Darboux inf: \(darbouxInf.area(from: mathRange.from, to: mathRange.to, subdivisions: n), specifier: "%.2f")")
            }
            .font(.system(.footnote, design: .monospaced))
            .padding()
            .frame(width: graphSize, alignment: .leading)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text("Number of sections")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.blue)
                Slider(value: $sectionCount, in: 2...100, step: 1)
                    .tint(.blue)
                Text("\(Int(sectionCount)) sections")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .frame(width: graphSize - 40)
        }
        .padding()
        .adaptivePlot($graphSize)
    }
}
#Preview {
    DarbouxView()
        .preferredColorScheme(.dark)
}
