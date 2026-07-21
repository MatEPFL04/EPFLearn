//
//  ProbabilityView.swift
//  EPFLearn
//
//  Created on 20.07.2026.
//

import SwiftUI

/// Interactive probability simulator with dice, coins, and cards
struct ProbabilityView: View {
    @State private var experimentType = ExperimentType.dice
    @State private var trials: Double = 100
    @State private var results: [Int] = []
    @State private var isSimulating = false
    
    enum ExperimentType: String, CaseIterable, Identifiable {
        case dice = "Dice Roll"
        case coin = "Coin Flip"
        case cards = "Card Draw"
        
        var id: Self { self }
    }
    
    private var trialCount: Int { max(10, min(1000, Int(trials.rounded()))) }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                theorySection
                controlsSection
                simulationSection
                resultsSection
                examplesSection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear { runSimulation() }
        .onChange(of: experimentType) { _, _ in runSimulation() }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Probability").font(.largeTitle.bold())
            Text("Probability measures the likelihood of events. Through repeated trials, observed frequencies approach theoretical probabilities (Law of Large Numbers).")
                .font(.callout).foregroundStyle(.secondary)
        }
    }
    
    private var theorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Basic Formula").font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("P(event) = favorable outcomes / total outcomes")
                    .font(.system(.callout, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.cyan.opacity(0.12)))
                
                Text(theoreticalDescription)
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }
    
    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Experiment type").font(.subheadline.weight(.medium))
                Picker("Experiment", selection: $experimentType) {
                    ForEach(ExperimentType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Label("Number of trials", systemImage: "repeat")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text("\(trialCount)")
                        .font(.subheadline.monospacedDigit().weight(.semibold))
                        .padding(.horizontal, 10).padding(.vertical, 3)
                        .background(Capsule().fill(Color.cyan.opacity(0.15)))
                        .foregroundStyle(.cyan)
                }
                Slider(value: $trials, in: 10...1000, step: 10).tint(.cyan)
            }
            
            Button {
                withAnimation {
                    isSimulating = true
                    runSimulation()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isSimulating = false
                    }
                }
            } label: {
                Label("Run simulation", systemImage: "play.fill")
            }
            .buttonStyle(.bordered)
            .tint(.cyan)
        }
    }
    
    private var simulationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Distribution").font(.headline)
            
            Canvas { ctx, size in
                drawHistogram(ctx, size: size)
            }
            .frame(height: 240)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
            .overlay {
                if isSimulating {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.secondarySystemGroupedBackground).opacity(0.8))
                }
            }
        }
    }
    
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Results").font(.headline)
            
            switch experimentType {
            case .dice:
                diceResults
            case .coin:
                coinResults
            case .cards:
                cardResults
            }
        }
    }
    
    private var diceResults: some View {
        let counts = Dictionary(grouping: results, by: { $0 }).mapValues { $0.count }
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
            ForEach(1...6, id: \.self) { face in
                let count = counts[face] ?? 0
                let prob = Double(count) / Double(trialCount)
                let theoretical = 1.0 / 6.0
                
                VStack(spacing: 6) {
                    Image(systemName: "die.face.\(face)")
                        .font(.title)
                        .foregroundStyle(.cyan)
                    Text("\(count)")
                        .font(.title3.monospacedDigit().bold())
                    Text("\(String(format: "%.1f", prob * 100))%")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(abs(prob - theoretical) < 0.05 ? .green : .secondary)
                    Text("(≈16.7%)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.cyan.opacity(0.08)))
            }
        }
    }
    
    private var coinResults: some View {
        let counts = Dictionary(grouping: results, by: { $0 }).mapValues { $0.count }
        let heads = counts[1] ?? 0
        let tails = counts[0] ?? 0
        let headsProb = Double(heads) / Double(trialCount)
        let theoretical = 0.5
        
        return HStack(spacing: 12) {
            VStack(spacing: 8) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.cyan)
                Text("Heads")
                    .font(.headline)
                Text("\(heads)")
                    .font(.title.monospacedDigit().bold())
                Text("\(String(format: "%.1f", headsProb * 100))%")
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(abs(headsProb - theoretical) < 0.1 ? .green : .secondary)
                Text("(expected 50%)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.cyan.opacity(0.08)))
            
            VStack(spacing: 8) {
                Image(systemName: "circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.gray)
                Text("Tails")
                    .font(.headline)
                Text("\(tails)")
                    .font(.title.monospacedDigit().bold())
                Text("\(String(format: "%.1f", (1 - headsProb) * 100))%")
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(abs((1 - headsProb) - theoretical) < 0.1 ? .green : .secondary)
                Text("(expected 50%)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.gray.opacity(0.08)))
        }
    }
    
    private var cardResults: some View {
        let counts = Dictionary(grouping: results, by: { $0 }).mapValues { $0.count }
        let suitNames = ["♠️ Spades", "♥️ Hearts", "♦️ Diamonds", "♣️ Clubs"]
        let suitColors: [Color] = [.primary, .red, .red, .primary]
        
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
            ForEach(0..<4, id: \.self) { suit in
                let count = counts[suit] ?? 0
                let prob = Double(count) / Double(trialCount)
                let theoretical = 0.25
                
                VStack(spacing: 6) {
                    Text(suitNames[suit])
                        .font(.title2)
                        .foregroundStyle(suitColors[suit])
                    Text("\(count)")
                        .font(.title3.monospacedDigit().bold())
                    Text("\(String(format: "%.1f", prob * 100))%")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(abs(prob - theoretical) < 0.08 ? .green : .secondary)
                    Text("(≈25%)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.cyan.opacity(0.08)))
            }
        }
    }
    
    private var examplesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Probability Rules").font(.headline)
            
            ruleCard(
                title: "Addition Rule",
                formula: "P(A ∪ B) = P(A) + P(B) - P(A ∩ B)",
                description: "For mutually exclusive events: P(A ∪ B) = P(A) + P(B)",
                icon: "plus"
            )
            
            ruleCard(
                title: "Multiplication Rule",
                formula: "P(A ∩ B) = P(A) × P(B)",
                description: "For independent events only",
                icon: "multiply"
            )
            
            ruleCard(
                title: "Complement Rule",
                formula: "P(A') = 1 - P(A)",
                description: "The probability of 'not A' equals 1 minus the probability of A",
                icon: "minus.circle"
            )
        }
    }
    
    private func ruleCard(title: String, formula: String, description: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.cyan)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.cyan.opacity(0.12)))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.subheadline.weight(.semibold))
                    Text(formula).font(.caption.monospaced()).foregroundStyle(.cyan)
                }
            }
            Text(description).font(.caption).foregroundStyle(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
    }
    
    // MARK: - Helper Properties & Functions
    
    private var theoreticalDescription: String {
        switch experimentType {
        case .dice:
            return "Rolling a fair die: each face (1-6) has probability 1/6 ≈ 16.7%"
        case .coin:
            return "Flipping a fair coin: heads and tails each have probability 1/2 = 50%"
        case .cards:
            return "Drawing a card: each suit has probability 1/4 = 25%"
        }
    }
    
    private func runSimulation() {
        results = []
        for _ in 0..<trialCount {
            switch experimentType {
            case .dice:
                results.append(Int.random(in: 1...6))
            case .coin:
                results.append(Int.random(in: 0...1))
            case .cards:
                results.append(Int.random(in: 0...3))
            }
        }
    }
    
    private func drawHistogram(_ ctx: GraphicsContext, size: CGSize) {
        let padding: CGFloat = 40
        let plotWidth = size.width - 2 * padding
        let plotHeight = size.height - 2 * padding
        
        let counts = Dictionary(grouping: results, by: { $0 }).mapValues { $0.count }
        let maxCount = counts.values.max() ?? 1
        
        let barCount: Int
        switch experimentType {
        case .dice: barCount = 6
        case .coin: barCount = 2
        case .cards: barCount = 4
        }
        
        let barWidth = plotWidth / CGFloat(barCount) * 0.7
        let spacing = plotWidth / CGFloat(barCount)
        
        // Axes
        var axes = Path()
        axes.move(to: CGPoint(x: padding, y: padding))
        axes.addLine(to: CGPoint(x: padding, y: size.height - padding))
        axes.addLine(to: CGPoint(x: size.width - padding, y: size.height - padding))
        ctx.stroke(axes, with: .color(.secondary.opacity(0.3)), lineWidth: 1.5)
        
        // Bars
        for i in 0..<barCount {
            let key: Int
            switch experimentType {
            case .dice: key = i + 1
            case .coin: key = i
            case .cards: key = i
            }
            
            let count = counts[key] ?? 0
            let barHeight = plotHeight * CGFloat(count) / CGFloat(maxCount)
            let x = padding + spacing * CGFloat(i) + (spacing - barWidth) / 2
            let y = size.height - padding - barHeight
            
            let bar = Path(roundedRect: CGRect(x: x, y: y, width: barWidth, height: barHeight), cornerRadius: 6)
            ctx.fill(bar, with: .color(.cyan.opacity(0.7)))
            
            // Label
            let label = experimentType == .dice ? "\(key)" : ""
            if !label.isEmpty {
                ctx.draw(
                    Text(label).font(.caption).foregroundStyle(.secondary),
                    at: CGPoint(x: x + barWidth / 2, y: size.height - padding + 14)
                )
            }
            
            // Count
            ctx.draw(
                Text("\(count)").font(.caption2.bold()).foregroundStyle(.cyan),
                at: CGPoint(x: x + barWidth / 2, y: y - 10)
            )
        }
    }
}

#Preview {
    ProbabilityView()
}
