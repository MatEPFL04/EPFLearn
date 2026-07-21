//
//  BinomialCoefficientsView.swift
//  EPFLearn
//
//  Created on 20.07.2026.
//

import SwiftUI

/// Interactive Pascal's Triangle visualization
struct BinomialCoefficientsView: View {
    @State private var rows: Double = 7
    
    private var rowCount: Int { max(1, min(12, Int(rows.rounded()))) }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                formulaSection
                controlSection
                triangleVisualization
                propertiesSection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Binomial Coefficients").font(.largeTitle.bold())
            Text("Pascal's Triangle displays binomial coefficients C(n,k), which count combinations and appear in binomial expansions.")
                .font(.callout).foregroundStyle(.secondary)
        }
    }
    
    private var formulaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Formula").font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("C(n,k) = n! / (k!(n-k)!)")
                    .font(.system(.title3, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.purple.opacity(0.12)))
                
                Text("Pascal's Identity: C(n,k) = C(n-1,k-1) + C(n-1,k)")
                    .font(.system(.callout, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.green.opacity(0.12)))
                
                Text("Each number is the sum of the two numbers above it.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }
    
    private var controlSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label("Number of rows", systemImage: "triangle")
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text("\(rowCount)")
                    .font(.subheadline.monospacedDigit().weight(.semibold))
                    .padding(.horizontal, 10).padding(.vertical, 3)
                    .background(Capsule().fill(Color.purple.opacity(0.15)))
                    .foregroundStyle(.purple)
            }
            Slider(value: $rows, in: 1...12, step: 1).tint(.purple)
        }
    }
    
    private var triangleVisualization: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pascal's Triangle").font(.headline)
            
            VStack(spacing: 8) {
                ForEach(0..<rowCount, id: \.self) { n in
                    HStack(spacing: 6) {
                        ForEach(0...n, id: \.self) { k in
                            let value = binomial(n, k)
                            Text("\(value)")
                                .font(.system(size: fontSize(for: rowCount), weight: .semibold, design: .rounded))
                                .frame(minWidth: cellWidth(for: rowCount))
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(colorForValue(value, in: n))
                                )
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
        }
    }
    
    private var propertiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Properties").font(.headline)
            
            propertyCard(
                title: "Symmetry",
                formula: "C(n,k) = C(n,n-k)",
                description: "The triangle is symmetric: values are mirrored.",
                icon: "arrow.left.and.right"
            )
            
            propertyCard(
                title: "Row Sum",
                formula: "Σ C(n,k) = 2ⁿ",
                description: "Sum of row n equals 2ⁿ. For n=4: 1+4+6+4+1 = 16 = 2⁴",
                icon: "plus"
            )
            
            propertyCard(
                title: "Binomial Theorem",
                formula: "(x+y)ⁿ = Σ C(n,k)xᵏyⁿ⁻ᵏ",
                description: "Coefficients in polynomial expansion come from row n.",
                icon: "function"
            )
            
            propertyCard(
                title: "Hockey Stick",
                formula: "Σ C(i,k) = C(n+1,k+1)",
                description: "Sum along a diagonal equals the value at the end.",
                icon: "hockeypuck"
            )
        }
    }
    
    private func propertyCard(title: String, formula: String, description: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.purple)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.purple.opacity(0.12)))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.subheadline.weight(.semibold))
                    Text(formula).font(.caption.monospaced()).foregroundStyle(.purple)
                }
            }
            Text(description).font(.caption).foregroundStyle(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
    }
    
    // MARK: - Helper functions
    
    private func binomial(_ n: Int, _ k: Int) -> Int {
        guard k >= 0, k <= n else { return 0 }
        if k == 0 || k == n { return 1 }
        
        var result = 1
        for i in 0..<min(k, n - k) {
            result *= (n - i)
            result /= (i + 1)
        }
        return result
    }
    
    private func colorForValue(_ value: Int, in row: Int) -> Color {
        let maxInRow = binomial(row, row / 2)
        let ratio = Double(value) / Double(max(maxInRow, 1))
        
        if ratio < 0.33 {
            return Color.blue
        } else if ratio < 0.67 {
            return Color.purple
        } else {
            return Color.pink
        }
    }
    
    private func fontSize(for rows: Int) -> CGFloat {
        switch rows {
        case ...5: return 18
        case 6...8: return 14
        case 9...10: return 12
        default: return 10
        }
    }
    
    private func cellWidth(for rows: Int) -> CGFloat {
        switch rows {
        case ...5: return 44
        case 6...8: return 36
        case 9...10: return 30
        default: return 26
        }
    }
}

#Preview {
    BinomialCoefficientsView()
}
