//
//  LHopitalView.swift
//  EPFLearn
//
 
import SwiftUI
 
struct LHopitalView: View {
 
    let graphSize: CGFloat = 300
    // zoom va de 100 (vue large) à 2000 (très zoomé)
    @State private var zoom: Double = 100
 
    // f(x) = sin(x), g(x) = x  →  sin(x)/x → 1
    // Au zoom maximal, sin(x) ≈ x donc les deux courbes se confondent
    let fColor = Color.red
    let gColor = Color.blue
 
    func xScreen(_ x: Double) -> CGFloat { CGFloat(x * zoom) + graphSize / 2 }
    func yScreen(_ y: Double) -> CGFloat { CGFloat(-y * zoom) + graphSize / 2 }
 
    var body: some View {
        VStack(spacing: 14) {
 
            // Titre dynamique
            Group {
                if zoom < 300 {
                    Text("f(x) = sin(x) et g(x) = x semblent différentes")
                } else if zoom < 800 {
                    Text("En zoomant, les courbes se rapprochent…")
                } else {
                    Text("Totalement zoomé : sin(x) ≈ x → sin(x)/x → 1")
                        .foregroundStyle(.green)
                }
            }
            .font(.caption)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .animation(.easeInOut, value: zoom)
 
            ZStack {
                GridDrawing(step: 10).stroke(Color.blue.opacity(0.2), lineWidth: 0.5)
                AxisDrawing(axis: .horizontal).stroke(Color.blue.opacity(0.5), lineWidth: 1)
                AxisDrawing(axis: .vertical).stroke(Color.blue.opacity(0.5), lineWidth: 1)
 
                // f(x) = sin(x) en rouge
                FunctionDrawing(f: { x in sin(x) }, integrF: { _ in 0 }, scale: zoom)
                    .stroke(fColor, lineWidth: 2)
 
                // g(x) = x en bleu
                FunctionDrawing(f: { x in x }, integrF: { _ in 0 }, scale: zoom)
                    .stroke(gColor, lineWidth: 2)
            }
            .frame(width: graphSize, height: graphSize)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Rectangle().fill(fColor).frame(width: 16, height: 3)
                        Text("f(x) = sin(x)").font(.caption2).foregroundStyle(fColor)
                    }
                    HStack(spacing: 6) {
                        Rectangle().fill(gColor).frame(width: 16, height: 3)
                        Text("g(x) = x").font(.caption2).foregroundStyle(gColor)
                    }
                }
                .padding(8)
            }
 
            // Message central
            VStack(spacing: 4) {
                Text("Plus on zoome autour de 0, plus f(x) ≈ f′(0)·x et g(x) ≈ g′(0)·x")
                    .font(.caption).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Text("donc  f(x)/g(x)  →  f′(0)/g′(0) = cos(0)/1 = 1")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(.green)
            }
            .padding(.horizontal)
 
            // Slider de zoom
            VStack(spacing: 4) {
                HStack {
                    Text("vue large")
                        .font(.caption2).foregroundStyle(.secondary)
                    Slider(value: $zoom, in: 80...2000)
                    Text("zoom ×\(Int(zoom/100))")
                        .font(.caption2).foregroundStyle(.secondary)
                        .frame(width: 55, alignment: .trailing)
                }
            }
            .padding(.horizontal)
        }
    }
}
 
#Preview {
    LHopitalView()
        .preferredColorScheme(.dark)
}

