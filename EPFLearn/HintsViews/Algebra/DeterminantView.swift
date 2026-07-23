//
//  DeterminantView.swift
//  EPFLearn
//
//  Created on 21.07.2026.
//

import SwiftUI

/// Visual determinant explorer with geometric interpretation
struct DeterminantView: View {
    @State private var a: Double = 2
    @State private var b: Double = 1
    @State private var c: Double = 1
    @State private var d: Double = 2
    
    private var determinant: Double { a * d - b * c }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Determinant").font(.largeTitle.bold())
                
                matrixControls
                geometricVisualization
                resultCard
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var matrixControls: some View {
        HStack(spacing: 12) {
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    pickerCompact(value: $a, color: .pink)
                    pickerCompact(value: $b, color: .pink)
                }
                HStack(spacing: 8) {
                    pickerCompact(value: $c, color: .purple)
                    pickerCompact(value: $d, color: .purple)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
    }
    
    private func pickerCompact(value: Binding<Double>, color: Color) -> some View {
        Picker("", selection: value) {
            ForEach(Array(stride(from: -3.0, through: 3.0, by: 0.5)), id: \.self) { val in
                Text(String(format: "%.1f", val)).tag(val)
            }
        }
        .pickerStyle(.wheel)
        .frame(width: 70, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .background(RoundedRectangle(cornerRadius: 8).stroke(color, lineWidth: 2))
    }
    
    private var geometricVisualization: some View {
        Canvas { ctx, size in
            drawParallelogram(ctx, size: size)
        }
        .frame(height: 280)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
    }
    
    private func drawParallelogram(_ ctx: GraphicsContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let scale: CGFloat = 40
        
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
        
        // Unit square (before transformation)
        let unitSquare = Path { p in
            let origin = CGPoint(x: centerX, y: centerY)
            p.move(to: origin)
            p.addLine(to: CGPoint(x: centerX + scale, y: centerY))
            p.addLine(to: CGPoint(x: centerX + scale, y: centerY - scale))
            p.addLine(to: CGPoint(x: centerX, y: centerY - scale))
            p.closeSubpath()
        }
        ctx.stroke(unitSquare, with: .color(.gray.opacity(0.3)), style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
        
        // Transformed parallelogram (shows determinant as area)
        let transformed = Path { p in
            let origin = CGPoint(x: centerX, y: centerY)
            let v1 = CGPoint(x: centerX + CGFloat(a) * scale, y: centerY - CGFloat(c) * scale)
            let v2 = CGPoint(x: centerX + CGFloat(b) * scale, y: centerY - CGFloat(d) * scale)
            let v3 = CGPoint(x: centerX + CGFloat(a + b) * scale, y: centerY - CGFloat(c + d) * scale)
            
            p.move(to: origin)
            p.addLine(to: v1)
            p.addLine(to: v3)
            p.addLine(to: v2)
            p.closeSubpath()
        }
        
        let fillColor: Color = determinant >= 0 ? .green : .red
        ctx.fill(transformed, with: .color(fillColor.opacity(0.3)))
        ctx.stroke(transformed, with: .color(fillColor), lineWidth: 3)
        
        // Vector labels
        let v1End = CGPoint(x: centerX + CGFloat(a) * scale, y: centerY - CGFloat(c) * scale)
        let v2End = CGPoint(x: centerX + CGFloat(b) * scale, y: centerY - CGFloat(d) * scale)
        
        drawVector(ctx, from: CGPoint(x: centerX, y: centerY), to: v1End, color: .pink, label: "v₁")
        drawVector(ctx, from: CGPoint(x: centerX, y: centerY), to: v2End, color: .purple, label: "v₂")
    }
    
    private func drawVector(_ ctx: GraphicsContext, from: CGPoint, to: CGPoint, color: Color, label: String) {
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        ctx.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        
        // Arrow head
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
        ctx.stroke(arrow, with: .color(color), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        
        // Label
        ctx.draw(
            Text(label).font(.headline).foregroundStyle(color),
            at: CGPoint(x: to.x + 20, y: to.y - 10)
        )
    }
    
    private var resultCard: some View {
        HStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("det(A)")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text(String(format: "%.2f", determinant))
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(determinantColor)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(determinantColor.opacity(0.1)))
            
            VStack(spacing: 8) {
                Image(systemName: determinant == 0 ? "xmark.circle.fill" : "checkmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(determinant == 0 ? .red : .green)
                Text(determinant == 0 ? "Singular" : "Invertible")
                    .font(.caption)
                Text("Area = \(String(format: "%.1f", abs(determinant)))")
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
    }
    
    private var determinantColor: Color {
        if abs(determinant) < 0.001 {
            return .red
        } else if determinant > 0 {
            return .green
        } else {
            return .orange
        }
    }
}

#Preview {
    DeterminantView()
}
