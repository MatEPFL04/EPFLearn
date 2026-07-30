//
//  BinomialCoefficientsView.swift
//  EPFLearn
//
//  Created on 20.07.2026.
//

import SwiftUI

/// Interactive binomial coefficients and Pascal's triangle visualization
struct BinomialCoefficientsView: View {
    @State private var rows: Int = 5
    @State private var selectedN: Int? = nil
    @State private var selectedK: Int? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header compact
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pascal's Triangle").font(.title.bold())
                    Text("Each value = sum of two above")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                
                // Contrôle rows
                HStack {
                    Text("Rows")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    Stepper("\(rows)", value: $rows, in: 2...6)
                        .frame(maxWidth: 200)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemGroupedBackground)))
                
                // Sélection interactive
                if let n = selectedN, let k = selectedK {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("C(\(n),\(k)) = \(binomialCoefficient(n, k))")
                                .font(.headline.monospaced())
                                .foregroundStyle(.purple)
                            Spacer()
                            Button {
                                withAnimation {
                                    selectedN = nil
                                    selectedK = nil
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        // Montrer la propriété de Pascal
                        if n > 0 {
                            if k == 0 || k == n {
                                Text("Edge: always = 1")
                                    .font(.caption.monospaced())
                                    .foregroundStyle(.orange)
                            } else {
                                Text("= C(\(n-1),\(k-1)) + C(\(n-1),\(k))")
                                    .font(.caption.monospaced())
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.purple.opacity(0.1)))
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Pascal's Triangle avec flèches visuelles
                VStack(spacing: 8) {
                    ForEach(0..<rows, id: \.self) { n in
                        HStack(spacing: 8) {
                            ForEach(0...n, id: \.self) { k in
                                let value = binomialCoefficient(n, k)
                                let isSelected = (selectedN == n && selectedK == k)
                                // Highlight both parents: C(n-1, k-1) AND C(n-1, k)
                                let isPartOfSum: Bool = {
                                    guard let sel = selectedN, let selK = selectedK else { return false }
                                    if n != sel - 1 { return false }
                                    // C(sel, selK) = C(n, k-1) + C(n, k)
                                    return k == selK - 1 || k == selK
                                }()
                                
                                Text("\(value)")
                                    .font(.system(size: cellFontSize, weight: isSelected ? .bold : .regular, design: .rounded))
                                    .foregroundStyle(isSelected ? .white : (isPartOfSum ? .orange : .purple))
                                    .frame(width: cellSize, height: cellSize)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(isSelected ? Color.purple : (isPartOfSum ? Color.orange.opacity(0.2) : Color.purple.opacity(0.08)))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .strokeBorder(isPartOfSum ? Color.orange : Color.clear, lineWidth: 2)
                                    )
                                    .scaleEffect(isSelected ? 1.1 : 1.0)
                                    .onTapGesture {
                                        withAnimation(.spring(duration: 0.3)) {
                                            if selectedN == n && selectedK == k {
                                                selectedN = nil
                                                selectedK = nil
                                            } else {
                                                selectedN = n
                                                selectedK = k
                                            }
                                        }
                                    }
                            }
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
                
                // Propriété visuelle
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pascal's Identity")
                        .font(.headline)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.left")
                            .foregroundStyle(.orange)
                        Text("+")
                            .font(.title3.bold())
                        Image(systemName: "arrow.down.right")
                            .foregroundStyle(.orange)
                        Text("=")
                            .font(.title3.bold())
                        Image(systemName: "arrow.down")
                            .foregroundStyle(.purple)
                    }
                    .font(.caption)
                    
                    Text("Tap any number to see how it's the sum of the two above it!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange.opacity(0.08)))
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var cellSize: CGFloat {
        rows <= 4 ? 55 : 50
    }
    
    private var cellFontSize: CGFloat {
        rows <= 4 ? 18 : 16
    }
    
    private func binomialCoefficient(_ n: Int, _ k: Int) -> Int {
        guard k >= 0, k <= n else { return 0 }
        if k == 0 || k == n { return 1 }
        
        let k = min(k, n - k)
        var result = 1
        for i in 0..<k {
            result = result * (n - i) / (i + 1)
        }
        return result
    }
}

#Preview {
    BinomialCoefficientsView()
}
