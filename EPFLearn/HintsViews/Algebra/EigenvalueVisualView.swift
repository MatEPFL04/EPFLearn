//
//  EigenvalueVisualView.swift
//  EPFLearn
//
//  Created on 21.07.2026.
//

import SwiftUI

/// Visual eigenvalue demonstration - see how Av = λv works!
struct EigenvalueVisualView: View {
    @State private var a11: Double = 3
    @State private var a12: Double = 1
    @State private var a21: Double = 0
    @State private var a22: Double = 2
    @State private var showTransformed = true
    @State private var selectedVector: Int = 0 // 0 = random, 1 = eigen1, 2 = eigen2
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Eigenvalues & Eigenvectors").font(.largeTitle.bold())
                Text("Watch what happens when you apply matrix A to different vectors!")
                    .font(.callout).foregroundStyle(.secondary)
                
                matrixInput
                vectorPicker
                liveVisualization
                resultsSection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var matrixInput: some View {
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
                Button("Rotation") { a11 = 0.8; a12 = -0.6; a21 = 0.6; a22 = 0.8 }
                    .buttonStyle(.bordered).tint(.pink).font(.caption)
                Button("Stretch") { a11 = 3; a12 = 0; a21 = 0; a22 = 2 }
                    .buttonStyle(.bordered).tint(.pink).font(.caption)
                Button("Shear") { a11 = 1; a12 = 1; a21 = 0; a22 = 1 }
                    .buttonStyle(.bordered).tint(.pink).font(.caption)
            }
        }
    }
    
    private var vectorPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose a vector to transform").font(.headline)
            
            Picker("Vector", selection: $selectedVector) {
                Text("Random vector").tag(0)
                Text("Eigenvector v₁").tag(1)
                Text("Eigenvector v₂").tag(2)
            }
            .pickerStyle(.segmented)
            
            Toggle("Show transformation", isOn: $showTransformed)
                .tint(.pink)
        }
    }
    
    private var liveVisualization: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live Transformation").font(.headline)
            
            Canvas { ctx, size in
                drawTransformation(ctx, size: size)
            }
            .frame(height: 400)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Rectangle().fill(.blue).frame(width: 30, height: 4)
                    Text("Original vector v (blue)")
                        .font(.caption)
                }
                HStack(spacing: 12) {
                    Rectangle().fill(.pink).frame(width: 30, height: 4)
                    Text("Transformed Av (pink)")
                        .font(.caption)
                }
                
                if selectedVector > 0 {
                    let (lambda1, lambda2) = calculateEigenvalues()
                    let lambda = selectedVector == 1 ? lambda1 : lambda2
                    
                    Divider()
                    
                    Text("✨ This is an eigenvector!")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.green)
                    
                    Text("Direction unchanged, only scaled by λ = \(formatted(lambda))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(.secondary)
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.tertiarySystemGroupedBackground)))
        }
    }
    
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Eigenvalues").font(.headline)
            
            let (lambda1, lambda2) = calculateEigenvalues()
            
            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("λ₁").font(.title3.weight(.semibold)).foregroundStyle(.secondary)
                    Text(formatted(lambda1))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.pink)
                        .contentTransition(.numericText())
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.pink.opacity(0.08)))
                
                VStack(spacing: 8) {
                    Text("λ₂").font(.title3.weight(.semibold)).foregroundStyle(.secondary)
                    Text(formatted(lambda2))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.purple)
                        .contentTransition(.numericText())
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.purple.opacity(0.08)))
            }
            
            Text("💡 Eigenvector equation: Av = λv")
                .font(.caption)
                .foregroundStyle(.pink)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.pink.opacity(0.12)))
        }
    }
    
    // MARK: - Drawing
    
    private func drawTransformation(_ ctx: GraphicsContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let scale: CGFloat = 60
        
        // Grid
        drawGrid(ctx, size: size, centerX: centerX, centerY: centerY, scale: scale)
        
        // Axes
        var axes = Path()
        axes.move(to: CGPoint(x: 0, y: centerY))
        axes.addLine(to: CGPoint(x: size.width, y: centerY))
        axes.move(to: CGPoint(x: centerX, y: 0))
        axes.addLine(to: CGPoint(x: centerX, y: size.height))
        ctx.stroke(axes, with: .color(.secondary.opacity(0.5)), lineWidth: 1.5)
        
        let origin = CGPoint(x: centerX, y: centerY)
        
        // Get vector to display
        let v: (Double, Double)
        switch selectedVector {
        case 1:
            let (lambda1, _) = calculateEigenvalues()
            v = calculateEigenvector(lambda: lambda1)
        case 2:
            let (_, lambda2) = calculateEigenvalues()
            v = calculateEigenvector(lambda: lambda2)
        default:
            v = (2.0, 1.5) // Random vector
        }
        
        // Original vector (blue)
        let vEnd = CGPoint(
            x: centerX + CGFloat(v.0) * scale,
            y: centerY - CGFloat(v.1) * scale
        )
        drawArrow(ctx, from: origin, to: vEnd, color: .blue, lineWidth: 3)
        
        // Draw label
        ctx.draw(
            Text("v").font(.headline.bold()).foregroundStyle(.blue),
            at: CGPoint(x: vEnd.x + 20, y: vEnd.y - 10)
        )
        
        // Transformed vector (pink)
        if showTransformed {
            let avx = a11 * v.0 + a12 * v.1
            let avy = a21 * v.0 + a22 * v.1
            
            let avEnd = CGPoint(
                x: centerX + CGFloat(avx) * scale,
                y: centerY - CGFloat(avy) * scale
            )
            
            drawArrow(ctx, from: origin, to: avEnd, color: .pink, lineWidth: 4)
            
            ctx.draw(
                Text("Av").font(.headline.bold()).foregroundStyle(.pink),
                at: CGPoint(x: avEnd.x + 20, y: avEnd.y - 10)
            )
            
            // If it's an eigenvector, show they're collinear
            if selectedVector > 0 {
                var dashedLine = Path()
                dashedLine.move(to: origin)
                let extended = CGPoint(
                    x: centerX + CGFloat(v.0) * scale * 3,
                    y: centerY - CGFloat(v.1) * scale * 3
                )
                dashedLine.addLine(to: extended)
                ctx.stroke(dashedLine, with: .color(.green.opacity(0.3)), style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
            }
        }
    }
    
    private func drawGrid(_ ctx: GraphicsContext, size: CGSize, centerX: CGFloat, centerY: CGFloat, scale: CGFloat) {
        for i in stride(from: -5, through: 5, by: 1) {
            var vLine = Path()
            vLine.move(to: CGPoint(x: centerX + CGFloat(i) * scale, y: 0))
            vLine.addLine(to: CGPoint(x: centerX + CGFloat(i) * scale, y: size.height))
            ctx.stroke(vLine, with: .color(.secondary.opacity(0.1)), lineWidth: 0.5)
            
            var hLine = Path()
            hLine.move(to: CGPoint(x: 0, y: centerY + CGFloat(i) * scale))
            hLine.addLine(to: CGPoint(x: size.width, y: centerY + CGFloat(i) * scale))
            ctx.stroke(hLine, with: .color(.secondary.opacity(0.1)), lineWidth: 0.5)
        }
    }
    
    private func drawArrow(_ ctx: GraphicsContext, from: CGPoint, to: CGPoint, color: Color, lineWidth: CGFloat) {
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        ctx.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        
        let angle = atan2(to.y - from.y, to.x - from.x)
        let arrowLength: CGFloat = 15
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
        ctx.stroke(arrow, with: .color(color), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
    }
    
    // MARK: - Calculations
    
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
    
    private func calculateEigenvector(lambda: Double) -> (Double, Double) {
        let b11 = a11 - lambda
        let b12 = a12
        
        if abs(b12) > 0.001 {
            return (1.0, -b11 / b12)
        } else if abs(b11) > 0.001 {
            return (0.0, 1.0)
        } else {
            let b21 = a21
            let b22 = a22 - lambda
            if abs(b22) > 0.001 {
                return (1.0, -b21 / b22)
            } else {
                return (1.0, 0.0)
            }
        }
    }
    
    private func formatted(_ value: Double) -> String {
        String(format: "%.2f", value)
    }
}

#Preview {
    EigenvalueVisualView()
}
