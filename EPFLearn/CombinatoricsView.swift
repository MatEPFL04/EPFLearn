//
//  CombinatoricsView.swift
//  EPFLearn
//
//  Created on 20.07.2026.
//

import SwiftUI

/// Interactive view demonstrating combinatorics concepts (permutations and combinations)
struct CombinatoricsView: View {
    @State private var n: Double = 5  // Total items
    @State private var k: Double = 3  // Items to choose
    @State private var showPermutations = true
    
    private var nInt: Int { max(1, min(10, Int(n.rounded()))) }
    private var kInt: Int { max(1, min(nInt, Int(k.rounded()))) }
    
    private var permutations: Int {
        factorial(nInt) / factorial(nInt - kInt)
    }
    
    private var combinations: Int {
        factorial(nInt) / (factorial(kInt) * factorial(nInt - kInt))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                formulaSection
                controlsSection
                visualizationSection
                examplesSection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Combinatorics").font(.largeTitle.bold())
            Text("Combinatorics studies counting, arrangement, and combination of objects.")
                .font(.callout).foregroundStyle(.secondary)
        }
    }
    
    private var formulaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Show Permutations (order matters)", isOn: $showPermutations)
                .tint(.green)
            
            VStack(alignment: .leading, spacing: 8) {
                if showPermutations {
                    Text("Permutations: P(n,k)")
                        .font(.headline)
                    Text("P(n,k) = n! / (n-k)!")
                        .font(.system(.title3, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.green.opacity(0.12)))
                    Text("Number of ways to arrange k items from n items where order matters.")
                        .font(.caption).foregroundStyle(.secondary)
                } else {
                    Text("Combinations: C(n,k)")
                        .font(.headline)
                    Text("C(n,k) = n! / (k!(n-k)!)")
                        .font(.system(.title3, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.12)))
                    Text("Number of ways to choose k items from n items where order doesn't matter.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Label("Total items (n)", systemImage: "square.grid.3x3")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text("\(nInt)")
                        .font(.subheadline.monospacedDigit().weight(.semibold))
                        .padding(.horizontal, 10).padding(.vertical, 3)
                        .background(Capsule().fill(Color.green.opacity(0.15)))
                        .foregroundStyle(.green)
                }
                Slider(value: $n, in: 1...10, step: 1).tint(.green)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Label("Items to choose (k)", systemImage: "hand.point.up.left")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text("\(kInt)")
                        .font(.subheadline.monospacedDigit().weight(.semibold))
                        .padding(.horizontal, 10).padding(.vertical, 3)
                        .background(Capsule().fill(Color.blue.opacity(0.15)))
                        .foregroundStyle(.blue)
                }
                Slider(value: $k, in: 1...Double(nInt), step: 1).tint(.blue)
            }
        }
    }
    
    private var visualizationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Result").font(.headline)
            
            HStack {
                VStack(spacing: 8) {
                    Text(showPermutations ? "P(\(nInt),\(kInt))" : "C(\(nInt),\(kInt))")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text("\(showPermutations ? permutations : combinations)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(showPermutations ? .green : .blue)
                        .contentTransition(.numericText())
                        .animation(.spring(duration: 0.3), value: showPermutations)
                        .animation(.spring(duration: 0.3), value: nInt)
                        .animation(.spring(duration: 0.3), value: kInt)
                    Text(showPermutations ? "arrangements" : "combinations")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(showPermutations ? Color.green.opacity(0.08) : Color.blue.opacity(0.08))
                )
            }
            
            // Visual representation with colored circles
            if nInt <= 8 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Visual representation")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 8) {
                        ForEach(0..<nInt, id: \.self) { i in
                            Circle()
                                .fill(i < kInt ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 36, height: 36)
                                .overlay {
                                    Text("\(i + 1)")
                                        .font(.headline)
                                        .foregroundStyle(i < kInt ? .white : .secondary)
                                }
                        }
                    }
                    
                    Text(showPermutations ? "Choosing \(kInt) items in order" : "Choosing \(kInt) items (any order)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
            }
        }
    }
    
    private var examplesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Real-world examples").font(.headline)
            
            if showPermutations {
                exampleCard(
                    title: "Race podium",
                    description: "10 runners compete. How many ways can gold, silver, and bronze be awarded?",
                    calculation: "P(10,3) = 10!/(10-3)! = 720",
                    icon: "medal"
                )
                exampleCard(
                    title: "Password codes",
                    description: "4-digit PIN from 10 digits without repetition?",
                    calculation: "P(10,4) = 5,040",
                    icon: "lock"
                )
            } else {
                exampleCard(
                    title: "Committee selection",
                    description: "Choose 3 members from 7 people for a committee?",
                    calculation: "C(7,3) = 7!/(3!×4!) = 35",
                    icon: "person.3"
                )
                exampleCard(
                    title: "Pizza toppings",
                    description: "Choose 3 toppings from 8 available?",
                    calculation: "C(8,3) = 56",
                    icon: "fork.knife"
                )
            }
        }
    }
    
    private func exampleCard(title: String, description: String, calculation: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(showPermutations ? .green : .blue)
                .frame(width: 44, height: 44)
                .background(Circle().fill((showPermutations ? Color.green : Color.blue).opacity(0.12)))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(description).font(.caption).foregroundStyle(.secondary)
                Text(calculation).font(.caption.monospaced()).foregroundStyle(showPermutations ? .green : .blue)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
    }
    
    private func factorial(_ n: Int) -> Int {
        guard n > 1 else { return 1 }
        return (1...n).reduce(1, *)
    }
}

#Preview {
    CombinatoricsView()
}
