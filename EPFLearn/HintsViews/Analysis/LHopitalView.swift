import SwiftUI

private struct LHopitalCase: Identifiable {
    let id: Int
    let chip: String
    let fLabel: String
    let gLabel: String
    let f: (Double) -> Double
    let g: (Double) -> Double
    let fSlope: Double?   // f'(0), nil si la pente n'existe pas / oscille
    let gSlope: Double
    let note: String
}

private let lhopitalCases: [LHopitalCase] = [
    LHopitalCase(
        id: 0, chip: "sin(x)/x",
        fLabel: "f(x) = sin x", gLabel: "g(x) = x",
        f: { sin($0) }, g: { $0 },
        fSlope: 1, gSlope: 1,
        note: "Same slope at 0 → ratio = 1."
    ),
    LHopitalCase(
        id: 1, chip: "sin(2x)/sin(3x)",
        fLabel: "f(x) = sin 2x", gLabel: "g(x) = sin 3x",
        f: { sin(2 * $0) }, g: { sin(3 * $0) },
        fSlope: 2, gSlope: 3,
        note: "f twice as steep, g three times → ratio = 2/3."
    ),
    LHopitalCase(
        id: 2, chip: "x²sin(1/x) / sin(x)",
        fLabel: "f(x) = x²sin(1/x)", gLabel: "g(x) = sin x",
        f: { x in x == 0 ? 0 : pow(x, 2) * sin(1 / x) }, g: { sin($0) },
        fSlope: nil, gSlope: 1,
        note: "g flattens onto its tangent (slope 1), but f keeps oscillating no matter the zoom, no slope to read. L'Hôpital gives no answer."
    ),
]

struct LHopitalView: View {

    @State private var selected = 0

    // Zoom exposé au slider sur une échelle 0...1, puis mappé de façon
    // exponentielle sur la plage réelle de zoom. Une échelle linéaire
    // saturait visuellement dès ~30% du slider (sin(x) ≈ x pour x petit),
    // rendant les 70% restants inutiles.
    // minZoom = 15 → demi-largeur visible ≈ 10 unités math, soit ~3 périodes
    // complètes de sin(x) (période 2π ≈ 6.28) à l'écran le plus large.
    @State private var zoomT: Double = 0.0
    private let minZoom: Double = 15
    private let maxZoom: Double = 2000
    private var zoom: Double {
        minZoom * pow(maxZoom / minZoom, zoomT)
    }

    @State private var graphSize: CGFloat = 300

    private var current: LHopitalCase { lhopitalCases[selected] }

    var body: some View {
        VStack(spacing: 14) {

            VStack(alignment: .leading, spacing: 2) {
                Text("L'Hôpital's Rule").font(.headline)
                Text("\(current.chip)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            ZStack {
                GridDrawing(step: 10).stroke(Color.blue.opacity(0.2), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal).stroke(Color.blue.opacity(0.5), lineWidth: 1)
                AxisDrawing(axis: .vertical).stroke(Color.blue.opacity(0.5), lineWidth: 1)

                FunctionDrawing(f: current.g, integrF: { _ in 0 }, scale: zoom)
                    .stroke(Color.blue, lineWidth: 2)
                FunctionDrawing(f: current.f, integrF: { _ in 0 }, scale: zoom)
                    .stroke(Color.red, lineWidth: current.fSlope == nil ? 1 : 2)
            }
            .frame(width: graphSize, height: graphSize)
            .padding(6)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Picker("Function pair", selection: $selected) {
                ForEach(lhopitalCases) { c in
                    Text(c.chip).tag(c.id)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(width: graphSize)

            // Légende sous le graphe (plus de superposition avec les courbes),
            // avec le nom explicite de f et g plutôt que juste "slope X".
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Rectangle().fill(Color.red).frame(width: 20, height: 3)
                    Text(current.fLabel)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(.red)
                    Spacer()
                    Text(current.fSlope == nil ? "no slope" : "slope \(current.fSlope!, specifier: "%.0f")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 8) {
                    Rectangle().fill(Color.blue).frame(width: 20, height: 3)
                    Text(current.gLabel)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(.blue)
                    Spacer()
                    Text("slope \(current.gSlope, specifier: "%.0f")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(10)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(width: graphSize)

            VStack(alignment: .leading, spacing: 4) {
                Text("Zoom (x\(zoom, specifier: "%.0f"))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                HStack {
                    Text("wide view").font(.caption2).foregroundStyle(.secondary)
                    Slider(value: $zoomT, in: 0...1)
                    Text("zoomed").font(.caption2).foregroundStyle(.secondary)
                }
            }
            .frame(width: graphSize)

            if let fSlope = current.fSlope {
                Text("f′(0)/g′(0) = \(fSlope, specifier: "%.0f")/\(current.gSlope, specifier: "%.0f") = \(fSlope / current.gSlope, specifier: "%.3f")")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.green)
            } else {
                Text("f′(0) doesn't exist, so L'Hôpital gives no answer here")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.red)
            }

            Text(current.note)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .adaptivePlot($graphSize)
    }
}

#Preview {
    LHopitalView()
}
