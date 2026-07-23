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
        case dice = "Dice"
        case coin = "Coin"
        case cards = "Cards"
        
        var id: Self { self }
    }
    
    private var trialCount: Int { max(10, min(1000, Int(trials.rounded()))) }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Probability").font(.largeTitle.bold())
                
                controlsSection
                simulationSection
                resultsSection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear { runSimulation() }
        .onChange(of: experimentType) { _, _ in runSimulation() }
    }
    
    private var controlsSection: some View {
        HStack(spacing: 12) {
            Picker("Type", selection: $experimentType) {
                ForEach(ExperimentType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 100, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Picker("Trials", selection: $trials) {
                ForEach(Array(stride(from: 10, through: 1000, by: 10)), id: \.self) { value in
                    Text("\(value)").tag(Double(value))
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 100, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Button {
                withAnimation {
                    isSimulating = true
                    runSimulation()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isSimulating = false
                    }
                }
            } label: {
                Image(systemName: "play.fill")
                    .font(.title2)
            }
            .buttonStyle(.bordered)
            .tint(.cyan)
            .controlSize(.large)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
    }
    
    private var simulationSection: some View {
        Canvas { ctx, size in
            drawHistogram(ctx, size: size)
        }
        .frame(height: 200)
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
    
    @ViewBuilder
    private var resultsSection: some View {
        switch experimentType {
        case .dice:
            diceResults
        case .coin:
            coinResults
        case .cards:
            cardResults
        }
    }
    
    private var diceResults: some View {
        let counts = Dictionary(grouping: results, by: { $0 }).mapValues { $0.count }
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
            ForEach(1...6, id: \.self) { face in
                let count = counts[face] ?? 0
                let prob = Double(count) / Double(trialCount)
                
                VStack(spacing: 4) {
                    Image(systemName: "die.face.\(face)")
                        .font(.title2)
                        .foregroundStyle(.cyan)
                    Text("\(count)")
                        .font(.caption.monospacedDigit().bold())
                    Text("\(String(format: "%.0f", prob * 100))%")
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.cyan.opacity(0.08)))
            }
        }
    }
    
    private var coinResults: some View {
        let counts = Dictionary(grouping: results, by: { $0 }).mapValues { $0.count }
        let heads = counts[1] ?? 0
        let tails = counts[0] ?? 0
        let headsProb = Double(heads) / Double(trialCount)
        
        return HStack(spacing: 12) {
            VStack(spacing: 8) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.cyan)
                Text("Heads")
                    .font(.caption)
                Text("\(heads)")
                    .font(.title2.monospacedDigit().bold())
                Text("\(String(format: "%.0f", headsProb * 100))%")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.cyan.opacity(0.08)))
            
            VStack(spacing: 8) {
                Image(systemName: "circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.gray)
                Text("Tails")
                    .font(.caption)
                Text("\(tails)")
                    .font(.title2.monospacedDigit().bold())
                Text("\(String(format: "%.0f", (1 - headsProb) * 100))%")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.08)))
        }
    }
    
    private var cardResults: some View {
        let counts = Dictionary(grouping: results, by: { $0 }).mapValues { $0.count }
        let suitNames = ["♠️", "♥️", "♦️", "♣️"]
        let suitColors: [Color] = [.primary, .red, .red, .primary]
        
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
            ForEach(0..<4, id: \.self) { suit in
                let count = counts[suit] ?? 0
                let prob = Double(count) / Double(trialCount)
                
                VStack(spacing: 4) {
                    Text(suitNames[suit])
                        .font(.title)
                        .foregroundStyle(suitColors[suit])
                    Text("\(count)")
                        .font(.caption.monospacedDigit().bold())
                    Text("\(String(format: "%.0f", prob * 100))%")
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.cyan.opacity(0.08)))
            }
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
        let padding: CGFloat = 30
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
            
            let bar = Path(roundedRect: CGRect(x: x, y: y, width: barWidth, height: barHeight), cornerRadius: 4)
            ctx.fill(bar, with: .color(.cyan.opacity(0.7)))
            
            // Count
            if count > 0 {
                ctx.draw(
                    Text("\(count)").font(.caption2.bold()).foregroundStyle(.cyan),
                    at: CGPoint(x: x + barWidth / 2, y: y - 8)
                )
            }
        }
    }
}

#Preview {
    ProbabilityView()
}
