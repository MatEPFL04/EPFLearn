//
//  SandwichView.swift
//  EPFLearn
//
//  Created by Mat on 09.04.2026.
//

import SwiftUI
import Combine
 
struct SandwichView: View {
 
    let graphW: CGFloat = 300
    let graphH: CGFloat = 220
 
    @State private var visibleN: Int = 1
    @State private var isPlaying = false
 
    let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()
    let maxN = 40
 
    // uₙ = sin(n²)/√n, encadrée par ±1/√n
    func lower(_ n: Int) -> Double { -1.0 / sqrt(Double(n)) }
    func upper(_ n: Int) -> Double {  1.0 / sqrt(Double(n)) }
    func middle(_ n: Int) -> Double { sin(Double(n * n)) / sqrt(Double(n)) }
 
    let yRange: ClosedRange<Double> = -1.2...1.2
    let limit = 0.0
 
    func xPos(_ n: Int) -> CGFloat {
        CGFloat(n - 1) / CGFloat(maxN - 1) * (graphW - 20) + 10
    }
 
    func yPos(_ val: Double) -> CGFloat {
        let lo = yRange.lowerBound, hi = yRange.upperBound
        let c = min(max(val, lo), hi)
        return graphH - CGFloat((c - lo) / (hi - lo)) * (graphH - 20) - 10
    }
 
    var body: some View {
        VStack(spacing: 12) {
 
            // Légende
            HStack(spacing: 16) {
                HStack(spacing: 5) {
                    Circle().fill(Color.orange).frame(width: 8, height: 8)
                    Text("±1/√n  (gendarmes)").font(.caption2).foregroundStyle(.orange)
                }
                HStack(spacing: 5) {
                    Circle().fill(Color.blue).frame(width: 8, height: 8)
                    Text("sin(n²)/√n").font(.caption2).foregroundStyle(.blue)
                }
            }
 
            ZStack(alignment: .topLeading) {
 
                // Ligne limite L = 0
                Path { p in
                    p.move(to: CGPoint(x: 0, y: yPos(0)))
                    p.addLine(to: CGPoint(x: graphW, y: yPos(0)))
                }
                .stroke(Color.green, style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
 
                Text("L = 0").font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.green)
                    .position(x: graphW - 25, y: yPos(0) - 10)
 
                // Zone entre gendarmes
                Path { p in
                    guard visibleN >= 1 else { return }
                    let ns = Array(1...visibleN)
                    p.move(to: CGPoint(x: xPos(1), y: yPos(lower(1))))
                    for n in ns { p.addLine(to: CGPoint(x: xPos(n), y: yPos(lower(n)))) }
                    for n in ns.reversed() { p.addLine(to: CGPoint(x: xPos(n), y: yPos(upper(n)))) }
                    p.closeSubpath()
                }
                .fill(Color.orange.opacity(0.12))
 
                // Courbe gendarme supérieur 1/√n
                Path { p in
                    guard visibleN >= 2 else { return }
                    p.move(to: CGPoint(x: xPos(1), y: yPos(upper(1))))
                    for n in 2...visibleN { p.addLine(to: CGPoint(x: xPos(n), y: yPos(upper(n)))) }
                }
                .stroke(Color.orange, lineWidth: 1.5)
 
                // Courbe gendarme inférieur -1/√n
                Path { p in
                    guard visibleN >= 2 else { return }
                    p.move(to: CGPoint(x: xPos(1), y: yPos(lower(1))))
                    for n in 2...visibleN { p.addLine(to: CGPoint(x: xPos(n), y: yPos(lower(n)))) }
                }
                .stroke(Color.orange, lineWidth: 1.5)
 
                // Points gendarmes
                ForEach(Array(1...maxN).filter { $0 <= visibleN }, id: \.self) { n in
                    Circle().fill(Color.orange).frame(width: 5, height: 5)
                        .position(x: xPos(n), y: yPos(upper(n)))
                    Circle().fill(Color.orange).frame(width: 5, height: 5)
                        .position(x: xPos(n), y: yPos(lower(n)))
                }
 
                // Ligne suite du milieu
                Path { p in
                    guard visibleN >= 2 else { return }
                    p.move(to: CGPoint(x: xPos(1), y: yPos(middle(1))))
                    for n in 2...visibleN { p.addLine(to: CGPoint(x: xPos(n), y: yPos(middle(n)))) }
                }
                .stroke(Color.blue.opacity(0.4), lineWidth: 1)
 
                // Points suite du milieu
                ForEach(Array(1...maxN).filter { $0 <= visibleN }, id: \.self) { n in
                    Circle().fill(Color.blue).frame(width: 7, height: 7)
                        .position(x: xPos(n), y: yPos(middle(n)))
                }
            }
            .frame(width: graphW, height: graphH)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
 
            // Encadrement explicite
            VStack(spacing: 3) {
                if visibleN >= 1 {
                    Text("-1/√\(visibleN) ≤ sin(\(visibleN)²)/√\(visibleN) ≤ 1/√\(visibleN)")
                        .font(.system(size: 12, design: .monospaced))
                    Text("\(lower(visibleN), specifier: "%.3f")  ≤  \(middle(visibleN), specifier: "%.3f")  ≤  \(upper(visibleN), specifier: "%.3f")")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                Text("Les gendarmes → 0  ⟹  sin(n²)/√n → 0")
                    .font(.caption)
                    .foregroundStyle(.green)
                    .opacity(visibleN > 15 ? 1 : 0)
                    .animation(.easeIn(duration: 0.5), value: visibleN)
            }
            .padding(.vertical, 4)
 
            HStack(spacing: 12) {
                Button(isPlaying ? "Pause" : "Lancer") { isPlaying.toggle() }
                    .buttonStyle(.borderedProminent)
                Button("Reset") { isPlaying = false; visibleN = 1 }
                    .buttonStyle(.bordered)
            }
        }
        .onReceive(timer) { _ in
            guard isPlaying else { return }
            if visibleN < maxN { visibleN += 1 } else { isPlaying = false }
        }
    }
}
 
#Preview {
    SandwichView()
        .preferredColorScheme(.dark)
}
