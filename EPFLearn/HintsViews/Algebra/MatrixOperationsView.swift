//
//  MatrixOperationsView.swift
//  EPFLearn
//
//  Created on 21.07.2026.
//

import SwiftUI

/// Interactive matrix operations visualization
struct MatrixOperationsView: View {
    @State private var operation: Operation = .multiply
    @State private var matrixARows: Double = 2
    @State private var matrixACols: Double = 3
    @State private var matrixBRows: Double = 3
    @State private var matrixBCols: Double = 2
    
    enum Operation: String, CaseIterable, Identifiable {
        case multiply = "Multiply (AB)"
        case add = "Add (A+B)"
        case transpose = "Transpose (Aᵀ)"
        case scalar = "Scalar Multiply (2A)"

        var id: Self { self }

    }
    
    private var aRows: Int { max(1, min(4, Int(matrixARows.rounded()))) }
    private var aCols: Int { max(1, min(4, Int(matrixACols.rounded()))) }
    private var bRows: Int { max(1, min(4, Int(matrixBRows.rounded()))) }
    private var bCols: Int { max(1, min(4, Int(matrixBCols.rounded()))) }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                VizHeader("Matrix Operations", subtitle: "Which shapes fit together, and what comes out.")

                // Picture first, then the pickers and the sliders that drive it -
                // the same order as every other visualization in the app.
                visualizationSection
                operationPickerSection
                controlsSection
            }
            .padding(14)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    /// A menu, under the picture, exactly like the preset pickers in the other
    /// views. It started as a 120pt wheel above the matrices, which is what
    /// made this view read as a different app from the rest.
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .bold))
            .tracking(0.7)
            .foregroundStyle(.secondary)
    }

    private var operationPickerSection: some View {
        Picker("Operation", selection: $operation) {
            ForEach(Operation.allCases) { op in
                Text(op.rawValue).tag(op)
            }
        }
        .pickerStyle(.menu)
        .labelsHidden()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("MATRIX A")
            
            HStack(spacing: 12) {
                VizSlider(label: "Rows", value: $matrixARows, range: 1...4, step: 1,
                          accent: .pink, valueText: "\(aRows)")
                VizSlider(label: "Columns", value: $matrixACols, range: 1...4, step: 1,
                          accent: .pink, valueText: "\(aCols)")
            }
            
            if operation == .multiply || operation == .add {
                sectionLabel("MATRIX B")
                
                HStack(spacing: 12) {
                    VizSlider(label: "Rows", value: $matrixBRows, range: 1...4, step: 1,
                              accent: .purple, valueText: "\(bRows)")
                    VizSlider(label: "Columns", value: $matrixBCols, range: 1...4, step: 1,
                              accent: .purple, valueText: "\(bCols)")
                }
            }
        }
    }
    
    private var visualizationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch operation {
            case .multiply:
                multiplyVisualization
            case .add:
                addVisualization
            case .transpose:
                transposeVisualization
            case .scalar:
                scalarVisualization
            }
        }
    }
    
    private var multiplyVisualization: some View {
        VStack(spacing: 16) {
            VStack(spacing: 16) {
                HStack(alignment: .center, spacing: 12) {
                    matrixView(rows: aRows, cols: aCols, label: "A", color: .pink, highlightFirstRow: true, isValid: aCols == bRows)
                    Text("×").font(.title.bold()).foregroundStyle(.secondary)
                    matrixView(rows: bRows, cols: bCols, label: "B", color: .purple, highlightFirstCol: true, isValid: aCols == bRows)
                    Text("=").font(.title.bold()).foregroundStyle(.secondary)
                    
                    if aCols == bRows {
                        matrixView(rows: aRows, cols: bCols, label: "C", color: .green)
                    } else {
                        Text("⚠️").font(.largeTitle)
                    }
                }
                
                Group {
                    if aCols == bRows {
                        Text("✓ Compatible: Result is \(aRows)×\(bCols) matrix")
                            .font(.caption)
                            .foregroundStyle(.green)
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.green.opacity(0.12)))
                    } else {
                        Text("✗ Incompatible: Columns of A (\(aCols)) ≠ Rows of B (\(bRows))")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.red.opacity(0.12)))
                    }
                }
                .frame(height: 32)
            }
            
            Text("Rule: (m×n) × (n×p) = (m×p)")
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
    }
    
    private var addVisualization: some View {
        VStack(spacing: 16) {
            VStack(spacing: 16) {
                HStack(alignment: .center, spacing: 12) {
                    matrixView(rows: aRows, cols: aCols, label: "A", color: .pink)
                    Text("+").font(.title.bold()).foregroundStyle(.secondary)
                    matrixView(rows: bRows, cols: bCols, label: "B", color: .purple)
                    Text("=").font(.title.bold()).foregroundStyle(.secondary)
                    
                    if aRows == bRows && aCols == bCols {
                        matrixView(rows: aRows, cols: aCols, label: "C", color: .green)
                    } else {
                        Text("⚠️").font(.largeTitle)
                    }
                }
                
                Group {
                    if aRows == bRows && aCols == bCols {
                        Text("✓ Compatible: Both matrices are \(aRows)×\(aCols)")
                            .font(.caption)
                            .foregroundStyle(.green)
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.green.opacity(0.12)))
                    } else {
                        Text("✗ Incompatible: Matrices must have same dimensions")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.red.opacity(0.12)))
                    }
                }
                .frame(height: 32)
            }
            
            Text("Rule: Can only add matrices of identical size")
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
    }
    
    private var transposeVisualization: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                matrixView(rows: aRows, cols: aCols, label: "A", color: .pink)
                Text("ᵀ =").font(.title.bold()).foregroundStyle(.secondary)
                matrixView(rows: aCols, cols: aRows, label: "Aᵀ", color: .green)
            }
            
            Text("Transpose swaps rows ↔ columns")
                .font(.caption)
                .foregroundStyle(.green)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.green.opacity(0.12)))
            
            Text("Rule: (m×n)ᵀ = (n×m)")
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
    }
    
    private var scalarVisualization: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                Text("2 ×")
                    .font(.title.bold())
                    .foregroundStyle(.pink)
                matrixView(rows: aRows, cols: aCols, label: "A", color: .pink)
                Text("=").font(.title.bold()).foregroundStyle(.secondary)
                matrixView(rows: aRows, cols: aCols, label: "2A", color: .green)
            }
            
            Text("Multiply each element by the scalar (2)")
                .font(.caption)
                .foregroundStyle(.green)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.green.opacity(0.12)))
            
            Text("Rule: c·(m×n) = (m×n) with each element multiplied by c")
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
    }
    
    private func matrixView(rows: Int, cols: Int, label: String, color: Color, highlightFirstRow: Bool = false, highlightFirstCol: Bool = false, isValid: Bool = true) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
            
            VStack(spacing: 2) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<cols, id: \.self) { col in
                            let isHighlighted = (highlightFirstRow && row == 0) || (highlightFirstCol && col == 0)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(isHighlighted ? (isValid ? color : color.opacity(0.5)) : color.opacity(0.3))
                                .frame(width: 20, height: 20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3)
                                        .strokeBorder(isHighlighted ? (isValid ? Color.orange : Color.gray.opacity(0.4)) : Color.clear, lineWidth: isHighlighted ? 2 : 0)
                                )
                        }
                    }
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color, lineWidth: 2)
            )
            
            Text("\(rows)×\(cols)")
                .font(.caption2.monospaced())
                .foregroundStyle(.secondary)
        }
    }
    

}

#Preview {
    MatrixOperationsView()
        .preferredColorScheme(.dark)
}
