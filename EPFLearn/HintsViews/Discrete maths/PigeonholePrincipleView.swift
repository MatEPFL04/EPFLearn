/// Interactive demonstration of the Pigeonhole Principle
import SwiftUI
import Combine

struct PigeonholePrincipleView: View {
    @State private var pigeons: Int = 13
    @State private var holes: Int = 10
    @State private var isAnimating = false
    @State private var currentPigeonIndex = 0
    @State private var distribution: [Int] = []
    @State private var showFormula = false
    
    private var guaranteedMin: Int {
        Int(ceil(Double(pigeons) / Double(holes)))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
            // Header compact
            VStack(alignment: .leading, spacing: 4) {
                Text("Pigeonhole Principle").font(.title.bold())
                Text("⌈n/m⌉ = \(guaranteedMin) items minimum")
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.orange)
            }
            
            // Contrôles inline compacts
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pigeons (n)").font(.caption.weight(.medium)).foregroundStyle(.secondary)
                    HStack {
                        Text("\(pigeons)")
                            .font(.headline)
                            .frame(minWidth: 35)
                        Stepper("", value: $pigeons, in: 1...25)
                            .labelsHidden()
                    }
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemGroupedBackground)))
                }
                .onChange(of: pigeons) { _ in resetDistribution() }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Holes (m)").font(.caption.weight(.medium)).foregroundStyle(.secondary)
                    HStack {
                        Text("\(holes)")
                            .font(.headline)
                            .frame(minWidth: 35)
                        Stepper("", value: $holes, in: 1...12)
                            .labelsHidden()
                    }
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemGroupedBackground)))
                }
                .onChange(of: holes) { _ in resetDistribution() }
            }
            
            // Bouton d'animation
            Button {
                if isAnimating {
                    stopAnimation()
                } else {
                    startAnimation()
                }
            } label: {
                Label(isAnimating ? "Stop" : "Animate distribution", systemImage: isAnimating ? "stop.fill" : "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(isAnimating ? .red : .orange)
            .controlSize(.large)
            .disabled(distribution.reduce(0, +) >= pigeons && !isAnimating)
            
            // Visualisation avec pigeons animés
            VStack(alignment: .leading, spacing: 12) {
                Text("Distribution").font(.headline)
                
                // Grille de trous avec compteur
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: min(holes, 4)), spacing: 10) {
                    ForEach(0..<holes, id: \.self) { index in
                        holeCard(index: index)
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
            
            // Résultat
            if !distribution.isEmpty, let maxCount = distribution.max(), maxCount > 0 {
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Guaranteed minimum")
                                .font(.caption).foregroundStyle(.secondary)
                            Text("\(guaranteedMin)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.orange)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Current max")
                                .font(.caption).foregroundStyle(.secondary)
                            Text("\(maxCount)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(maxCount >= guaranteedMin ? .green : .blue)
                        }
                    }
                    
                    if maxCount >= guaranteedMin {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Principle verified!")
                                .font(.callout.weight(.medium))
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange.opacity(0.08)))
            }
        }
        .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            resetDistribution()
        }
    }
    
    private func holeCard(index: Int) -> some View {
        let count = distribution.indices.contains(index) ? distribution[index] : 0
        let isFull = count >= guaranteedMin
        
        return VStack(spacing: 6) {
            Text("#\(index + 1)")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isFull ? Color.orange.opacity(0.15) : Color.blue.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(isFull ? Color.orange : Color.gray.opacity(0.2), lineWidth: isFull ? 2 : 1)
                    )
                
                VStack(spacing: 4) {
                    // Pigeons empilés
                    if count > 0 {
                        VStack(spacing: -8) {
                            ForEach(0..<min(count, 4), id: \.self) { index in
                                Image(systemName: "bird.fill")
                                    .font(.callout)
                                    .foregroundStyle(isFull ? .orange : .blue)
                            }
                        }
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        Image(systemName: "tray")
                            .font(.title3)
                            .foregroundStyle(.gray.opacity(0.3))
                    }
                    
                    Text("\(count)")
                        .font(.headline.bold())
                        .foregroundStyle(isFull ? .orange : (count > 0 ? .blue : .secondary))
                        .contentTransition(.numericText())
                }
            }
            .frame(height: 90)
        }
        .animation(.spring(duration: 0.4), value: count)
    }
    
    private func resetDistribution() {
        stopAnimation()
        distribution = Array(repeating: 0, count: holes)
        currentPigeonIndex = 0
    }
    
    private func startAnimation() {
        isAnimating = true
        animateNextPigeon()
    }
    
    private func stopAnimation() {
        isAnimating = false
    }
    
    private func animateNextPigeon() {
        guard isAnimating, currentPigeonIndex < pigeons else {
            isAnimating = false
            return
        }
        
        withAnimation(.spring(duration: 0.4)) {
            // Remplir séquentiellement: trouver le hole avec le minimum de pigeons
            let minCount = distribution.min() ?? 0
            let minIndex = distribution.firstIndex(of: minCount) ?? 0
            
            distribution[minIndex] += 1
            currentPigeonIndex += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            animateNextPigeon()
        }
    }
}
 
#Preview {
    PigeonholePrincipleView()
}
