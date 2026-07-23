//
//  SVDVisualView.swift
//  EPFLearn
//
//  Created on 21.07.2026.
//

import SwiftUI

/// Visual SVD: See the 3-step transformation A = UΣVᵀ
struct SVDVisualView: View {
    @State private var currentStep: Int = 0 // 0=original, 1=Vᵀ, 2=Σ, 3=U
    @State private var autoPlay = false
    
    // Simple 2×2 example matrix
    private let a11: Double = 3
    private let a12: Double = 1
    private let a21: Double = 1
    private let a22: Double = 2
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("SVD: A = UΣVᵀ").font(.largeTitle.bold())
                Text("See how ANY matrix is actually 3 simple transformations!")
                    .font(.callout).foregroundStyle(.secondary)
                
                stepControls
                visualizationSection
                explanationSection
                formulaSection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var stepControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Transformation Steps").font(.headline)
            
            HStack {
                ForEach(0...3, id: \.self) { step in
                    Button {
                        withAnimation(.spring(duration: 0.4)) {
                            currentStep = step
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Circle()
                                .fill(currentStep >= step ? Color.pink : Color.gray.opacity(0.3))
                                .frame(width: 30, height: 30)
                                .overlay {
                                    Text(stepLabel(step))
                                        .font(.caption.bold())
                                        .foregroundStyle(.white)
                                }
                            
                            Text(stepName(step))
                                .font(.caption2)
                                .foregroundStyle(currentStep == step ? .primary : .secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    
                    if step < 3 {
                        Rectangle()
                            .fill(currentStep > step ? Color.pink : Color.gray.opacity(0.3))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            
            HStack {
                Button {
                    if currentStep > 0 {
                        withAnimation(.spring(duration: 0.4)) {
                            currentStep -= 1
                        }
                    }
                } label: {
                    Label("Previous", systemImage: "chevron.left")
                }
                .buttonStyle(.bordered)
                .disabled(currentStep == 0)
                
                Spacer()
                
                Button(autoPlay ? "Stop" : "Auto Play") {
                    autoPlay.toggle()
                    if autoPlay {
                        playSteps()
                    }
                }
                .buttonStyle(.bordered)
                .tint(.pink)
                
                Spacer()
                
                Button {
                    if currentStep < 3 {
                        withAnimation(.spring(duration: 0.4)) {
                            currentStep += 1
                        }
                    }
                } label: {
                    Label("Next", systemImage: "chevron.right")
                }
                .buttonStyle(.bordered)
                .disabled(currentStep == 3)
            }
        }
    }
    
    private var visualizationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Watch the Circle Transform").font(.headline)
            
            Canvas { ctx, size in
                drawSVDTransformation(ctx, size: size)
            }
            .frame(height: 400)
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.05), Color.pink.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.pink.opacity(0.2), lineWidth: 2)
            )
            .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Circle().fill(.blue.opacity(0.3)).frame(width: 12)
                    Text("Unit circle (start)")
                        .font(.caption)
                }
                HStack(spacing: 12) {
                    Circle().fill(.pink).frame(width: 12)
                    Text("After transformation (current step)")
                        .font(.caption)
                }
            }
            .foregroundStyle(.secondary)
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.tertiarySystemGroupedBackground)))
        }
    }
    
    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(stepDescription)
                .font(.subheadline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 12).fill(stepColor.opacity(0.12)))
                .foregroundStyle(stepColor)
        }
    }
    
    private var formulaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("The 3 Steps").font(.headline)
            
            stepCard(
                number: 1,
                title: "Vᵀ: Rotate",
                formula: "Vᵀ rotates to align with principal axes",
                color: .blue,
                icon: "arrow.triangle.2.circlepath",
                active: currentStep >= 1
            )
            
            stepCard(
                number: 2,
                title: "Σ: Scale",
                formula: "Σ stretches along axes (singular values)",
                color: .purple,
                icon: "arrow.up.left.and.arrow.down.right",
                active: currentStep >= 2
            )
            
            stepCard(
                number: 3,
                title: "U: Rotate",
                formula: "U rotates to final orientation",
                color: .pink,
                icon: "arrow.triangle.2.circlepath",
                active: currentStep >= 3
            )
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Why SVD?").font(.subheadline.weight(.semibold))
                
                Label("Data compression: keep largest σ values", systemImage: "arrow.down.circle")
                    .font(.caption)
                Label("Image processing: reduce file size", systemImage: "photo")
                    .font(.caption)
                Label("Recommendation systems: find patterns", systemImage: "star")
                    .font(.caption)
                Label("Any matrix can be decomposed this way!", systemImage: "sparkles")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
        }
    }
    
    private func stepCard(number: Int, title: String, formula: String, color: Color, icon: String, active: Bool) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(active ? color : Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                VStack(spacing: 2) {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundStyle(.white)
                    Text("\(number)")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline.weight(.semibold))
                    .foregroundStyle(active ? .primary : .secondary)
                Text(formula).font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if active {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(active ? color.opacity(0.08) : Color(.secondarySystemGroupedBackground)))
    }
    
    // MARK: - Drawing
    
    private func drawSVDTransformation(_ ctx: GraphicsContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let scale: CGFloat = 80
        
        // Draw axes
        drawAxes(ctx, size: size, centerX: centerX, centerY: centerY)
        
        // Draw original unit circle (faint)
        drawCircle(ctx, centerX: centerX, centerY: centerY, scale: scale, color: .blue.opacity(0.2))
        
        // Draw transformed shape based on current step
        drawTransformedShape(ctx, centerX: centerX, centerY: centerY, scale: scale)
    }
    
    private func drawAxes(_ ctx: GraphicsContext, size: CGSize, centerX: CGFloat, centerY: CGFloat) {
        var axes = Path()
        axes.move(to: CGPoint(x: 0, y: centerY))
        axes.addLine(to: CGPoint(x: size.width, y: centerY))
        axes.move(to: CGPoint(x: centerX, y: 0))
        axes.addLine(to: CGPoint(x: centerX, y: size.height))
        ctx.stroke(axes, with: .color(.secondary.opacity(0.5)), lineWidth: 1.5)
        
        // Grid
        for i in stride(from: -3, through: 3, by: 1) {
            if i == 0 { continue }
            var vLine = Path()
            vLine.move(to: CGPoint(x: centerX + CGFloat(i) * 80, y: 0))
            vLine.addLine(to: CGPoint(x: centerX + CGFloat(i) * 80, y: size.height))
            ctx.stroke(vLine, with: .color(.secondary.opacity(0.1)), lineWidth: 0.5)
            
            var hLine = Path()
            hLine.move(to: CGPoint(x: 0, y: centerY + CGFloat(i) * 80))
            hLine.addLine(to: CGPoint(x: size.width, y: centerY + CGFloat(i) * 80))
            ctx.stroke(hLine, with: .color(.secondary.opacity(0.1)), lineWidth: 0.5)
        }
    }
    
    private func drawCircle(_ ctx: GraphicsContext, centerX: CGFloat, centerY: CGFloat, scale: CGFloat, color: Color) {
        var path = Path()
        let points = 50
        for i in 0...points {
            let angle = Double(i) * 2 * .pi / Double(points)
            let x = cos(angle)
            let y = sin(angle)
            
            let screenX = centerX + CGFloat(x) * scale
            let screenY = centerY - CGFloat(y) * scale
            
            if i == 0 {
                path.move(to: CGPoint(x: screenX, y: screenY))
            } else {
                path.addLine(to: CGPoint(x: screenX, y: screenY))
            }
        }
        path.closeSubpath()
        ctx.stroke(path, with: .color(color), lineWidth: 2)
    }
    
    private func drawTransformedShape(_ ctx: GraphicsContext, centerX: CGFloat, centerY: CGFloat, scale: CGFloat) {
        var path = Path()
        let points = 50
        
        for i in 0...points {
            let angle = Double(i) * 2 * .pi / Double(points)
            var x = cos(angle)
            var y = sin(angle)
            
            // Apply transformations based on current step
            switch currentStep {
            case 1: // Vᵀ (rotation)
                let theta = -0.3 // Rotate -17°
                let newX = cos(theta) * x - sin(theta) * y
                let newY = sin(theta) * x + cos(theta) * y
                x = newX
                y = newY
                
            case 2: // Vᵀ + Σ (rotation + scaling)
                let theta = -0.3
                var newX = cos(theta) * x - sin(theta) * y
                var newY = sin(theta) * x + cos(theta) * y
                // Scale by singular values
                newX *= 2.0  // σ₁
                newY *= 0.7  // σ₂
                x = newX
                y = newY
                
            case 3: // Full transformation: U·Σ·Vᵀ
                // Vᵀ
                let theta1 = -0.3
                var newX = cos(theta1) * x - sin(theta1) * y
                var newY = sin(theta1) * x + cos(theta1) * y
                // Σ
                newX *= 2.0
                newY *= 0.7
                // U (final rotation)
                let theta2 = 0.5
                let finalX = cos(theta2) * newX - sin(theta2) * newY
                let finalY = sin(theta2) * newX + cos(theta2) * newY
                x = finalX
                y = finalY
                
            default: // 0 = original circle
                break
            }
            
            let screenX = centerX + CGFloat(x) * scale
            let screenY = centerY - CGFloat(y) * scale
            
            if i == 0 {
                path.move(to: CGPoint(x: screenX, y: screenY))
            } else {
                path.addLine(to: CGPoint(x: screenX, y: screenY))
            }
        }
        path.closeSubpath()
        
        ctx.fill(path, with: .color(stepColor.opacity(0.2)))
        ctx.stroke(path, with: .color(stepColor), lineWidth: 3)
    }
    
    // MARK: - Helpers
    
    private var stepColor: Color {
        switch currentStep {
        case 0: return .blue
        case 1: return .blue
        case 2: return .purple
        case 3: return .pink
        default: return .pink
        }
    }
    
    private var stepDescription: String {
        switch currentStep {
        case 0:
            return "🔵 Start: Unit circle in 2D space"
        case 1:
            return "🔵 Step 1 (Vᵀ): Rotate to align with principal directions"
        case 2:
            return "🟣 Step 2 (Σ): Stretch by singular values σ₁ and σ₂"
        case 3:
            return "🌸 Step 3 (U): Final rotation to output orientation"
        default:
            return ""
        }
    }
    
    private func stepLabel(_ step: Int) -> String {
        switch step {
        case 0: return "●"
        case 1: return "Vᵀ"
        case 2: return "Σ"
        case 3: return "U"
        default: return ""
        }
    }
    
    private func stepName(_ step: Int) -> String {
        switch step {
        case 0: return "Start"
        case 1: return "Rotate"
        case 2: return "Scale"
        case 3: return "Rotate"
        default: return ""
        }
    }
    
    private func playSteps() {
        guard autoPlay else { return }
        
        if currentStep < 3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.spring(duration: 0.4)) {
                    self.currentStep += 1
                }
                self.playSteps()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.spring(duration: 0.4)) {
                    self.currentStep = 0
                }
                self.playSteps()
            }
        }
    }
}

#Preview {
    SVDVisualView()
}
