
import SwiftUI

private func factorial(_ n: Int) -> Double {
    n <= 1 ? 1 : Double(n) * factorial(n - 1)
}

// Trace une courbe mais casse le trait au lieu de le relier
// quand deux points consécutifs sautent trop — évite les faux
// pics verticaux près des asymptotes ou des bords de domaine.
private struct BreakingCurve: Shape {
    let f: (Double) -> Double
    let scale: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        var previousY: CGFloat? = nil
        let jumpThreshold: CGFloat = 20

        for x in stride(from: rect.minX, to: rect.maxX, by: 1.0) {
            let xMath = (x - rect.width / 2) / scale
            let raw = f(xMath)
            guard raw.isFinite else { previousY = nil; continue }
            let y = -CGFloat(raw * scale) + rect.height / 2

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

private struct TaylorFunction: Identifiable {
    let id: Int
    let name: String
    let f: (Double) -> Double
    let derivativesAtZero: [Double]  // f⁽ᵏ⁾(0) pour k = 0...6
}

private let taylorFunctions: [TaylorFunction] = [
    TaylorFunction(
        id: 0, name: "sin(x)", f: { sin($0) },
        derivativesAtZero: [0, 1, 0, -1, 0, 1, 0]
    ),
    TaylorFunction(
        id: 1, name: "cos(x)", f: { cos($0) },
        derivativesAtZero: [1, 0, -1, 0, 1, 0, -1]
    ),
    TaylorFunction(
        id: 2, name: "eˣ", f: { exp($0) },
        derivativesAtZero: [1, 1, 1, 1, 1, 1, 1]
    ),
    TaylorFunction(
        id: 3, name: "ln(1+x)",
        f: { x in x > -1 ? log(1 + x) : Double.nan },
        derivativesAtZero: [0, 1, -1, 2, -6, 24, -120]
    ),
]

struct TaylorView: View {

    @State private var functionIndex = 0
    @State private var order = 3
    let graphSize: CGFloat = 300
    let scale: Double = 25
    let threshold = 0.1

    private var current: TaylorFunction { taylorFunctions[functionIndex] }

    func taylor(_ x: Double) -> Double {
        var sum = 0.0
        for k in 0...order {
            sum += current.derivativesAtZero[k] * pow(x, Double(k)) / factorial(k)
        }
        return sum
    }

    func error(_ x: Double) -> Double {
        let fx = current.f(x)
        guard fx.isFinite else { return Double.nan }
        return abs(fx - taylor(x))
    }
    
    private func gcd(_ a: Int, _ b: Int) -> Int { b == 0 ? a : gcd(b, a % b) }

    private let superscriptDigits: [Character: Character] = [
        "0": "⁰", "1": "¹", "2": "²", "3": "³", "4": "⁴",
        "5": "⁵", "6": "⁶", "7": "⁷", "8": "⁸", "9": "⁹"
    ]
    private func superscript(_ n: Int) -> String {
        String(String(n).map { superscriptDigits[$0] ?? $0 })
    }

    var polynomialString: String {
        var parts: [String] = []
        for k in 0...order {
            let numRaw = Int(current.derivativesAtZero[k])
            guard numRaw != 0 else { continue }
            let denRaw = Int(factorial(k))
            let g = gcd(abs(numRaw), denRaw)
            let num = numRaw / g
            let den = denRaw / g

            let sign = num < 0 ? "−" : (parts.isEmpty ? "" : "+")
            let magNum = abs(num)

            let coeffStr: String
            if den == 1 {
                coeffStr = (magNum == 1 && k != 0) ? "" : "\(magNum)"
            } else {
                coeffStr = "\(magNum)/\(den)"
            }

            let powerStr = k == 0 ? "" : (k == 1 ? "x" : "x" + superscript(k))
            parts.append("\(sign)\(coeffStr)\(powerStr)")
        }
        return "T\(order)(x) = " + parts.joined(separator: " ")
    }

    var body: some View {
        VStack(spacing: 12) {

            Picker("Function", selection: $functionIndex) {
                ForEach(taylorFunctions) { fn in
                    Text(fn.name).tag(fn.id)
                }
            }
            .pickerStyle(.menu)

            ZStack {
                GridDrawing(step: 10).stroke(Color.blue.opacity(0.5), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal).stroke(Color.blue.opacity(0.8), lineWidth: 1.5)
                AxisDrawing(axis: .vertical).stroke(Color.blue.opacity(0.8), lineWidth: 1.5)

                BreakingCurve(f: current.f, scale: scale)
                    .stroke(Color.blue, lineWidth: 2)
                BreakingCurve(f: taylor, scale: scale)
                    .stroke(Color.orange, lineWidth: 2)
            }
            .frame(width: graphSize, height: graphSize / 2)
            .background(Color(.systemBackground))
            .clipped()

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Rectangle().fill(Color.blue).frame(width: 16, height: 2)
                    Text(current.name).font(.caption)
                }
                HStack(spacing: 4) {
                    Rectangle().fill(Color.orange).frame(width: 16, height: 2)
                    Text("T\(order)(x)").font(.caption)
                }
            }

            Text(polynomialString)
                .font(.system(size: 14, design: .monospaced))
                .foregroundStyle(.orange)
                .multilineTextAlignment(.center)

            ZStack {
                GridDrawing(step: 10).stroke(Color.blue.opacity(0.5), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal).stroke(Color.blue.opacity(0.8), lineWidth: 1.5)
                AxisDrawing(axis: .vertical).stroke(Color.blue.opacity(0.8), lineWidth: 1.5)

                BreakingCurve(f: { _ in threshold }, scale: scale)
                    .stroke(Color.red.opacity(0.7), style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                BreakingCurve(f: error, scale: scale)
                    .stroke(Color.red, lineWidth: 1.5)
            }
            .frame(width: graphSize, height: graphSize / 2)
            .background(Color(.systemBackground))
            .clipped()

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Rectangle().fill(Color.red).frame(width: 16, height: 2)
                    Text("|f(x) − T\(order)(x)|").font(.caption)
                }
                HStack(spacing: 4) {
                    Rectangle().fill(Color.red.opacity(0.7)).frame(width: 16, height: 2)
                    Text("threshold 0.1").font(.caption)
                }
            }

            Slider(
                value: Binding(get: { Double(order) }, set: { order = Int($0) }),
                in: 1...6, step: 1
            )
            Text("Order: \(order)")
        }
        .padding(.horizontal)
    }
}

#Preview {
    TaylorView()
        .preferredColorScheme(.dark)
}
