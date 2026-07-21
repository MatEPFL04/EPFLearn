//
//  LinearTransformationView.swift
//  EPFLearn
//
//  Created on 21.07.2026.
//

import SwiftUI

/// Interactive linear transformation visualizer
struct LinearTransformationView: View {
    @State private var transformType: TransformType = .rotation
    @State private var angle: Double = 45
    @State private var scaleX: Double = 1.5
    @State private var scaleY: Double = 0.8
    
    enum TransformType: String, CaseIterable, Identifiable {
        case rotation = "Rotation"
        case scaling = "Scaling"
        case shear = "Shear"
        case reflection = "Reflection"
        
        var id: Self { self }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Linear Transformations").font(.largeTitle.bold())
                Text("A linear transformation T: V → W preserves vector addition and scalar multiplication.")
                    .font(.callout).foregroundStyle(.secondary)
                
                Picker("Transformation", selection: $transformType) {
                    ForEach(TransformType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                
                controlsSection
                matrixDisplay
                visualizationSection
                propertiesSection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch transformType {
            case .rotation:
                Text("Rotation angle").font(.subheadline.weight(.medium))
                HStack {
                    Slider(value: $angle, in: 0...360, step: 15).tint(.pink)
                    Text("\(Int(angle))°").font(.caption.monospacedDigit()).frame(width: 40)
                }
            case .scaling:
                Text("Scale factors").font(.subheadline.weight(.medium))
                VStack(spacing: 8) {
                    HStack {
                        Text("X:").frame(width: 20)
                        Slider(value: $scaleX, in: 0.1...3, step: 0.1).tint(.pink)
                        Text(String(format: "%.1f", scaleX)).font(.caption.monospacedDigit()).frame(width: 30)
                    }
                    HStack {
                        Text("Y:").frame(width: 20)
                        Slider(value: $scaleY, in: 0.1...3, step: 0.1).tint(.purple)
                        Text(String(format: "%.1f", scaleY)).font(.caption.monospacedDigit()).frame(width: 30)
                    }
                }
            default:
                EmptyView()
            }
        }
    }
    
    private var matrixDisplay: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Transformation Matrix").font(.headline)
            
            let matrix = getTransformationMatrix()
            
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    Text(String(format: "%.2f", matrix.0))
                        .font(.title3.monospaced())
                        .frame(width: 70)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.pink.opacity(0.12)))
                    
                    Text(String(format: "%.2f", matrix.1))
                        .font(.title3.monospaced())
                        .frame(width: 70)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.pink.opacity(0.12)))
                }
                HStack(spacing: 12) {
                    Text(String(format: "%.2f", matrix.2))
                        .font(.title3.monospaced())
                        .frame(width: 70)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.purple.opacity(0.12)))
                    
                    Text(String(format: "%.2f", matrix.3))
                        .font(.title3.monospaced())
                        .frame(width: 70)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.purple.opacity(0.12)))
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
        }
    }
    
    private var visualizationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Before & After").font(.headline)
            
            Canvas { ctx, size in
                drawTransformation(ctx, size: size)
            }
            .frame(height: 250)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
        }
    }
    
    private var propertiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Properties").font(.headline)
            
            Group {
                HStack(spacing: 12) {
                    Image(systemName: "function")
                        .foregroundStyle(.pink)
                        .frame(width: 30)
                    VStack(alignment: .leading) {
                        Text("T(v + w) = T(v) + T(w)")
                            .font(.caption.monospaced())
                        Text("Preserves vector addition")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "multiply")
                        .foregroundStyle(.pink)
                        .frame(width: 30)
                    VStack(alignment: .leading) {
                        Text("T(cv) = cT(v)")
                            .font(.caption.monospaced())
                        Text("Preserves scalar multiplication")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
        }
    }
    
    private func getTransformationMatrix() -> (Double, Double, Double, Double) {
        switch transformType {
        case .rotation:
            let rad = angle * .pi / 180
            return (cos(rad), -sin(rad), sin(rad), cos(rad))
        case .scaling:
            return (scaleX, 0, 0, scaleY)
        case .shear:
            return (1, 1, 0, 1)
        case .reflection:
            return (1, 0, 0, -1)
        }
    }
    
    private func drawTransformation(_ ctx: GraphicsContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let scale: CGFloat = 40
        
        // Axes
        var axes = Path()
        axes.move(to: CGPoint(x: 0, y: centerY))
        axes.addLine(to: CGPoint(x: size.width, y: centerY))
        axes.move(to: CGPoint(x: centerX, y: 0))
        axes.addLine(to: CGPoint(x: centerX, y: size.height))
        ctx.stroke(axes, with: .color(.secondary.opacity(0.3)), lineWidth: 1)
        
        // Original unit square (before)
        let points = [
            (0.0, 0.0), (2.0, 0.0), (2.0, 2.0), (0.0, 2.0)
        ]
        
        var originalPath = Path()
        for (i, point) in points.enumerated() {
            let screenPoint = CGPoint(
                x: centerX + CGFloat(point.0) * scale,
                y: centerY - CGFloat(point.1) * scale
            )
            if i == 0 {
                originalPath.move(to: screenPoint)
            } else {
                originalPath.addLine(to: screenPoint)
            }
        }
        originalPath.closeSubpath()
        ctx.stroke(originalPath, with: .color(.secondary.opacity(0.3)), style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
        
        // Transformed square (after)
        let matrix = getTransformationMatrix()
        var transformedPath = Path()
        for (i, point) in points.enumerated() {
            let tx = matrix.0 * point.0 + matrix.1 * point.1
            let ty = matrix.2 * point.0 + matrix.3 * point.1
            let screenPoint = CGPoint(
                x: centerX + CGFloat(tx) * scale,
                y: centerY - CGFloat(ty) * scale
            )
            if i == 0 {
                transformedPath.move(to: screenPoint)
            } else {
                transformedPath.addLine(to: screenPoint)
            }
        }
        transformedPath.closeSubpath()
        ctx.fill(transformedPath, with: .color(.pink.opacity(0.2)))
        ctx.stroke(transformedPath, with: .color(.pink), lineWidth: 2)
    }
}

#Preview {
    LinearTransformationView()
}
