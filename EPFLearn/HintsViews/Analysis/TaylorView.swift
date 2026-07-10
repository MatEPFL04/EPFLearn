import SwiftUI
 
struct TaylorView: View {
 
    let graphSize: CGFloat = 300
    let scale: Double      = 50
    @State private var order = 1
 
 
    func taylor(_ x: Double) -> Double {
        switch order {
        case 1, 2: return x
        case 3, 4: return x - pow(x, 3) / 6
        case 5:    return x - pow(x, 3) / 6 + pow(x, 5) / 120
        default:   return x
        }
    }
 
    func taylorLabel(_ order: Int) -> String {
        switch order {
        case 1, 2: return "x"
        case 3, 4: return "x − x³/3!"
        case 5:    return "x − x³/3! + x⁵/5!"
        default:   return ""
        }
    }
 
    func error(_ x: Double) -> Double { abs(sin(x) - taylor(x)) }
 
    // MARK: - Body
 
    var body: some View {
        VStack(spacing: 8) {
 
            // Graphe 1 : sin vs Taylor
            ZStack {
                GridDrawing(step: 10)
                    .stroke(Color.blue.opacity(0.5), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal)
                    .stroke(Color.blue.opacity(0.8), lineWidth: 1.5)
                AxisDrawing(axis: .vertical)
                    .stroke(Color.blue.opacity(0.8), lineWidth: 1.5)
 
                FunctionDrawing(f: { x in sin(x) }, integrF: { _ in 0 }, scale: scale)
                    .stroke(Color.blue, lineWidth: 2)
                FunctionDrawing(f: { x in taylor(x) }, integrF: { _ in 0 }, scale: scale)
                    .stroke(Color.orange, lineWidth: 2)
            }
            .frame(width: graphSize, height: graphSize / 2)
            .background(Color(.systemBackground))
            .clipped()
 
            // Légende
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Rectangle().fill(Color.blue).frame(width: 16, height: 2)
                    Text("sin(x)").font(.caption)
                }
                HStack(spacing: 4) {
                    Rectangle().fill(Color.orange).frame(width: 16, height: 2)
                    Text("T\(order)(x) = \(taylorLabel(order))").font(.caption)
                }
            }
 
            // Graphe 2 : erreur |sin - Taylor|
            ZStack {
                GridDrawing(step: 10)
                    .stroke(Color.blue.opacity(0.5), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal)
                    .stroke(Color.blue.opacity(0.8), lineWidth: 1.5)
                AxisDrawing(axis: .vertical)
                    .stroke(Color.blue.opacity(0.8), lineWidth: 1.5)
 
                FunctionDrawing(f: { _ in 0.1 }, integrF: { _ in 0 }, scale: scale)
                    .stroke(Color.red.opacity(0.7),
                            style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                FunctionDrawing(f: { x in error(x) }, integrF: { _ in 0 }, scale: scale)
                    .stroke(Color.red, lineWidth: 1.5)
            }
            .frame(width: graphSize, height: graphSize / 2)
            .background(Color(.systemBackground))
            .clipped()
 
            // Légende erreur
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Rectangle().fill(Color.red).frame(width: 16, height: 2)
                    Text("|sin(x) − T\(order)(x)|").font(.caption)
                }
                HStack(spacing: 4) {
                    Rectangle().fill(Color.red.opacity(0.7)).frame(width: 16, height: 2)
                    Text("seuil 0.1").font(.caption)
                }
            }
 
            Slider(
                value: Binding(get: { Double(order) }, set: { order = Int($0) }),
                in: 1...5, step: 1
            )
            Text("Ordre : \(order)")
        }
    }
}
 
#Preview {
    TaylorView()
        .preferredColorScheme(.dark)
}
