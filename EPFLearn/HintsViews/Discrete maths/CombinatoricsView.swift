//
//  CombinatoricsView.swift
//  EPFLearn
//
//  Created on 20.07.2026.
//

import SwiftUI

/// Interactive view demonstrating combinatorics concepts (permutations and combinations)
struct CombinatoricsView: View {
    @State private var n: Int = 5
    @State private var k: Int = 3
    @State private var showPermutations = true
    @State private var selectedItems: Set<Int> = []
    @State private var animateShuffle = false
    
    private var result: Int {
        showPermutations ? permutations(n, k) : combinations(n, k)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
            // Header compact
            VStack(alignment: .leading, spacing: 4) {
                Text("Combinatorics").font(.title.bold())
                Text(showPermutations ? "P(n,k) = n!/(n-k)!" : "C(n,k) = n!/(k!(n-k)!)")
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            
            // Toggle compact
            Picker("Mode", selection: $showPermutations) {
                Text("Permutations").tag(true)
                Text("Combinations").tag(false)
            }
            .pickerStyle(.segmented)
            
            // Contrôles inline horizontaux
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("n").font(.caption.weight(.medium)).foregroundStyle(.secondary)
                    Stepper("\(n)", value: $n, in: 3...8)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemGroupedBackground)))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("k").font(.caption.weight(.medium)).foregroundStyle(.secondary)
                    Stepper("\(k)", value: $k, in: 1...n)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemGroupedBackground)))
                }
            }
            
            // Résultat en grand
            HStack {
                VStack(spacing: 4) {
                    Text(showPermutations ? "P(\(n),\(k))" : "C(\(n),\(k))")
                        .font(.title3).foregroundStyle(.secondary)
                    Text("\(result)")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(showPermutations ? .green : .blue)
                        .contentTransition(.numericText())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill((showPermutations ? Color.green : Color.blue).opacity(0.1))
                )
            }
            
            // Visualisation interactive avec drag & drop
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Interactive selection")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Button {
                        withAnimation(.spring(duration: 0.4)) {
                            selectedItems.removeAll()
                            selectRandomK()
                            animateShuffle.toggle()
                        }
                    } label: {
                        Label("Shuffle", systemImage: "shuffle")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(showPermutations ? .green : .blue)
                }
                
                // Grille d'items sélectionnables
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: min(n, 4)), spacing: 10) {
                    ForEach(0..<n, id: \.self) { i in
                        itemCircle(index: i)
                            .onTapGesture {
                                withAnimation(.spring(duration: 0.3)) {
                                    toggleSelection(i)
                                }
                            }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
                
                if selectedItems.count == k {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text(showPermutations ? "\(k) items selected (order matters)" : "\(k) items selected")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            selectRandomK()
        }
    }
    
    private func itemCircle(index: Int) -> some View {
        let isSelected = selectedItems.contains(index)
        let selectionIndex = Array(selectedItems.sorted()).firstIndex(of: index)
        
        return ZStack {
            Circle()
                .fill(isSelected ? (showPermutations ? Color.green : Color.blue) : Color.gray.opacity(0.2))
                .overlay(
                    Circle()
                        .strokeBorder(isSelected ? .white : .clear, lineWidth: 2)
                )
            
            VStack(spacing: 2) {
                Text("\(index + 1)")
                    .font(.title2.bold())
                    .foregroundStyle(isSelected ? .white : .secondary)
                
                if showPermutations, let order = selectionIndex {
                    Text("→ \(order + 1)")
                        .font(.caption2.bold())
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
        .frame(height: 70)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(duration: 0.3), value: isSelected)
        .animation(.spring(duration: 0.3), value: animateShuffle)
    }
    
    private func toggleSelection(_ index: Int) {
        if selectedItems.contains(index) {
            selectedItems.remove(index)
        } else if selectedItems.count < k {
            selectedItems.insert(index)
        }
    }
    
    private func selectRandomK() {
        selectedItems.removeAll()
        let randomIndices = Array(0..<n).shuffled().prefix(k)
        selectedItems = Set(randomIndices)
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
