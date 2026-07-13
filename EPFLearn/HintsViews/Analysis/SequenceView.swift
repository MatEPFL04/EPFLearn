//
//  SequenceView.swift
//  EPFLearn
//
//  Illustrates different qualitative behaviors of subsequences:
//  convergent, multiple limits, or no convergent subsequence at all.
//
import Combine
import SwiftUI

private struct SubsequenceDef: Identifiable {
    let id: Int
    let color: Color
    let membership: (Int) -> Bool   // is index n part of this subsequence?
    let limitLabel: String
    let limitValue: Double?         // nil if it diverges (no line drawn)
}

private struct SequenceDefinition: Identifiable {
    let id: Int
    let name: String
    let formula: (Int) -> Double
    let startIndex: Int
    let totalTerms: Int
    let yRange: ClosedRange<Double>
    let summary: String
    let subsequences: [SubsequenceDef]   // colored automatically, no user picking
}

// Palette choisie pour rester lisible sur fond sombre : couleurs plus
// vibrantes/claires que les .blue/.orange/.red bruts, qui perdent en
// contraste sur un fond noir. Les points non-appariés utilisent un gris
// plus clair (0.5 au lieu de 0.35) pour rester visibles sans dominer.
private let subsequenceColors: [Color] = [.cyan, .orange, .pink]
private let unmatchedDotColor = Color(white: 0.75)

private let sequenceDefinitions: [SequenceDefinition] = [

    // Convergent sequence: colored as one single converging subsequence
    SequenceDefinition(
        id: 0, name: "1/n",
        formula: { 1.0 / Double($0) },
        startIndex: 1, totalTerms: 24, yRange: -0.1...1.15,
        summary: "The sequence itself converges to 0 — every term is part of it.",
        subsequences: [
            SubsequenceDef(id: 0, color: subsequenceColors[0],
                            membership: { _ in true }, limitLabel: "→ 0", limitValue: 0),
        ]
    ),

    // Periodic: several distinct convergent subsequences
    SequenceDefinition(
        id: 1, name: "cos(nπ/2)",
        formula: { cos(Double($0) * .pi / 2) },
        startIndex: 0, totalTerms: 24, yRange: -1.15...1.15,
        summary: "Bounded and periodic — several subsequences converge, but to different limits.",
        subsequences: [
            SubsequenceDef(id: 0, color: subsequenceColors[0],
                            membership: { $0 % 4 == 0 }, limitLabel: "→ 1", limitValue: 1),
            SubsequenceDef(id: 1, color: subsequenceColors[1],
                            membership: { $0 % 4 == 1 }, limitLabel: "→ 0", limitValue: 0),
            SubsequenceDef(id: 2, color: subsequenceColors[2],
                            membership: { $0 % 4 == 2 }, limitLabel: "→ −1", limitValue: -1),
        ]
    ),

    // Unbounded, oscillating: no convergent subsequence — everything stays gray
    SequenceDefinition(
        id: 2, name: "(-1)ⁿ(n+1)",
        formula: { n in (n % 2 == 0 ? 1.0 : -1.0) * Double(n + 1) },
        startIndex: 0, totalTerms: 14, yRange: -15...15,
        summary: "Unbounded — Bolzano–Weierstrass doesn't apply here. No subsequence converges to a finite limit.",
        subsequences: []
    ),
]

struct SequenceView: View {

    @State private var visibleCount: Int = 1
    @State private var isPlaying: Bool = false
    @State private var selectedFunction: Int = 0

    let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    let graphW: CGFloat = 320
    let graphH: CGFloat = 200

    private var sequence: SequenceDefinition { sequenceDefinitions[selectedFunction] }

    private func matchingSub(for n: Int) -> SubsequenceDef? {
        sequence.subsequences.first { $0.membership(n) }
    }

    func xPos(_ i: Int) -> CGFloat {
        CGFloat(i) / CGFloat(max(sequence.totalTerms - 1, 1)) * (graphW - 30) + 15
    }

    func yPos(_ v: Double) -> (y: CGFloat, offScreen: Bool) {
        let lo = sequence.yRange.lowerBound, hi = sequence.yRange.upperBound
        let clamped = min(max(v, lo), hi)
        let y = graphH - CGFloat((clamped - lo) / (hi - lo)) * (graphH - 20) - 10
        return (y, v < lo || v > hi)
    }

    var body: some View {
        VStack(spacing: 16) {

            Text("uₙ = \(sequence.name)")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundStyle(.secondary)

            Picker("Sequence", selection: $selectedFunction) {
                ForEach(sequenceDefinitions) { s in
                    Text(s.name).tag(s.id)
                }
            }
            .pickerStyle(.menu)
            .frame(width: graphW)
            .onChange(of: selectedFunction) {
                visibleCount = 1
                isPlaying = false
            }

            ZStack {
                Color(.systemBackground)

                Path { p in
                    for y in stride(from: 0, through: graphH, by: 20) {
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: graphW, y: y))
                    }
                }
                .stroke(Color.blue.opacity(0.15), lineWidth: 0.5)

                // limit lines for every convergent subsequence — shown from the start
                ForEach(sequence.subsequences.filter { $0.limitValue != nil }) { s in
                    Path { p in
                        let y = yPos(s.limitValue!).y
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: graphW, y: y))
                    }
                    .stroke(s.color.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5, 4]))

                    Text(s.limitLabel)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(s.color)
                        .position(x: graphW - 30, y: yPos(s.limitValue!).y - 10)
                }

                // faded connecting line for the full sequence
                Path { p in
                    let visible = 0..<min(visibleCount, sequence.totalTerms)
                    guard visible.count > 1 else { return }
                    let n0 = sequence.startIndex
                    p.move(to: CGPoint(x: xPos(0), y: yPos(sequence.formula(n0)).y))
                    for i in visible.dropFirst() {
                        p.addLine(to: CGPoint(x: xPos(i), y: yPos(sequence.formula(n0 + i)).y))
                    }
                }
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)

                // terms — colored if part of a convergent subsequence, gray otherwise
                ForEach(0..<min(visibleCount, sequence.totalTerms), id: \.self) { i in
                    let n = sequence.startIndex + i
                    let match = matchingSub(for: n)
                    let value = sequence.formula(n)
                    let (y, offScreen) = yPos(value)

                    if let match, offScreen {
                        Image(systemName: value > sequence.yRange.upperBound ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                            .foregroundStyle(match.color)
                            .font(.system(size: 10))
                            .position(x: xPos(i), y: y)
                    } else {
                        Circle()
                            .fill(match?.color ?? unmatchedDotColor)
                            .frame(width: match != nil ? 10 : 6, height: match != nil ? 10 : 6)
                            .position(x: xPos(i), y: y)
                    }
                }
            }
            .frame(width: graphW, height: graphH)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 0.5))

            // Légende des sous-suites — utile dès que plusieurs limites coexistent
            if !sequence.subsequences.isEmpty {
                HStack(spacing: 14) {
                    ForEach(sequence.subsequences) { s in
                        HStack(spacing: 5) {
                            Circle().fill(s.color).frame(width: 8, height: 8)
                            Text(s.limitLabel)
                                .font(.caption2)
                                .foregroundStyle(s.color)
                        }
                    }
                }
            }

            Text(sequence.summary)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                Button(isPlaying ? "Pause" : "Play") { isPlaying.toggle() }
                    .buttonStyle(.borderedProminent)
                Button("Reset") { isPlaying = false; visibleCount = 1 }
                    .buttonStyle(.bordered)
            }
        }
        .padding()
        .onReceive(timer) { _ in
            guard isPlaying else { return }
            if visibleCount < sequence.totalTerms { visibleCount += 1 } else { isPlaying = false }
        }
    }
}

#Preview {
    SequenceView()
        .preferredColorScheme(.dark)
}
