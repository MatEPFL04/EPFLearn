//
//  DeterminantView.swift
//  EPFLearn
//
//  Created on 21.07.2026.
//

import SwiftUI

/// Interactive determinant calculator and visualizer for 2×2 and 3×3 matrices
struct DeterminantView: View {
    @State private var matrixSize: Int = 2
    @State private var matrix2x2: [[Double]] = [[2, 1], [1, 3]]
    @State private var matrix3x3: [[Double]] = [[1, 2, 3], [0, 1, 4], [5, 6, 0]]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                sizePickerSection
                matrixInputSection
                calculationSection
                propertiesSection
                interpretationSection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Determinant").font(.largeTitle.bold())
            Text("The determinant is a scalar value that encodes important information about a square matrix, including invertibility and geometric scaling.")
                .font(.callout).foregroundStyle(.secondary)
        }
    }
    
    private var sizePickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Matrix size").font(.subheadline.weight(.medium))
            Picker("Size", selection: $matrixSize) {
                Text("2×2").tag(2)
                Text("3×3").tag(3)
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var matrixInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Matrix values").font(.headline)
            
            if matrixSize == 2 {
                matrix2x2Input
            } else {
                matrix3x3Input
            }
        }
    }
    
    private var matrix2x2Input: some View {
        VStack(spacing: 12) {
            ForEach(0..<2, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(0..<2, id: \.self) { col in
                        TextField("", value: $matrix2x2[row][col], format: .number)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.center)
                            .font(.title3.monospaced())
                            .frame(width: 80)
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
    }
    
    private var matrix3x3Input: some View {
        VStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { col in
                        TextField("", value: $matrix3x3[row][col], format: .number)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.center)
                            .font(.title3.monospaced())
                            .frame(width: 70)
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
    }
    
    private var calculationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Calculation").font(.headline)
            
            VStack(spacing: 12) {
                if matrixSize == 2 {
                    det2x2Calculation
                } else {
                    det3x3Calculation
                }
                
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Text("det(A) =")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.2f", currentDeterminant))
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(determinantColor)
                            .contentTransition(.numericText())
                    }
                    Spacer()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(determinantColor.opacity(0.08)))
            }
        }
    }
    
    private var det2x2Calculation: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Formula for 2×2:")
                .font(.subheadline.weight(.medium))
            
            Text("det(A) = ad - bc")
                .font(.system(.title3, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.pink.opacity(0.12)))
            
            let a = matrix2x2[0][0]
            let b = matrix2x2[0][1]
            let c = matrix2x2[1][0]
            let d = matrix2x2[1][1]
            
            VStack(alignment: .leading, spacing: 4) {
                Text("= (\(formatted(a)))(\(formatted(d))) - (\(formatted(b)))(\(formatted(c)))")
                    .font(.callout.monospaced())
                Text("= \(formatted(a * d)) - \(formatted(b * c))")
                    .font(.callout.monospaced())
                Text("= \(formatted(a * d - b * c))")
                    .font(.callout.monospaced())
                    .foregroundStyle(.pink)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
        }
    }
    
    private var det3x3Calculation: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Formula for 3×3 (Cofactor expansion):")
                .font(.subheadline.weight(.medium))
            
            Text("det(A) = a₁₁C₁₁ + a₁₂C₁₂ + a₁₃C₁₃")
                .font(.system(.callout, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.pink.opacity(0.12)))
            
            let a11 = matrix3x3[0][0]
            let a12 = matrix3x3[0][1]
            let a13 = matrix3x3[0][2]
            
            let minor11 = matrix3x3[1][1] * matrix3x3[2][2] - matrix3x3[1][2] * matrix3x3[2][1]
            let minor12 = matrix3x3[1][0] * matrix3x3[2][2] - matrix3x3[1][2] * matrix3x3[2][0]
            let minor13 = matrix3x3[1][0] * matrix3x3[2][1] - matrix3x3[1][1] * matrix3x3[2][0]
            
            VStack(alignment: .leading, spacing: 4) {
                Text("= \(formatted(a11))(\(formatted(minor11))) - \(formatted(a12))(\(formatted(minor12))) + \(formatted(a13))(\(formatted(minor13)))")
                    .font(.caption.monospaced())
                Text("= \(formatted(a11 * minor11 - a12 * minor12 + a13 * minor13))")
                    .font(.callout.monospaced())
                    .foregroundStyle(.pink)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
        }
    }
    
    private var propertiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Properties").font(.headline)
            
            propertyCard(
                title: "Invertibility",
                formula: "det(A) ≠ 0 ⟺ A is invertible",
                description: "Non-zero determinant means the matrix has an inverse",
                icon: "arrow.triangle.2.circlepath"
            )
            
            propertyCard(
                title: "Multiplicative",
                formula: "det(AB) = det(A) × det(B)",
                description: "Determinant of product = product of determinants",
                icon: "multiply"
            )
            
            propertyCard(
                title: "Transpose",
                formula: "det(Aᵀ) = det(A)",
                description: "Transposing doesn't change the determinant",
                icon: "arrow.up.arrow.down"
            )
            
            propertyCard(
                title: "Row Swap",
                formula: "Swap 2 rows → det changes sign",
                description: "Elementary row operation affects determinant",
                icon: "arrow.left.arrow.right"
            )
        }
    }
    
    private var interpretationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Geometric Interpretation").font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: "square.grid.2x2")
                        .font(.title)
                        .foregroundStyle(determinantColor)
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(determinantColor.opacity(0.12)))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Scaling Factor")
                            .font(.subheadline.weight(.semibold))
                        Text("|det(A)| = volume scaling factor of the linear transformation")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Divider()
                
                if abs(currentDeterminant) < 0.001 {
                    Label("det ≈ 0: Transformation collapses space (not invertible)", systemImage: "arrow.down.to.line.compact")
                        .font(.caption)
                        .foregroundStyle(.red)
                } else if currentDeterminant > 0 {
                    Label("det > 0: Preserves orientation", systemImage: "arrow.clockwise")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else {
                    Label("det < 0: Reverses orientation", systemImage: "arrow.counterclockwise")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
        }
    }
    
    private func propertyCard(title: String, formula: String, description: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.pink)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.pink.opacity(0.12)))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(formula).font(.caption.monospaced()).foregroundStyle(.pink)
                Text(description).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
    }
    
    // MARK: - Helper Properties
    
    private var currentDeterminant: Double {
        if matrixSize == 2 {
            return matrix2x2[0][0] * matrix2x2[1][1] - matrix2x2[0][1] * matrix2x2[1][0]
        } else {
            let a11 = matrix3x3[0][0]
            let a12 = matrix3x3[0][1]
            let a13 = matrix3x3[0][2]
            
            let minor11 = matrix3x3[1][1] * matrix3x3[2][2] - matrix3x3[1][2] * matrix3x3[2][1]
            let minor12 = matrix3x3[1][0] * matrix3x3[2][2] - matrix3x3[1][2] * matrix3x3[2][0]
            let minor13 = matrix3x3[1][0] * matrix3x3[2][1] - matrix3x3[1][1] * matrix3x3[2][0]
            
            return a11 * minor11 - a12 * minor12 + a13 * minor13
        }
    }
    
    private var determinantColor: Color {
        if abs(currentDeterminant) < 0.001 {
            return .red
        } else if currentDeterminant > 0 {
            return .green
        } else {
            return .orange
        }
    }
    
    private func formatted(_ value: Double) -> String {
        String(format: "%.1f", value)
    }
}

#Preview {
    DeterminantView()
}
