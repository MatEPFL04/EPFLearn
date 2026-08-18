//
//  FunctionView.swift
//  EPFLearn
//
//  Created by Mat on 05.04.2026.
//
//  Shared plotting primitives. Every view under HintsViews/Analysis draws its
//  axes and grid from here, so this file must exist for any of them to compile.
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
}
