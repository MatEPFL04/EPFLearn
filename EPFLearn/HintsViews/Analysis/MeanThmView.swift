//
//  MeanThmView.swift
//  LearnViz
//
//  Mean value theorem for integrals. Each rectangle's height is the average
//  value of f on its piece, so its top edge always meets the curve inside that
//  piece. Those meeting points are the c the theorem promises, and they are
//  drawn: counting them is the whole point of the view.
//

import SwiftUI

// MARK: - Functions

private struct MeanThmFunction {
    let name: String
    let f: @Sendable (Double) -> Double
    let antiderivative: @Sendable (Double) -> Double
}

enum MeanThmPreset: String, CaseIterable, Identifiable {
    case increasing
    case cos3x
    case sine
    case square
    case xAndSine

    var id: Self { self }

    var displayName: String {
        switch self {
        case .increasing: return "x³/8 + x/2"
        case .cos3x:      return "cos(3x)"
        case .sine:       return "sin(x)"
        case .square:     return "x² / 4"
        case .xAndSine:   return "0.5x + sin(2x)"
        }
    }

    fileprivate var function: MeanThmFunction {
        switch self {
        case .increasing:
            // Strictly increasing on the whole window: 3x²/8 + 1/2 is never
            // zero. The curve never returns to a height it has left, so every
            // piece holds exactly one c.
            return MeanThmFunction(
                name: displayName,
                f: { x in pow(x, 3) / 8 + x / 2 },
                antiderivative: { x in pow(x, 4) / 32 + x * x / 4 }
            )
        case .cos3x:
            return MeanThmFunction(
                name: displayName,
                f: { x in cos(3 * x) },
                antiderivative: { x in sin(3 * x) / 3 }
            )
        case .sine:
            return MeanThmFunction(
                name: displayName,
                f: { x in sin(x) },
                antiderivative: { x in -cos(x) }
            )
        case .square:
            return MeanThmFunction(
                name: displayName,
                f: { x in x * x / 4 },
                antiderivative: { x in pow(x, 3) / 12 }
            )
        case .xAndSine:
            return MeanThmFunction(
                name: displayName,
                f: { x in 0.5 * x + sin(2 * x) },
                antiderivative: { x in x * x / 4 - cos(2 * x) / 2 }
            )
        }
    }
}

// MARK: - Pieces

/// One slice of the subdivision, with its average height and every point where
/// the curve actually reaches that height.
private struct Piece: Identifiable {
    let id: Int
    let xStart: Double
    let xEnd: Double
    let height: Double
    let roots: [Double]

    var area: Double { height * (xEnd - xStart) }
}

/// Every solution of f(x) = level on [a, b], found by scanning for sign
/// changes then bisecting. Returning all of them is what makes the uniqueness
/// question answerable by eye.
private func crossings(
    of f: (Double) -> Double,
    level: Double,
    from a: Double,
    to b: Double
) -> [Double] {
    let samples = 240
    var roots: [Double] = []
    var prevX = a
    var prevG = f(a) - level

    for i in 1...samples {
        let x = a + (b - a) * Double(i) / Double(samples)
        let g = f(x) - level

        if prevG * g < 0 {
            var lo = prevX, hi = x
            for _ in 0..<40 {
                let mid = (lo + hi) / 2
                if (f(lo) - level) * (f(mid) - level) <= 0 { hi = mid } else { lo = mid }
            }
            roots.append((lo + hi) / 2)
        } else if g == 0 {
            roots.append(x)
        }

        prevX = x
        prevG = g
    }
    return roots
}

private func buildPieces(
    _ fn: MeanThmFunction,
    from a: Double,
    to b: Double,
    count: Int
) -> [Piece] {
    let dx = (b - a) / Double(count)
    return (0..<count).map { k in
        let x0 = a + Double(k) * dx
        let x1 = x0 + dx
        // Average value straight from the antiderivative: no quadrature error.
        let height = (fn.antiderivative(x1) - fn.antiderivative(x0)) / dx
        return Piece(
            id: k,
            xStart: x0,
            xEnd: x1,
            height: height,
            roots: crossings(of: fn.f, level: height, from: x0, to: x1)
        )
    }
}

// MARK: - Shapes

private struct SectionsShape: Shape {
    let pieces: [Piece]
    let scale: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cs = MathCoordinateSpace(rect: rect, scale: scale)
        for piece in pieces {
            let left  = cs.toScreen(x: piece.xStart, y: 0).x
            let right = cs.toScreen(x: piece.xEnd,   y: 0).x
            let top   = cs.toScreen(x: piece.xStart, y: piece.height).y
            guard top >= rect.minY && top <= rect.maxY else { continue }
            path.move(to:    CGPoint(x: left,  y: rect.midY))
            path.addLine(to: CGPoint(x: left,  y: top))
            path.addLine(to: CGPoint(x: right, y: top))
            path.addLine(to: CGPoint(x: right, y: rect.midY))
            path.closeSubpath()
        }
        return path
    }
}

// MARK: - View

struct MeanThmView: View {

    @State private var preset: MeanThmPreset
    @State private var sectionCount: Double = 4
    @State private var graphSize: CGFloat = 300

    private let baseScale: Double = 100
    private var scale: Double { baseScale * Double(graphSize) / 300 }

    init(_ initial: MeanThmPreset = .cos3x) {
        _preset = State(initialValue: initial)
    }

    var body: some View {
        let fn = preset.function
        let cs = MathCoordinateSpace(size: graphSize, scale: scale)
        let a = cs.toMath(x: 0)
        let b = cs.toMath(x: graphSize)
        let pieces = buildPieces(fn, from: a, to: b, count: Int(sectionCount))

        let rectangleTotal = pieces.reduce(0) { $0 + $1.area }
        let integral = fn.antiderivative(b) - fn.antiderivative(a)
        let rootCount = pieces.reduce(0) { $0 + $1.roots.count }
        let dotRadius: CGFloat = sectionCount <= 12 ? 5 : 3

        VStack(spacing: 14) {
            
            Text("Mean Value Theorem (Integrals)").font(.headline)


            ZStack {
                GridDrawing(step: scale)
                    .stroke(Color.blue.opacity(0.35), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal)
                    .stroke(Color.primary.opacity(0.7), lineWidth: 1.5)
                AxisDrawing(axis: .vertical)
                    .stroke(Color.primary.opacity(0.7), lineWidth: 1.5)

                SectionsShape(pieces: pieces, scale: scale)
                    .fill(Color.blue.opacity(0.2))
                SectionsShape(pieces: pieces, scale: scale)
                    .stroke(Color.blue, lineWidth: 1)

                FunctionDrawing(f: fn.f, integrF: fn.antiderivative, scale: scale)
                    .stroke(lineWidth: 1.5)

                // The c the theorem promises: where each top edge meets the curve.
                ForEach(pieces) { piece in
                    ForEach(Array(piece.roots.enumerated()), id: \.offset) { _, c in
                        Circle()
                            .fill(Color.orange)
                            .frame(width: dotRadius * 2, height: dotRadius * 2)
                            .position(cs.toScreen(x: c, y: piece.height))
                    }
                }
            }
            .frame(width: graphSize, height: graphSize)
            .clipped()

            HStack(spacing: 5) {
                Circle().fill(Color.orange).frame(width: 6, height: 6)
                Text("each c where the top edge meets the curve")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)

            Picker("Function", selection: $preset) {
                ForEach(MeanThmPreset.allCases) { option in
                    Text(option.displayName).tag(option)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(width: graphSize)

            VStack(alignment: .leading, spacing: 4) {
                Text("Number of sections: \(Int(sectionCount))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Slider(value: $sectionCount, in: 2...40, step: 1)
            }
            .frame(width: graphSize - 40)
        }
        .padding()
        .adaptivePlot($graphSize)
    }
}

#Preview {
    ScrollView { MeanThmView() }
}
