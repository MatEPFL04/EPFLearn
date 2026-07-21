//
//  GramSchmidtView.swift
//  EPFLearn
//
//  Created on 21.07.2026.
//

import SwiftUI

/// Interactive Gram-Schmidt orthogonalization process
struct GramSchmidtView: View {
    @State private var v1x: Double = 3
    @State private var v1y: Double = 1
    @State private var v2x: Double = 2
    @State private var v2y: Double = 2
    @State private var showSteps = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Gram-Schmidt Process").font(.largeTitle.bold())
                Text("Transform linearly independent vectors into an orthonormal basis.")
                    .font(.callout).foregroundStyle(.secondary)
                
                inputSection
                Toggle("Show calculation steps", isOn: $showSteps)
                    .tint(.pink)
                
                if showSteps {
                    calculationSteps
                }
                
                resultsSection
                visualizationSection
                definitionsSection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Input Vectors").font(.headline)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("v₁").font(.subheadline.weight(.semibold)).foregroundStyle(.pink)
                    HStack {
                        TextField("x", value: $v1x, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                        TextField("y", value: $v1y, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.pink.opacity(0.08)))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("v₂").font(.subheadline.weight(.semibold)).foregroundStyle(.purple)
                    HStack {
                        TextField("x", value: $v2x, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                        TextField("y", value: $v2y, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.purple.opacity(0.08)))
            }
        }
    }
    
    private var calculationSteps: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Calculation Steps").font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Step 1: Normalize v₁")
                    .font(.subheadline.weight(.semibold))
                let norm1 = sqrt(v1x * v1x + v1y * v1y)
                Text("u₁ = v₁ / ||v₁|| = [\(formatted(v1x)), \(formatted(v1y))] / \(formatted(norm1))")
                    .font(.caption.monospaced())
                Text("u₁ = [\(formatted(v1x/norm1)), \(formatted(v1y/norm1))]")
                    .font(.callout.monospaced())
                    .foregroundStyle(.pink)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Step 2: Orthogonalize v₂")
                    .font(.subheadline.weight(.semibold))
                let norm1 = sqrt(v1x * v1x + v1y * v1y)
                let u1x = v1x / norm1
                let u1y = v1y / norm1
                let proj = v2x * u1x + v2y * u1y
                let w2x = v2x - proj * u1x
                let w2y = v2y - proj * u1y
                
                Text("proj = (v₂ · u₁) = \(formatted(proj))")
                    .font(.caption.monospaced())
                Text("w₂ = v₂ - proj·u₁ = [\(formatted(w2x)), \(formatted(w2y))]")
                    .font(.caption.monospaced())
                
                let norm2 = sqrt(w2x * w2x + w2y * w2y)
                Text("u₂ = w₂ / ||w₂|| = [\(formatted(w2x/norm2)), \(formatted(w2y/norm2))]")
                    .font(.callout.monospaced())
                    .foregroundStyle(.purple)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
        }
    }
    
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Orthonormal Basis").font(.headline)
            
            let (u1, u2) = computeOrthonormal()
            
            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("u₁").font(.headline).foregroundStyle(.pink)
                    Text("[\(formatted(u1.0))]")
                        .font(.title3.monospaced())
                    Text("[\(formatted(u1.1))]")
                        .font(.title3.monospaced())
                    Text("||u₁|| = \(formatted(sqrt(u1.0 * u1.0 + u1.1 * u1.1)))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.pink.opacity(0.08)))
                
                VStack(spacing: 8) {
                    Text("u₂").font(.headline).foregroundStyle(.purple)
                    Text("[\(formatted(u2.0))]")
                        .font(.title3.monospaced())
                    Text("[\(formatted(u2.1))]")
                        .font(.title3.monospaced())
                    Text("||u₂|| = \(formatted(sqrt(u2.0 * u2.0 + u2.1 * u2.1)))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.purple.opacity(0.08)))
            }
            
            let dotProduct = u1.0 * u2.0 + u1.1 * u2.1
            Label("u₁ · u₂ = \(formatted(dotProduct)) ≈ 0 ✓ Orthogonal", systemImage: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(abs(dotProduct) < 0.01 ? .green : .red)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.green.opacity(0.12)))
        }
    }
    
    private var visualizationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Visualization").font(.headline)
            
            Canvas { ctx, size in
                drawVectors(ctx, size: size)
            }
            .frame(height: 250)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
            
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Circle().fill(.gray).frame(width: 10)
                    Text("Original v₁, v₂").font(.caption)
                }
                HStack(spacing: 6) {
                    Circle().fill(.pink).frame(width: 10)
                    Text("Orthonormal u₁").font(.caption)
                }
                HStack(spacing: 6) {
                    Circle().fill(.purple).frame(width: 10)
                    Text("Orthonormal u₂").font(.caption)
                }
            }
            .foregroundStyle(.secondary)
        }
    }
    
    private var definitionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Definitions").font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.down.forward.and.arrow.up.backward")
                        .foregroundStyle(.pink)
                        .frame(width: 30)
                    VStack(alignment: .leading) {
                        Text("Orthogonal: u · v = 0")
                            .font(.caption.monospaced())
                        Text("Vectors are perpendicular")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "arrow.up")
                        .foregroundStyle(.pink)
                        .frame(width: 30)
                    VStack(alignment: .leading) {
                        Text("Normalized: ||v|| = 1")
                            .font(.caption.monospaced())
                        Text("Vector has unit length")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle")
                        .foregroundStyle(.pink)
                        .frame(width: 30)
                    VStack(alignment: .leading) {
                        Text("Orthonormal: orthogonal + normalized")
                            .font(.caption.monospaced())
                        Text("Perfect basis for computations")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
        }
    }
    
    private func computeOrthonormal() -> ((Double, Double), (Double, Double)) {
        // u1 = v1 / ||v1||
        let norm1 = sqrt(v1x * v1x + v1y * v1y)
        let u1x = v1x / norm1
        let u1y = v1y / norm1
        
        // w2 = v2 - (v2 · u1)u1
        let proj = v2x * u1x + v2y * u1y
        let w2x = v2x - proj * u1x
        let w2y = v2y - proj * u1y
        
        // u2 = w2 / ||w2||
        let norm2 = sqrt(w2x * w2x + w2y * w2y)
        let u2x = w2x / norm2
        let u2y = w2y / norm2
        
        return ((u1x, u1y), (u2x, u2y))
    }
    
    private func drawVectors(_ ctx: GraphicsContext, size: CGSize) {
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
        
        let origin = CGPoint(x: centerX, y: centerY)
        
        // Original vectors (dashed)
        drawVector(ctx, from: origin,
                   to: CGPoint(x: centerX + CGFloat(v1x) * scale,
                              y: centerY - CGFloat(v1y) * scale),
                   color: .gray, dashed: true)
        drawVector(ctx, from: origin,
                   to: CGPoint(x: centerX + CGFloat(v2x) * scale,
                              y: centerY - CGFloat(v2y) * scale),
                   color: .gray, dashed: true)
        
        // Orthonormal vectors
        let (u1, u2) = computeOrthonormal()
        drawVector(ctx, from: origin,
                   to: CGPoint(x: centerX + CGFloat(u1.0) * scale * 2,
                              y: centerY - CGFloat(u1.1) * scale * 2),
                   color: .pink)
        drawVector(ctx, from: origin,
                   to: CGPoint(x: centerX + CGFloat(u2.0) * scale * 2,
                              y: centerY - CGFloat(u2.1) * scale * 2),
                   color: .purple)
    }
    
    private func drawVector(_ ctx: GraphicsContext, from: CGPoint, to: CGPoint, color: Color, dashed: Bool = false) {
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        
        if dashed {
            ctx.stroke(path, with: .color(color.opacity(0.5)), style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
        } else {
            ctx.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        }
        
        // Arrow
        let angle = atan2(to.y - from.y, to.x - from.x)
        var arrow = Path()
        arrow.move(to: to)
        arrow.addLine(to: CGPoint(x: to.x - 10 * cos(angle - .pi/6), y: to.y - 10 * sin(angle - .pi/6)))
        arrow.move(to: to)
        arrow.addLine(to: CGPoint(x: to.x - 10 * cos(angle + .pi/6), y: to.y - 10 * sin(angle + .pi/6)))
        ctx.stroke(arrow, with: .color(color), lineWidth: dashed ? 2 : 3)
    }
    
    private func formatted(_ value: Double) -> String {
        String(format: "%.2f", value)
    }
}

#Preview {
    GramSchmidtView()
}
