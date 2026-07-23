//
//  LinearTransformVisualView.swift
//  EPFLearn
//
//  Created on 21.07.2026.
//

import SwiftUI

struct LinearTransformVisualView: View {
    @State private var a11: Double = 2
    @State private var a12: Double = 0
    @State private var a21: Double = 0
    @State private var a22: Double = 1.5
    @State private var vectorX: Double = 1
    @State private var vectorY: Double = 1
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Linear Transformations").font(.largeTitle.bold())
                
                presetsRow
                matrixControls
                gridVisualization
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var presetsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                presetButton("Identity", a11: 1, a12: 0, a21: 0, a22: 1, icon: "square")
                presetButton("Scale 2×", a11: 2, a12: 0, a21: 0, a22: 2, icon: "arrow.up.left.and.arrow.down.right")
                presetButton("Rotate 90°", a11: 0, a12: -1, a21: 1, a22: 0, icon: "rotate.right")
                presetButton("Shear", a11: 1, a12: 1, a21: 0, a22: 1, icon: "arrow.right")
                presetButton("Reflect", a11: -1, a12: 0, a21: 0, a22: 1, icon: "arrow.left.and.right")
                presetButton("Project", a11: 1, a12: 0, a21: 0, a22: 0, icon: "arrow.down.to.line")
            }
        }
    }
    
    private func presetButton(_ name: String, a11: Double, a12: Double, a21: Double, a22: Double, icon: String) -> some View {
        Button {
            withAnimation(.spring(duration: 0.3)) {
                self.a11 = a11
                self.a12 = a12
                self.a21 = a21
                self.a22 = a22
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(name)
                    .font(.caption2)
            }
            .frame(width: 70, height: 60)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.pink.opacity(0.1)))
            .foregroundStyle(.pink)
        }
    }
    
    private var matrixControls: some View {
        HStack(spacing: 12) {
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    pickerCompact(value: $a11, color: .pink)
                    pickerCompact(value: $a12, color: .pink)
                }
                HStack(spacing: 8) {
                    pickerCompact(value: $a21, color: .purple)
                    pickerCompact(value: $a22, color: .purple)
                }
            }
            
            VStack(spacing: 4) {
                Text("det")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(String(format: "%.1f", a11*a22 - a12*a21))
                    .font(.title3.monospaced().bold())
                    .foregroundStyle(determinantColor)
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
    
    private var determinantColor: Color {
        let det = a11*a22 - a12*a21
        return abs(det) < 0.01 ? .red : (det > 0 ? .green : .orange)
    }
    
    private var gridVisualization: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Drag the orange vector").font(.headline)
            
            GeometryReader { geo in
                Canvas { ctx, size in
                    drawGridTransform(ctx, size: size)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let centerX = geo.size.width / 2
                            let centerY = geo.size.height / 2
                            let scale: CGFloat = 60
                            
                            vectorX = Double((value.location.x - centerX) / scale)
                            vectorY = Double((centerY - value.location.y) / scale)
                        }
                )
            }
            .frame(height: 350)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
            
            let transformedX = a11 * vectorX + a12 * vectorY
            let transformedY = a21 * vectorX + a22 * vectorY
            
            HStack(spacing: 12) {
                VStack(spacing: 4) {
                    Text("v").font(.caption.bold()).foregroundStyle(.orange)
                    Text("[\(String(format: "%.1f", vectorX)), \(String(format: "%.1f", vectorY))]")
                        .font(.caption2.monospaced())
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.orange.opacity(0.1)))
                
                Image(systemName: "arrow.right")
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 4) {
                    Text("Av").font(.caption.bold()).foregroundStyle(.cyan)
                    Text("[\(String(format: "%.1f", transformedX)), \(String(format: "%.1f", transformedY))]")
                        .font(.caption2.monospaced())
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.cyan.opacity(0.1)))
            }
        }
    }
    
    private func drawGridTransform(_ ctx: GraphicsContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let scale: CGFloat = 60
        
        // Grid
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
        
        // Axes
        var axes = Path()
        axes.move(to: CGPoint(x: 0, y: centerY))
        axes.addLine(to: CGPoint(x: size.width, y: centerY))
        axes.move(to: CGPoint(x: centerX, y: 0))
        axes.addLine(to: CGPoint(x: centerX, y: size.height))
        ctx.stroke(axes, with: .color(.secondary.opacity(0.5)), lineWidth: 1.5)
        
        // Original vector (orange)
        let origEnd = CGPoint(
            x: centerX + CGFloat(vectorX) * scale,
            y: centerY - CGFloat(vectorY) * scale
        )
        drawArrow(ctx, from: CGPoint(x: centerX, y: centerY), to: origEnd, color: .orange, width: 3)
        
        // Transformed vector (cyan)
        let transformedX = a11 * vectorX + a12 * vectorY
        let transformedY = a21 * vectorX + a22 * vectorY
        let transEnd = CGPoint(
            x: centerX + CGFloat(transformedX) * scale,
            y: centerY - CGFloat(transformedY) * scale
        )
        drawArrow(ctx, from: CGPoint(x: centerX, y: centerY), to: transEnd, color: .cyan, width: 4)
    }
    
    private func drawArrow(_ ctx: GraphicsContext, from: CGPoint, to: CGPoint, color: Color, width: CGFloat) {
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        ctx.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round))
        
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
        ctx.stroke(arrow, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round))
    }
}

#Preview {
    LinearTransformVisualView()
}
