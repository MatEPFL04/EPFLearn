//
//  TaylorView.swift
//  EPFLearn
//
//  Created by Mat on 07.04.2026.
//

import SwiftUI

struct TaylorView: View {

    let graphSize: CGFloat = 300
    let scale: Double = 50  // pixels par radian
    @State private var order = 1

    func taylor1(_ x: Double) -> Double { x }
    func taylor3(_ x: Double) -> Double { x - pow(x,3) / 6 }
    func taylor5(_ x: Double) -> Double { x - pow(x,3)/6 + pow(x,5)/120 }
    
    func taylor(_ x: Double) -> Double {
        switch order {
        case 1:
            return taylor1(x)
        case 2:
            return taylor1(x)
        case 3:
            return taylor3(x)
        case 4:
            return taylor3(x)
        case 5:
            return taylor5(x)
        default:
            return -1
        }
    }

    // Erreur absolue
    func error(_ x: Double) -> Double { abs(sin(x) - taylor(x)) }
    
    func taylorFor(_ order: Int) -> String {
        switch order {
        case 1:
            return "x"
        case 2:
            return "x"
        case 3:
            return "x - pow(x,3)/3!"
        case 4:
            return "x - pow(x,3)"
        case 5:
            return "x - pow(x,3)/3! + pow(x,5)/5!"
        default:
            return ""
        }
    }
    

    var body: some View {
        VStack(spacing: 8) {

            // Graphe 1 : sin vs T3
            ZStack {
                GridDrawing(step: 10)
                    .stroke(Color.blue.opacity(0.5), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal).stroke(Color.blue.opacity(0.8), lineWidth: 1.5)
                AxisDrawing(axis: .vertical).stroke(Color.blue.opacity(0.8), lineWidth: 1.5)

                // sin(x) en bleu
                FunctionDrawing(f: { x in scale * sin(x) }, integrF: { x in 0 }, scale: scale)
                    .stroke(Color.blue, lineWidth: 2)

                // T3(x) en orange
                FunctionDrawing(f: { x in scale * taylor(x) }, integrF: { x in 0 }, scale: scale)
                    .stroke(Color.orange, lineWidth: 2)
            }
            .frame(width: graphSize, height: graphSize / 2)
            .clipped()

            // Légende
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Rectangle().fill(Color.blue).frame(width: 16, height: 2)
                    Text("sin(x)").font(.caption)
                }
                HStack(spacing: 4) {
                    Rectangle().fill(Color.orange).frame(width: 16, height: 2)
                    Text("T\(order)(x) = \(taylorFor(order))").font(.caption)
                }
            }

            // Graphe 2 : erreur |sin - T3|
            ZStack {
                GridDrawing(step: 10)
                    .stroke(Color.blue.opacity(0.5), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal).stroke(Color.blue.opacity(0.8), lineWidth: 1.5)
                AxisDrawing(axis: .vertical).stroke(Color.blue.opacity(0.8), lineWidth: 1.5)

                // Seuil 0.1 en rouge pointillé
                FunctionDrawing(f: { _ in scale * 0.1 }, integrF: { x in 0 }, scale: scale)
                    .stroke(Color.red.opacity(0.7),
                            style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))

                // Courbe erreur en rouge
                FunctionDrawing(f: { x in scale * error(x) }, integrF: { x in 0 }, scale: scale)
                    .stroke(Color.red, lineWidth: 1.5)
            }
            .frame(width: graphSize, height: graphSize / 2)
            .clipped()

            // Légende erreur
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Rectangle().fill(Color.red).frame(width: 16, height: 2)
                    Text("|sin(x) −T\(order)(x)|").font(.caption)
                }
                HStack(spacing: 4) {
                    Rectangle().fill(Color.red.opacity(0.7)).frame(width: 16, height: 2)
                    Text("seuil 0.1").font(.caption)
                }
            }
            Slider(value: Binding(
                get: { Double(order) },
                set: { order = Int($0) }
            ), in: 1...5, step: 1)
            Text("Ordre : \(order)")
        }
    }
}

#Preview {
    TaylorView()
}//
//  TaylorView.swift
//  EPFLearn
//
//  Created by Mat on 07.04.2026.
//

