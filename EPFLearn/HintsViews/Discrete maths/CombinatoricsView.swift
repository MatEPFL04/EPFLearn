//
//  CombinatoricsView.swift
//  EPFLearn
//
//  Created on 20.07.2026.
//

import SwiftUI

/// Interactive view demonstrating combinatorics concepts (permutations and combinations)
struct CombinatoricsView: View {
    @State private var n: Int = 4
    @State private var k: Int = 2
    @State private var showPermutations = true
    @State private var generatedCombos: [[Int]] = []
    @State private var isGenerating = false
    @State private var currentIndex = 0
    
    private var result: Int {
        showPermutations ? permutations(n, k) : combinations(n, k)
    }
    
    private var gridColumns: Int {
        k == 1 ? 4 : (k == 2 ? 3 : 2)
    }
    
    private var maxDisplay: Int {
        k == 1 ? 12 : (k == 2 ? 12 : (k == 3 ? 8 : 6))
    }
    
    private let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .cyan]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(showPermutations ? "Permutations" : "Combinations").font(.title.bold())
                    Text(showPermutations ? "Order matters! ABC ≠ BAC" : "Order doesn't matter! ABC = BAC")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // Toggle
                Picker("Mode", selection: $showPermutations.animation()) {
                    Text("Permutations").tag(true)
                    Text("Combinations").tag(false)
                }
                .pickerStyle(.segmented)
                .onChange(of: showPermutations) { _ in
                    generateCombos()
                }
                
                // Contrôles
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total items (n)").font(.caption.weight(.medium)).foregroundStyle(.secondary)
                        Stepper("\(n)", value: $n, in: 2...5)
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemGroupedBackground)))
                            .onChange(of: n) { newValue in
                                if k > newValue { k = newValue }
                                generateCombos()
                            }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pick (k)").font(.caption.weight(.medium)).foregroundStyle(.secondary)
                        Stepper("\(k)", value: $k, in: 1...n)
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemGroupedBackground)))
                            .onChange(of: k) { _ in
                                generateCombos()
                            }
                    }
                }
                
                // Résultat
                HStack {
                    VStack(spacing: 4) {
                        Text(showPermutations ? "P(\(n),\(k))" : "C(\(n),\(k))")
                            .font(.title3).foregroundStyle(.secondary)
                        Text("\(result)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(showPermutations ? .green : .blue)
                            .contentTransition(.numericText())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill((showPermutations ? Color.green : Color.blue).opacity(0.1))
                    )
                }
                
                // Source items
                VStack(alignment: .leading, spacing: 8) {
                    Text("Available items:")
                        .font(.subheadline.weight(.semibold))
                    
                    HStack(spacing: 12) {
                        ForEach(0..<n, id: \.self) { i in
                            Circle()
                                .fill(colors[i % colors.count])
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text("\(i + 1)")
                                        .font(.title2.bold())
                                        .foregroundStyle(.white)
                                )
                        }
                        Spacer()
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
                
                // Toutes les possibilités
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("All \(result) possibilities:")
                            .font(.headline)
                        Spacer()
                        if result > maxDisplay {
                            Text("Showing first \(maxDisplay)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: gridColumns), spacing: 8) {
                        ForEach(0..<min(generatedCombos.count, maxDisplay), id: \.self) { index in
                            comboCard(combo: generatedCombos[index], index: index)
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            generateCombos()
        }
    }
    
    private func comboCard(combo: [Int], index: Int) -> some View {
        VStack(spacing: 4) {
            // Label pour permutations (ordre visible)
            if showPermutations {
                Text("#\(index + 1)")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: showPermutations ? 2 : 4) {
                ForEach(combo.indices, id: \.self) { i in
                    Circle()
                        .fill(colors[combo[i] % colors.count])
                        .frame(width: circleSize, height: circleSize)
                        .overlay(
                            Text("\(combo[i] + 1)")
                                .font(circleFontSize)
                                .foregroundStyle(.white)
                        )
                    
                    if showPermutations && i < combo.count - 1 {
                        Image(systemName: "arrow.right")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.tertiarySystemGroupedBackground))
        )
    }
    
    private var circleSize: CGFloat {
        switch k {
        case 1: return 40
        case 2: return 35
        case 3: return 28
        case 4: return 24
        default: return 20
        }
    }
    
    private var circleFontSize: Font {
        k >= 4 ? .caption.bold() : .callout.bold()
    }
    
    private func generateCombos() {
        generatedCombos.removeAll()
        
        if showPermutations {
            generatedCombos = generatePermutations(n: n, k: k)
        } else {
            generatedCombos = generateCombinations(n: n, k: k)
        }
    }
    
    private func generatePermutations(n: Int, k: Int) -> [[Int]] {
        var result: [[Int]] = []
        var current: [Int] = []
        var used = Array(repeating: false, count: n)
        
        func backtrack() {
            if current.count == k {
                result.append(Array(current))  // COPIE !
                return
            }
            
            for i in 0..<n {
                if !used[i] {
                    used[i] = true
                    current.append(i)
                    backtrack()
                    current.removeLast()
                    used[i] = false
                }
            }
        }
        
        backtrack()
        return result
    }
    
    private func generateCombinations(n: Int, k: Int) -> [[Int]] {
        var result: [[Int]] = []
        var current: [Int] = []
        
        func backtrack(start: Int) {
            if current.count == k {
                result.append(Array(current))  // COPIE !
                return
            }
            
            for i in start..<n {
                current.append(i)
                backtrack(start: i + 1)
                current.removeLast()
            }
        }
        
        backtrack(start: 0)
        return result
    }
    
    private func permutations(_ n: Int, _ k: Int) -> Int {
        factorial(n) / factorial(n - k)
    }
    
    private func combinations(_ n: Int, _ k: Int) -> Int {
        factorial(n) / (factorial(k) * factorial(n - k))
    }
    
    private func factorial(_ n: Int) -> Int {
        guard n > 1 else { return 1 }
        return (1...n).reduce(1, *)
    }
}

#Preview {
    CombinatoricsView()
}
