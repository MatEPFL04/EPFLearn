//
//  SandwichView.swift
//  EPFLearn
//
//  Created by Mat on 09.04.2026.
//

import SwiftUI
import Combine

private struct SqueezeCase: Identifiable {
    let id: Int
    let chip: String
    let middle: (Int) -> Double
    let lower: (Int) -> Double
    let upper: (Int) -> Double
    let middleLabel: String
    let boundLabel: String
    let note: String
}

private let squeezeCases: [SqueezeCase] = [
    SqueezeCase(
        id: 0, chip: "sin(n²)/√n",
        middle: { n in sin(Double(n * n)) / sqrt(Double(n)) },
        lower: { n in -1.0 / sqrt(Double(n)) },
        upper: { n in  1.0 / sqrt(Double(n)) },
        middleLabel: "sin(n²)/√n",
        boundLabel: "±1/√n",
        note: "sin(n²) oscillates forever with no pattern — but it's squeezed by ±1/√n, which both → 0. The oscillation becomes irrelevant."
    ),
    SqueezeCase(
        id: 1, chip: "(-1)ⁿ/n",
        middle: { n in (n % 2 == 0 ? 1.0 : -1.0) / Double(n) },
        lower: { n in -1.0 / Double(n) },
        upper: { n in  1.0 / Double(n) },
        middleLabel: "(-1)ⁿ/n",
        boundLabel: "±1/n",
        note: "The sign flips every step, but the envelope ±1/n shrinks to 0 regardless of the sign pattern."
    ),
    SqueezeCase(
        id: 2, chip: "cos(n)/n²",
        middle: { n in cos(Double(n)) / pow(Double(n), 2) },
        lower: { n in -1.0 / pow(Double(n), 2) },
        upper: { n in  1.0 / pow(Double(n), 2) },
        middleLabel: "cos(n)/n²",
        boundLabel: "±1/n²",
        note: "Same idea, tighter envelope — ±1/n² shrinks much faster than ±1/n, so the squeeze happens sooner."
    ),
]

struct SandwichView: View {

    let graphW: CGFloat = 300
    let graphH: CGFloat = 220
    let maxN = 40

    @State private var selectedCase = 0
    @State private var visibleN: Int = 1
    @State private var isPlaying = false

    let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()

    private var current: SqueezeCase { squeezeCases[selectedCase] }
    let yRange: ClosedRange<Double> = -1.2...1.2

    func xPos(_ n: Int) -> CGFloat {
        CGFloat(n - 1) / CGFloat(maxN - 1) * (graphW - 20) + 10
    }

    func yPos(_ val: Double) -> CGFloat {
        let lo = yRange.lowerBound, hi = yRange.upperBound
        let c = min(max(val, lo), hi)
        return graphH - CGFloat((c - lo) / (hi - lo)) * (graphH - 20) - 10
    }

    var body: some View {
        VStack(spacing: 14) {

            Text("uₙ = \(current.middleLabel)")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundStyle(.secondary)

            Picker("Sequence", selection: $selectedCase) {
                ForEach(squeezeCases) { c in
                    Text(c.chip).tag(c.id)
                }
            }
            .pickerStyle(.menu)
            .frame(width: graphW)
            .onChange(of: selectedCase) {
                visibleN = 1
                isPlaying = false
            }

            HStack(spacing: 16) {
                HStack(spacing: 5) {
                    Circle().fill(Color.orange).frame(width: 8, height: 8)
                    Text("Bounds: \(current.boundLabel)").font(.caption2).foregroundStyle(.orange)
                }
                HStack(spacing: 5) {
                    Circle().fill(Color.blue).frame(width: 8, height: 8)
                    Text("Sequence: \(current.middleLabel)").font(.caption2).foregroundStyle(.blue)
                }
            }

            ZStack(alignment: .topLeading) {

                Path { p in
                    p.move(to: CGPoint(x: 0, y: yPos(0)))
                    p.addLine(to: CGPoint(x: graphW, y: yPos(0)))
                }
                .stroke(Color.green, style: StrokeStyle(lineWidth: 1, dash: [5, 3]))

                Text("L = 0").font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.green)
                    .position(x: graphW - 25, y: yPos(0) - 10)

                // Squeeze zone
                Path { p in
                    guard visibleN >= 1 else { return }
                    let ns = Array(1...visibleN)
                    p.move(to: CGPoint(x: xPos(1), y: yPos(current.lower(1))))
                    for n in ns { p.addLine(to: CGPoint(x: xPos(n), y: yPos(current.lower(n)))) }
                    for n in ns.reversed() { p.addLine(to: CGPoint(x: xPos(n), y: yPos(current.upper(n)))) }
                    p.closeSubpath()
                }
                .fill(Color.orange.opacity(0.12))

                Path { p in
                    guard visibleN >= 2 else { return }
                    p.move(to: CGPoint(x: xPos(1), y: yPos(current.upper(1))))
                    for n in 2...visibleN { p.addLine(to: CGPoint(x: xPos(n), y: yPos(current.upper(n)))) }
                }
                .stroke(Color.orange, lineWidth: 1.5)

                Path { p in
                    guard visibleN >= 2 else { return }
                    p.move(to: CGPoint(x: xPos(1), y: yPos(current.lower(1))))
                    for n in 2...visibleN { p.addLine(to: CGPoint(x: xPos(n), y: yPos(current.lower(n)))) }
                }
                .stroke(Color.orange, lineWidth: 1.5)

                ForEach(Array(1...maxN).filter { $0 <= visibleN }, id: \.self) { n in
                    Circle().fill(Color.orange).frame(width: 5, height: 5)
                        .position(x: xPos(n), y: yPos(current.upper(n)))
                    Circle().fill(Color.orange).frame(width: 5, height: 5)
                        .position(x: xPos(n), y: yPos(current.lower(n)))
                }

                Path { p in
                    guard visibleN >= 2 else { return }
                    p.move(to: CGPoint(x: xPos(1), y: yPos(current.middle(1))))
                    for n in 2...visibleN { p.addLine(to: CGPoint(x: xPos(n), y: yPos(current.middle(n)))) }
                }
                .stroke(Color.blue.opacity(0.4), lineWidth: 1)

                ForEach(Array(1...maxN).filter { $0 <= visibleN }, id: \.self) { n in
                    Circle().fill(Color.blue).frame(width: 7, height: 7)
                        .position(x: xPos(n), y: yPos(current.middle(n)))
                }
            }
            .frame(width: graphW, height: graphH)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))

            VStack(spacing: 6) {
                if visibleN >= 1 {
                    HStack(spacing: 6) {
                        Text("n = \(visibleN)")
                            .font(.system(size: 13, weight: .medium))
                            .padding(.horizontal, 10).padding(.vertical, 3)
                            .background(Color.blue.opacity(0.12))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                        Text("\(current.lower(visibleN), specifier: "%.3f")  ≤  \(current.middle(visibleN), specifier: "%.3f")  ≤  \(current.upper(visibleN), specifier: "%.3f")")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
                Text(current.note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: graphW)

            HStack(spacing: 12) {
                Button(isPlaying ? "Pause" : "Play") { isPlaying.toggle() }
                    .buttonStyle(.borderedProminent)
                Button("Reset") { isPlaying = false; visibleN = 1 }
                    .buttonStyle(.bordered)
            }
        }
        .padding()
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
