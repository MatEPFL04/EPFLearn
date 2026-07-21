//
//  VectorSpaceView.swift
//  EPFLearn
//
//  Created on 21.07.2026.
//

import SwiftUI

/// Interactive vector space visualization
struct VectorSpaceView: View {
    @State private var v1x: Double = 1
    @State private var v1y: Double = 0
    @State private var v2x: Double = 0
    @State private var v2y: Double = 1
    @State private var alpha: Double = 1.5
    @State private var beta: Double = 0.8
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                vectorInputSection
                linearCombinationSection
                visualizationSection
                conceptsSection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Vector Spaces").font(.largeTitle.bold())
            Text("A vector space is closed under addition and scalar multiplication. Explore linear combinations, span, and linear independence.")
                .font(.callout).foregroundStyle(.secondary)
        }
    }
    
    private var vectorInputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Base Vectors").font(.headline)
            
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
    
    private var linearCombinationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Linear Combination").font(.headline)
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("α (coefficient for v₁)")
                            .font(.subheadline)
                        Spacer()
                        Text(String(format: "%.1f", alpha))
                            .font(.subheadline.monospacedDigit().weight(.semibold))
                            .padding(.horizontal, 8).padding(.vertical, 2)
                            .background(Capsule().fill(Color.pink.opacity(0.15)))
                            .foregroundStyle(.pink)
                    }
                    Slider(value: $alpha, in: -2...2, step: 0.1).tint(.pink)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("β (coefficient for v₂)")
                            .font(.subheadline)
                        Spacer()
                        Text(String(format: "%.1f", beta))
                            .font(.subheadline.monospacedDigit().weight(.semibold))
                            .padding(.horizontal, 8).padding(.vertical, 2)
                            .background(Capsule().fill(Color.purple.opacity(0.15)))
                            .foregroundStyle(.purple)
                    }
                    Slider(value: $beta, in: -2...2, step: 0.1).tint(.purple)
                }
            }
            
            let resultX = alpha * v1x + beta * v2x
            let resultY = alpha * v1y + beta * v2y
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Result: w = αv₁ + βv₂")
                    .font(.subheadline.weight(.medium))
                Text("w = \(formatted(alpha))·[\(formatted(v1x)), \(formatted(v1y))] + \(formatted(beta))·[\(formatted(v2x)), \(formatted(v2y))]")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                Text("w = [\(formatted(resultX)), \(formatted(resultY))]")
                    .font(.callout.monospaced().weight(.semibold))
                    .foregroundStyle(.green)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
        }
    }
    
    private var visualizationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Visualization").font(.headline)
            
            Canvas { ctx, size in
                drawVectors(ctx, size: size)
            }
            .frame(height: 300)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
            
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Circle().fill(.pink).frame(width: 10)
                    Text("v₁").font(.caption)
                }
                HStack(spacing: 6) {
                    Circle().fill(.purple).frame(width: 10)
                    Text("v₂").font(.caption)
                }
                HStack(spacing: 6) {
                    Circle().fill(.green).frame(width: 10)
                    Text("w = αv₁ + βv₂").font(.caption)
                }
            }
            .foregroundStyle(.secondary)
        }
    }
    
    private var conceptsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Concepts").font(.headline)
            
            conceptCard(
                title: "Linear Independence",
                formula: "c₁v₁ + c₂v₂ + ... + cₙvₙ = 0 ⟹ all cᵢ = 0",
                description: "Vectors are linearly independent if no vector can be written as a combination of others",
                icon: "arrow.triangle.branch"
            )
            
            conceptCard(
                title: "Span",
                formula: "span(v₁, v₂, ..., vₙ) = all linear combinations",
                description: "The set of all vectors that can be created from linear combinations",
                icon: "square.3.layers.3d"
            )
            
            conceptCard(
                title: "Basis",
                formula: "Linearly independent + spans V",
                description: "A minimal set of vectors that spans the entire space",
                icon: "square.grid.2x2"
            )
            
            conceptCard(
                title: "Dimension",
                formula: "dim(V) = number of vectors in any basis",
                description: "The number of vectors needed to span the space",
                icon: "number"
            )
        }
    }
    
    private func conceptCard(title: String, formula: String, description: String, icon: String) -> some View {
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
    
    private func drawVectors(_ ctx: GraphicsContext, size: CGSize) {
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
        
        let origin = CGPoint(x: centerX, y: centerY)
        
        // Draw v1
        drawVector(ctx, from: origin,
                   to: CGPoint(x: centerX + CGFloat(v1x) * scale,
                              y: centerY - CGFloat(v1y) * scale),
                   color: .pink)
        
        // Draw v2
        drawVector(ctx, from: origin,
                   to: CGPoint(x: centerX + CGFloat(v2x) * scale,
                              y: centerY - CGFloat(v2y) * scale),
                   color: .purple)
        
        // Draw result w
        let resultX = alpha * v1x + beta * v2x
        let resultY = alpha * v1y + beta * v2y
        drawVector(ctx, from: origin,
                   to: CGPoint(x: centerX + CGFloat(resultX) * scale,
                              y: centerY - CGFloat(resultY) * scale),
                   color: .green, lineWidth: 3)
    }
    
    private func drawVector(_ ctx: GraphicsContext, from: CGPoint, to: CGPoint, color: Color, lineWidth: CGFloat = 2) {
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        ctx.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        
        // Arrow
        let angle = atan2(to.y - from.y, to.x - from.x)
        let arrowLength: CGFloat = 12
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
    
    private func formatted(_ value: Double) -> String {
        String(format: "%.1f", value)
    }
}

#Preview {
    VectorSpaceView()
}
