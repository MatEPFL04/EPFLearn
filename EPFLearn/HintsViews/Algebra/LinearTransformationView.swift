//
//  LinearTransformationView.swift
//  EPFLearn
//
//  Created on 21.07.2026.
//

import SwiftUI

/// Interactive linear transformation visualizer
struct LinearTransformationView: View {
    @State private var a11: Double = 2
    @State private var a12: Double = 0
    @State private var a21: Double = 0
    @State private var a22: Double = 1.5
    @State private var animationProgress: Double = 0
    @State private var isAnimating = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Linear Transformations").font(.largeTitle.bold())
                
                matrixPicker
                gridVisualization
                presetsSection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            startAutoAnimation()
        }
    }
    
    private var matrixPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Transformation Matrix A").font(.headline)
                Spacer()
                Button(isAnimating ? "⏸" : "▶︎") {
                    isAnimating.toggle()
                    if isAnimating {
                        startAutoAnimation()
                    }
                }
                .font(.title2)
                .buttonStyle(.borderless)
            }
            
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    matrixValuePicker(value: $a11, color: .pink)
                    matrixValuePicker(value: $a21, color: .purple)
                }
                VStack(spacing: 8) {
                    matrixValuePicker(value: $a12, color: .pink)
                    matrixValuePicker(value: $a22, color: .purple)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
            
            let det = a11 * a22 - a12 * a21
            HStack(spacing: 8) {
                Image(systemName: det > 0 ? "arrow.clockwise" : "arrow.counterclockwise")
                    .foregroundStyle(det > 0 ? .green : .orange)
                Text("det(A) = \(formatted(det))")
                    .font(.caption.monospaced())
                Spacer()
                if abs(det) < 0.1 {
                    Text("⚠️ Collapses space!")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
    }
    
    private func matrixValuePicker(value: Binding<Double>, color: Color) -> some View {
        HStack(spacing: 4) {
            Button {
                withAnimation(.spring(duration: 0.2)) {
                    value.wrappedValue = max(-3, value.wrappedValue - 0.5)
                }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(color)
            }
            .buttonStyle(.borderless)
            
            Text(formatted(value.wrappedValue))
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundStyle(color)
                .frame(width: 70)
                .contentTransition(.numericText())
            
            Button {
                withAnimation(.spring(duration: 0.2)) {
                    value.wrappedValue = min(3, value.wrappedValue + 0.5)
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(color)
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 12).fill(color.opacity(0.1)))
    }
    
    private var gridVisualization: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live Grid Transformation").font(.headline)
            
            Canvas { ctx, size in
                drawGridTransform(ctx, size: size)
            }
            .frame(height: 400)
            .background(
                LinearGradient(
                    colors: [Color.pink.opacity(0.05), Color.purple.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.pink.opacity(0.2), lineWidth: 2))
            .cornerRadius(16)
            
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Rectangle().fill(.blue.opacity(0.3)).frame(width: 30, height: 4)
                    Text("Original").font(.caption)
                }
                HStack(spacing: 6) {
                    Rectangle().fill(.pink).frame(width: 30, height: 4)
                    Text("Transformed").font(.caption)
                }
            }
            .foregroundStyle(.secondary)
        }
    }
    
    private var presetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Presets").font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                presetButton(title: "Identity", icon: "equal", a11: 1, a12: 0, a21: 0, a22: 1, color: .gray)
                presetButton(title: "Stretch X", icon: "arrow.left.and.right", a11: 2, a12: 0, a21: 0, a22: 1, color: .pink)
                presetButton(title: "Shear X", icon: "triangle.righthalf.filled", a11: 1, a12: 1, a21: 0, a22: 1, color: .purple)
                presetButton(title: "Rotate 45°", icon: "arrow.triangle.2.circlepath", a11: 0.7, a12: -0.7, a21: 0.7, a22: 0.7, color: .blue)
                presetButton(title: "Reflect Y", icon: "arrow.up.and.down", a11: 1, a12: 0, a21: 0, a22: -1, color: .orange)
                presetButton(title: "Collapse", icon: "arrow.down.to.line", a11: 1, a12: 0, a21: 0, a22: 0, color: .red)
            }
        }
    }
    
    private func presetButton(title: String, icon: String, a11: Double, a12: Double, a21: Double, a22: Double, color: Color) -> some View {
        Button {
            withAnimation(.spring(duration: 0.5)) {
                self.a11 = a11
                self.a12 = a12
                self.a21 = a21
                self.a22 = a22
                animationProgress = 1.0
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(color.opacity(0.1)))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
    
    private func drawGridTransform(_ ctx: GraphicsContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let scale: CGFloat = 50
        
        drawOriginalGrid(ctx, centerX: centerX, centerY: centerY, scale: scale)
        drawTransformedGrid(ctx, centerX: centerX, centerY: centerY, scale: scale)
        drawAxes(ctx, size: size, centerX: centerX, centerY: centerY)
        drawBasisVectors(ctx, centerX: centerX, centerY: centerY, scale: scale)
    }
    
    private func drawOriginalGrid(_ ctx: GraphicsContext, centerX: CGFloat, centerY: CGFloat, scale: CGFloat) {
        for i in stride(from: -4, through: 4, by: 1) {
            var vLine = Path()
            vLine.move(to: CGPoint(x: centerX + CGFloat(i) * scale, y: centerY - 200))
            vLine.addLine(to: CGPoint(x: centerX + CGFloat(i) * scale, y: centerY + 200))
            ctx.stroke(vLine, with: .color(.blue.opacity(0.15)), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
            
            var hLine = Path()
            hLine.move(to: CGPoint(x: centerX - 200, y: centerY + CGFloat(i) * scale))
            hLine.addLine(to: CGPoint(x: centerX + 200, y: centerY + CGFloat(i) * scale))
            ctx.stroke(hLine, with: .color(.blue.opacity(0.15)), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
        }
    }
    
    private func drawTransformedGrid(_ ctx: GraphicsContext, centerX: CGFloat, centerY: CGFloat, scale: CGFloat) {
        let t = animationProgress
        
        for i in stride(from: -4, through: 4, by: 1) {
            var vLine = Path()
            for j in stride(from: -4, through: 4, by: 0.2) {
                let x = Double(i), y = j
                let transformedX = (1 - t) * x + t * (a11 * x + a12 * y)
                let transformedY = (1 - t) * y + t * (a21 * x + a22 * y)
                let screenX = centerX + CGFloat(transformedX) * scale
                let screenY = centerY - CGFloat(transformedY) * scale
                
                if j == -4 {
                    vLine.move(to: CGPoint(x: screenX, y: screenY))
                } else {
                    vLine.addLine(to: CGPoint(x: screenX, y: screenY))
                }
            }
            ctx.stroke(vLine, with: .color(.pink.opacity(0.6)), lineWidth: 2)
            
            var hLine = Path()
            for j in stride(from: -4, through: 4, by: 0.2) {
                let x = j, y = Double(i)
                let transformedX = (1 - t) * x + t * (a11 * x + a12 * y)
                let transformedY = (1 - t) * y + t * (a21 * x + a22 * y)
                let screenX = centerX + CGFloat(transformedX) * scale
                let screenY = centerY - CGFloat(transformedY) * scale
                
                if j == -4 {
                    hLine.move(to: CGPoint(x: screenX, y: screenY))
                } else {
                    hLine.addLine(to: CGPoint(x: screenX, y: screenY))
                }
            }
            ctx.stroke(hLine, with: .color(.purple.opacity(0.6)), lineWidth: 2)
        }
    }
    
    private func drawAxes(_ ctx: GraphicsContext, size: CGSize, centerX: CGFloat, centerY: CGFloat) {
        var axes = Path()
        axes.move(to: CGPoint(x: 0, y: centerY))
        axes.addLine(to: CGPoint(x: size.width, y: centerY))
        axes.move(to: CGPoint(x: centerX, y: 0))
        axes.addLine(to: CGPoint(x: centerX, y: size.height))
        ctx.stroke(axes, with: .color(.secondary.opacity(0.5)), lineWidth: 1.5)
    }
    
    private func drawBasisVectors(_ ctx: GraphicsContext, centerX: CGFloat, centerY: CGFloat, scale: CGFloat) {
        let t = animationProgress
        let origin = CGPoint(x: centerX, y: centerY)
        
        let e1x = (1 - t) * 1 + t * a11
        let e1y = (1 - t) * 0 + t * a21
        let e1End = CGPoint(x: centerX + CGFloat(e1x) * scale, y: centerY - CGFloat(e1y) * scale)
        drawArrow(ctx, from: origin, to: e1End, color: .pink, lineWidth: 4)
        
        let e2x = (1 - t) * 0 + t * a12
        let e2y = (1 - t) * 1 + t * a22
        let e2End = CGPoint(x: centerX + CGFloat(e2x) * scale, y: centerY - CGFloat(e2y) * scale)
        drawArrow(ctx, from: origin, to: e2End, color: .purple, lineWidth: 4)
        
        ctx.draw(Text("e₁").font(.headline.bold()).foregroundStyle(.pink), at: CGPoint(x: e1End.x + 20, y: e1End.y))
        ctx.draw(Text("e₂").font(.headline.bold()).foregroundStyle(.purple), at: CGPoint(x: e2End.x, y: e2End.y - 20))
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
        arrow.addLine(to: CGPoint(x: to.x - arrowLength * cos(angle - arrowAngle), y: to.y - arrowLength * sin(angle - arrowAngle)))
        arrow.move(to: to)
        arrow.addLine(to: CGPoint(x: to.x - arrowLength * cos(angle + arrowAngle), y: to.y - arrowLength * sin(angle + arrowAngle)))
        ctx.stroke(arrow, with: .color(color), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
    }
    
    private func startAutoAnimation() {
        guard isAnimating else { return }
        
        withAnimation(.easeInOut(duration: 2)) {
            animationProgress = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            guard self.isAnimating else { return }
            withAnimation(.easeInOut(duration: 2)) {
                self.animationProgress = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.startAutoAnimation()
            }
        }
    }
    
    private func formatted(_ value: Double) -> String {
        String(format: "%.1f", value)
    }
}

struct LinearTransformationView_Previews: PreviewProvider {
    static var previews: some View {
        LinearTransformationView()
    }
}
