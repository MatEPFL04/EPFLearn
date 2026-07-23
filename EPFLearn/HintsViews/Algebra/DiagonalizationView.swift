//
//  DiagonalizationView.swift
//  EPFLearn
//
//  Created on 21.07.2026.
//

import SwiftUI

/// Interactive diagonalization visualizer
struct DiagonalizationView: View {
    @State private var a11: Double = 4
    @State private var a12: Double = 1
    @State private var a21: Double = 0
    @State private var a22: Double = 3
    @State private var powerK: Double = 2
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Diagonalization").font(.largeTitle.bold())
                Text("If A has n linearly independent eigenvectors, we can write A = PDP⁻¹ where D is diagonal.")
                    .font(.callout).foregroundStyle(.secondary)
                
                matrixInputSection
                decompositionSection
                powerSection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var matrixInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Matrix A").font(.headline)
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    TextField("", value: $a11, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.center)
                        .font(.title3.monospaced())
                        .frame(width: 80)
                    TextField("", value: $a12, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.center)
                        .font(.title3.monospaced())
                        .frame(width: 80)
                }
                HStack(spacing: 12) {
                    TextField("", value: $a21, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.center)
                        .font(.title3.monospaced())
                        .frame(width: 80)
                    TextField("", value: $a22, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.center)
                        .font(.title3.monospaced())
                        .frame(width: 80)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
            
            HStack(spacing: 8) {
                Button("Diagonal") {
                    a11 = 4; a12 = 0; a21 = 0; a22 = 3
                }
                .buttonStyle(.bordered).tint(.pink)
                
                Button("Symmetric") {
                    a11 = 3; a12 = 1; a21 = 1; a22 = 2
                }
                .buttonStyle(.bordered).tint(.pink)
                
                Button("General") {
                    a11 = 5; a12 = 2; a21 = 1; a22 = 4
                }
                .buttonStyle(.bordered).tint(.pink)
            }
            .font(.caption)
        }
    }
    
    private var decompositionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Decomposition: A = PDP⁻¹").font(.headline)
            
            let (lambda1, lambda2) = calculateEigenvalues()
            
            HStack(spacing: 8) {
                matrixBox(title: "P", values: "eigenvectors", color: .pink)
                Text("×").font(.title).foregroundStyle(.secondary)
                VStack(spacing: 4) {
                    Text("D").font(.caption.weight(.semibold)).foregroundStyle(.purple)
                    VStack(spacing: 4) {
                        Text(formatted(lambda1))
                            .font(.callout.monospaced())
                            .frame(width: 60)
                            .padding(4)
                            .background(RoundedRectangle(cornerRadius: 6).fill(Color.purple.opacity(0.12)))
                        Text(formatted(lambda2))
                            .font(.callout.monospaced())
                            .frame(width: 60)
                            .padding(4)
                            .background(RoundedRectangle(cornerRadius: 6).fill(Color.purple.opacity(0.12)))
                    }
                }
                Text("×").font(.title).foregroundStyle(.secondary)
                matrixBox(title: "P⁻¹", values: "inverse", color: .blue)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
            
            VStack(alignment: .leading, spacing: 6) {
                Label("Eigenvalues: λ₁ = \(formatted(lambda1)), λ₂ = \(formatted(lambda2))",
                      systemImage: "function")
                    .font(.caption)
                
                if isDiagonalizable() {
                    Label("Matrix is diagonalizable ✓", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else {
                    Label("Matrix may not be diagonalizable", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            .foregroundStyle(.secondary)
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.tertiarySystemGroupedBackground)))
        }
    }
    
    private var powerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Matrix Powers: A^k = PD^kP⁻¹").font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Exponent k")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.pink)
                Picker("Exponent", selection: $powerK) {
                    ForEach(1...10, id: \.self) { value in
                        Text("\(value)").tag(Double(value))
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            let (lambda1, lambda2) = calculateEigenvalues()
            let k = Int(powerK)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("D^k diagonal:")
                    .font(.caption.weight(.medium))
                HStack(spacing: 16) {
                    VStack {
                        Text("λ₁^k")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(formatted(pow(lambda1, Double(k))))
                            .font(.title3.monospaced().bold())
                            .foregroundStyle(.pink)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.pink.opacity(0.08)))
                    
                    VStack {
                        Text("λ₂^k")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(formatted(pow(lambda2, Double(k))))
                            .font(.title3.monospaced().bold())
                            .foregroundStyle(.purple)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.purple.opacity(0.08)))
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
            
            Text("Computing A^k directly requires k matrix multiplications. With diagonalization, just raise diagonal elements to power k!")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.green.opacity(0.12)))
        }
    }
    
    private func matrixBox(title: String, values: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
            Text(values)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 6).fill(color.opacity(0.12)))
        }
    }
    
    private func calculateEigenvalues() -> (Double, Double) {
        let trace = a11 + a22
        let det = a11 * a22 - a12 * a21
        let discriminant = trace * trace - 4 * det
        
        if discriminant >= 0 {
            let sqrtDisc = sqrt(discriminant)
            return ((trace + sqrtDisc) / 2, (trace - sqrtDisc) / 2)
        } else {
            return (trace / 2, trace / 2)
        }
    }
    
    private func isDiagonalizable() -> Bool {
        let (lambda1, lambda2) = calculateEigenvalues()
        // For 2×2, if eigenvalues are distinct or matrix is symmetric, it's diagonalizable
        return abs(lambda1 - lambda2) > 0.001 || abs(a12 - a21) < 0.001
    }
    
    private func formatted(_ value: Double) -> String {
        if abs(value) > 1000 {
            return String(format: "%.1e", value)
        } else {
            return String(format: "%.2f", value)
        }
    }
}

#Preview {
    DiagonalizationView()
}
