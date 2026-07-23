//
//  EigenvaluesView.swift
//  EPFLearn
//
//  Created on 21.07.2026.
//

import SwiftUI

/// Visual eigenvalue and eigenvector explorer
struct EigenvaluesView: View {
    @State private var a: Double = 2
    @State private var b: Double = 0
    @State private var c: Double = 0
    @State private var d: Double = 3
    @State private var showEigenvectors = true
    
    private var eigenvalues: (Double, Double) {
        let trace = a + d
        let det = a * d - b * c
        let discriminant = trace * trace - 4 * det
        
        if discriminant >= 0 {
            let sqrtDisc = sqrt(discriminant)
            return ((trace + sqrtDisc) / 2, (trace - sqrtDisc) / 2)
        } else {
            return (trace / 2, trace / 2)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Eigenvalues & Eigenvectors").font(.largeTitle.bold())
                
                matrixControls
                visualTransformation
                eigenvalueDisplay
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var matrixControls: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                pickerColumn(value: $a, label: "a", color: .pink)
                pickerColumn(value: $b, label: "b", color: .pink)
            }
            HStack(spacing: 16) {
                pickerColumn(value: $c, label: "c", color: .purple)
                pickerColumn(value: $d, label: "d", color: .purple)
            }
            
            Toggle("Show eigenvectors", isOn: $showEigenvectors)
                .tint(.green)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
    }
    
    private func pickerColumn(value: Binding<Double>, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.title3.monospaced().bold())
                .foregroundStyle(color)
            Picker(label, selection: value) {
                ForEach(Array(stride(from: -3.0, through: 3.0, by: 0.5)), id: \.self) { val in
                    Text(String(format: "%.1f", val)).tag(val)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private var visualTransformation: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Transformation").font(.headline)
            
            Canvas { ctx, size in
                drawEigenVisualization(ctx, size: size)
            }
            .frame(height: 320)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
        }
    }
    
    private func drawEigenVisualization(_ ctx: GraphicsContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let scale: CGFloat = 50
        
        // Grid
        for i in stride(from: -4, through: 4, by: 1) {
            var vLine = Path()
            vLine.move(to: CGPoint(x: centerX + CGFloat(i) * scale, y: 0))
            vLine.addLine(to: CGPoint(x: centerX + CGFloat(i) * scale, y: size.height))
            ctx.stroke(vLine, with: .color(.secondary.opacity(0.1)), lineWidth: 0.5)
            
            var hLine = Path()
            hLine.move(to: CGPoint(x: 0, y: centerY + CGFloat(i) * scale))
            hLine.addLine(to: CGPoint(x: size.width, y: centerY + CGFloat(i) * scale))
            ctx.stroke(hLine, with: .color(.secondary.opacity(0.1)), lineWidth: 0.5)
        }
        
        // Axes
        var axes = Path()
        axes.move(to: CGPoint(x: 0, y: centerY))
        axes.addLine(to: CGPoint(x: size.width, y: centerY))
        axes.move(to: CGPoint(x: centerX, y: 0))
        axes.addLine(to: CGPoint(x: centerX, y: size.height))
        ctx.stroke(axes, with: .color(.secondary.opacity(0.5)), lineWidth: 1.5)
        
        if showEigenvectors {
            // Draw circle of vectors being transformed
            let numVectors = 16
            for i in 0..<numVectors {
                let angle = Double(i) * 2 * .pi / Double(numVectors)
                let x = cos(angle)
                let y = sin(angle)
                
                // Original vector
                let origEnd = CGPoint(
                    x: centerX + CGFloat(x) * scale,
                    y: centerY - CGFloat(y) * scale
                )
                
                // Transformed vector
                let tx = a * x + b * y
                let ty = c * x + d * y
                let transEnd = CGPoint(
                    x: centerX + CGFloat(tx) * scale,
                    y: centerY - CGFloat(ty) * scale
                )
                
                // Original (gray)
                drawArrow(ctx, from: CGPoint(x: centerX, y: centerY), to: origEnd, 
                         color: .gray.opacity(0.3), width: 1.5)
                
                // Transformed (colored)
                let isEigenvector = abs(ty * x - tx * y) < 0.1 // Check if roughly collinear
                drawArrow(ctx, from: CGPoint(x: centerX, y: centerY), to: transEnd,
                         color: isEigenvector ? .green : .cyan.opacity(0.7), width: isEigenvector ? 3 : 2)
            }
        }
    }
    
    private func drawArrow(_ ctx: GraphicsContext, from: CGPoint, to: CGPoint, color: Color, width: CGFloat) {
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        ctx.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round))
        
        let angle = atan2(to.y - from.y, to.x - from.x)
        let arrowLength: CGFloat = 8
        let arrowAngle: CGFloat = .pi / 6
        
        var arrow = Path()
        arrow.move(to: to)
        arrow.addLine(to: CGPoint(
            x: to.x - arrowLength * cos(angle - arrowAngle),
            y: to.y - arrowLength * sin(angle - arrowAngle)
        ))
        arrow.move(to: to)
        arrow.addLine(to: CGPoint(
            x: to.x - arrowLength * cos(angle + arrowAngle),
            y: to.y - arrowLength * sin(angle + arrowAngle)
        ))
        ctx.stroke(arrow, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round))
    }
    
    private var eigenvalueDisplay: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                VStack(spacing: 8) {
                    Text("λ₁")
                        .font(.title3.bold())
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.2f", eigenvalues.0))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)
                        .contentTransition(.numericText())
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.green.opacity(0.1)))
                
                VStack(spacing: 8) {
                    Text("λ₂")
                        .font(.title3.bold())
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.2f", eigenvalues.1))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.blue)
                        .contentTransition(.numericText())
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.1)))
            }
            
            Text("Green vectors stay on their line after transformation")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.green.opacity(0.08)))
        }
    }
}

#Preview {
    EigenvaluesView()
}
