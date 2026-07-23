//
//  GaussianEliminationView.swift
//  EPFLearn
//
//  Created on 21.07.2026.
//

import SwiftUI

/// Interactive Gaussian elimination visualizer
struct GaussianEliminationView: View {
    @State private var matrix: [[Double]] = [
        [2, 1, -1, 8],
        [-3, -1, 2, -11],
        [-2, 1, 2, -3]
    ]
    @State private var currentStep = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Gaussian Elimination").font(.largeTitle.bold())
                Text("Transform a matrix to row echelon form using elementary row operations.")
                    .font(.callout).foregroundStyle(.secondary)
                
                matrixDisplay
                
                HStack {
                    Button("Previous Step") {
                        if currentStep > 0 { currentStep -= 1 }
                    }
                    .buttonStyle(.bordered)
                    .disabled(currentStep == 0)
                    
                    Spacer()
                    
                    Text("Step \(currentStep) of 3")
                        .font(.caption.monospacedDigit())
                    
                    Spacer()
                    
                    Button("Next Step") {
                        if currentStep < 3 { currentStep += 1 }
                    }
                    .buttonStyle(.bordered)
                    .tint(.pink)
                    .disabled(currentStep == 3)
                }
                
                stepExplanation
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var matrixDisplay: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Augmented Matrix").font(.headline)
            
            VStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: 8) {
                        ForEach(0..<4, id: \.self) { col in
                            Text(String(format: "%.0f", getCurrentMatrix()[row][col]))
                                .font(.title3.monospaced())
                                .frame(width: 50)
                                .padding(6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(col == 3 ? Color.green.opacity(0.12) : Color.pink.opacity(0.08))
                                )
                        }
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
        }
    }
    
    private var stepExplanation: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(stepDescription)
                .font(.subheadline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.pink.opacity(0.12)))
        }
    }
    
    private func getCurrentMatrix() -> [[Double]] {
        switch currentStep {
        case 0:
            return matrix
        case 1:
            // After first pivot
            return [
                [2, 1, -1, 8],
                [0, 0.5, 0.5, 1],
                [0, 2, 1, 5]
            ]
        case 2:
            // After second pivot
            return [
                [2, 1, -1, 8],
                [0, 0.5, 0.5, 1],
                [0, 0, -1, 1]
            ]
        case 3:
            // Row echelon form
            return [
                [2, 1, -1, 8],
                [0, 0.5, 0.5, 1],
                [0, 0, 1, -1]
            ]
        default:
            return matrix
        }
    }
    
    private var stepDescription: String {
        switch currentStep {
        case 0:
            return "Original augmented matrix [A|b]"
        case 1:
            return "R₂ → R₂ + (3/2)R₁, R₃ → R₃ + R₁ (Eliminate first column below pivot)"
        case 2:
            return "R₃ → R₃ - 4R₂ (Eliminate second column below pivot)"
        case 3:
            return "R₃ → -R₃ (Make pivot 1). Row echelon form achieved!"
        default:
            return ""
        }
    }
}

struct GaussianEliminationView_Previews: PreviewProvider {
    static var previews: some View {
        GaussianEliminationView()
    }
}
