//
//  PigeonholePrincipleView.swift
//  EPFLearn
//
//  Created on 20.07.2026.
//

import SwiftUI

/// Interactive demonstration of the Pigeonhole Principle
struct PigeonholePrincipleView: View {
    @State private var pigeons: Double = 13
    @State private var holes: Double = 10
    @State private var distribution: [Int] = []
    @State private var animationTrigger = false
    
    private var pigeonCount: Int { max(1, min(50, Int(pigeons.rounded()))) }
    private var holeCount: Int { max(1, min(20, Int(holes.rounded()))) }
    
    private var guaranteedMin: Int {
        Int(ceil(Double(pigeonCount) / Double(holeCount)))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                principleSection
                controlsSection
                visualizationSection
                resultSection
                examplesSection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear(perform: distributeRandomly)
        .onChange(of: pigeonCount) { _, _ in distributeRandomly() }
        .onChange(of: holeCount) { _, _ in distributeRandomly() }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pigeonhole Principle").font(.largeTitle.bold())
            Text("If you put n items into m containers and n > m, at least one container must contain more than one item.")
                .font(.callout).foregroundStyle(.secondary)
        }
    }
    
    private var principleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("The Principle").font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("⌈n/m⌉ items in at least one container")
                    .font(.system(.title3, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange.opacity(0.12)))
                
                Text("Where n = number of items and m = number of containers.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }
    
    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Label("Pigeons (items)", systemImage: "bird")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text("\(pigeonCount)")
                        .font(.subheadline.monospacedDigit().weight(.semibold))
                        .padding(.horizontal, 10).padding(.vertical, 3)
                        .background(Capsule().fill(Color.orange.opacity(0.18)))
                        .foregroundStyle(.orange)
                }
                Slider(value: $pigeons, in: 1...50, step: 1).tint(.orange)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Label("Holes (containers)", systemImage: "square.grid.3x3")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text("\(holeCount)")
                        .font(.subheadline.monospacedDigit().weight(.semibold))
                        .padding(.horizontal, 10).padding(.vertical, 3)
                        .background(Capsule().fill(Color.blue.opacity(0.15)))
                        .foregroundStyle(.blue)
                }
                Slider(value: $holes, in: 1...20, step: 1).tint(.blue)
            }
            
            Button {
                distributeRandomly()
                animationTrigger.toggle()
            } label: {
                Label("Redistribute randomly", systemImage: "shuffle")
            }
            .buttonStyle(.bordered)
            .tint(.orange)
        }
    }
    
    private var visualizationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Visualization").font(.headline)
            
            if holeCount <= 12 {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: min(holeCount, 4)), spacing: 12) {
                    ForEach(0..<holeCount, id: \.self) { index in
                        holeView(index: index, count: distribution.indices.contains(index) ? distribution[index] : 0)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
            } else {
                Text("Too many holes to display. Use the chart below.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
            }
        }
    }
    
    private func holeView(index: Int, count: Int) -> some View {
        VStack(spacing: 8) {
            Text("Hole \(index + 1)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(count >= guaranteedMin ? Color.orange.opacity(0.15) : Color.blue.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(count >= guaranteedMin ? Color.orange : Color.blue.opacity(0.3), lineWidth: 2)
                    )
                
                VStack(spacing: 4) {
                    Image(systemName: "bird.fill")
                        .font(.title2)
                        .foregroundStyle(count >= guaranteedMin ? .orange : .blue)
                    
                    Text("\(count)")
                        .font(.title.bold())
                        .foregroundStyle(count >= guaranteedMin ? .orange : .blue)
                }
            }
            .frame(height: 100)
            .animation(.spring(duration: 0.4), value: count)
            .animation(.spring(duration: 0.4), value: animationTrigger)
        }
    }
    
    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Result").font(.headline)
            
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("Guaranteed minimum")
                        .font(.caption).foregroundStyle(.secondary)
                    Text("\(guaranteedMin)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.orange)
                        .contentTransition(.numericText())
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange.opacity(0.12)))
                
                VStack(spacing: 4) {
                    Text("Actual maximum")
                        .font(.caption).foregroundStyle(.secondary)
                    Text("\(distribution.max() ?? 0)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.blue)
                        .contentTransition(.numericText())
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.12)))
            }
            
            Text("⌈\(pigeonCount)/\(holeCount)⌉ = ⌈\(String(format: "%.2f", Double(pigeonCount)/Double(holeCount)))⌉ = \(guaranteedMin)")
                .font(.callout.monospaced())
                .foregroundStyle(.secondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
        }
    }
    
    private var examplesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Classic Examples").font(.headline)
            
            exampleCard(
                title: "Birthday Problem",
                problem: "367 people in a room (366 possible birthdays)",
                solution: "⌈367/366⌉ = 2",
                conclusion: "At least 2 people share a birthday",
                icon: "gift"
            )
            
            exampleCard(
                title: "Sock Drawer",
                problem: "10 pairs of socks (10 colors) in a dark drawer",
                solution: "⌈11/10⌉ = 2",
                conclusion: "Pull 11 socks to guarantee a matching pair",
                icon: "figure.walk"
            )
            
            exampleCard(
                title: "Handshakes",
                problem: "In a party of 13 people",
                solution: "⌈13/12⌉ = 2",
                conclusion: "At least 2 people were born in the same month",
                icon: "hand.wave"
            )
        }
    }
    
    private func exampleCard(title: String, problem: String, solution: String, conclusion: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.orange)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.orange.opacity(0.12)))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.subheadline.weight(.semibold))
                    Text(problem).font(.caption).foregroundStyle(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(solution).font(.caption.monospaced()).foregroundStyle(.orange)
                Text(conclusion).font(.caption.weight(.medium)).foregroundStyle(.primary)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
    }
    
    // MARK: - Distribution Logic
    
    private func distributeRandomly() {
        var newDistribution = Array(repeating: 0, count: holeCount)
        for _ in 0..<pigeonCount {
            let randomIndex = Int.random(in: 0..<holeCount)
            newDistribution[randomIndex] += 1
        }
        distribution = newDistribution
    }
}

#Preview {
    PigeonholePrincipleView()
}
