//
//  EigenvalueView.swift
//  EPFLearn
//
//  Created on 21.07.2026.
//

import SwiftUI

/// Interactive eigenvalue and eigenvector visualization for 2×2 matrices
struct EigenvalueView: View {
    @State private var a11: Double = 3
    @State private var a12: Double = 1
    @State private var a21: Double = 0
    @State private var a22: Double = 2
    @State private var showVectors = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                matrixInputSection
                eigenvaluesSection
                eigenvectorsSection
                visualizationSection
                propertiesSection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Eigenvalues & Eigenvectors").font(.largeTitle.bold())
            Text("An eigenvector v satisfies Av = λv, where λ is the eigenvalue. The matrix only scales the eigenvector, without changing its direction.")
                .font(.callout).foregroundStyle(.secondary)
        }
    }
    
    private var matrixInputSection: some View {
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
            
            // Quick presets
            HStack(spacing: 8) {
                Button("Identity") {
                    a11 = 1; a12 = 0; a21 = 0; a22 = 1
                }
                .buttonStyle(.bordered)
                .tint(.pink)
                
                Button("Diagonal") {
                    a11 = 3; a12 = 0; a21 = 0; a22 = 2
                }
                .buttonStyle(.bordered)
                .tint(.pink)
                
                Button("Symmetric") {
                    a11 = 2; a12 = 1; a21 = 1; a22 = 3
                }
                .buttonStyle(.bordered)
                .tint(.pink)
            }
            .font(.caption)
        }
    }
    
    private var eigenvaluesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Eigenvalues").font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Characteristic equation: det(A - λI) = 0")
                    .font(.system(.callout, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.pink.opacity(0.12)))
                
                let (lambda1, lambda2) = calculateEigenvalues()
                
                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("λ₁")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(formatted(lambda1))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.pink)
                            .contentTransition(.numericText())
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.pink.opacity(0.08)))
                    
                    VStack(spacing: 4) {
                        Text("λ₂")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(formatted(lambda2))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.purple)
                            .contentTransition(.numericText())
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.purple.opacity(0.08)))
                }
            }
        }
    }
    
    private var eigenvectorsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Eigenvectors").font(.headline)
            
            let (lambda1, lambda2) = calculateEigenvalues()
            let v1 = calculateEigenvector(lambda: lambda1)
            let v2 = calculateEigenvector(lambda: lambda2)
            
            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("v₁")
                        .font(.headline)
                        .foregroundStyle(.pink)
                    
                    VStack(spacing: 4) {
                        Text("[\(formatted(v1.0))]")
                            .font(.title3.monospaced())
                        Text("[\(formatted(v1.1))]")
                            .font(.title3.monospaced())
                    }
                    .foregroundStyle(.pink)
                    
                    Text("for λ₁ = \(formatted(lambda1))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.pink.opacity(0.08)))
                
                VStack(spacing: 8) {
                    Text("v₂")
                        .font(.headline)
                        .foregroundStyle(.purple)
                    
                    VStack(spacing: 4) {
                        Text("[\(formatted(v2.0))]")
                            .font(.title3.monospaced())
                        Text("[\(formatted(v2.1))]")
                            .font(.title3.monospaced())
                    }
                    .foregroundStyle(.purple)
                    
                    Text("for λ₂ = \(formatted(lambda2))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.purple.opacity(0.08)))
            }
        }
    }
    
    private var visualizationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Vector Space Visualization").font(.headline)
                Spacer()
                Toggle("Show vectors", isOn: $showVectors)
                    .labelsHidden()
            }
            
            Canvas { ctx, size in
                drawVectorSpace(ctx, size: size)
            }
            .frame(height: 300)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
            
            if showVectors {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 12) {
                        Circle().fill(.pink).frame(width: 12, height: 12)
                        Text("Eigenvector v₁ (pink)")
                            .font(.caption)
                    }
                    HStack(spacing: 12) {
                        Circle().fill(.purple).frame(width: 12, height: 12)
                        Text("Eigenvector v₂ (purple)")
                            .font(.caption)
                    }
                }
                .foregroundStyle(.secondary)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.tertiarySystemGroupedBackground)))
            }
        }
    }
    
    private var propertiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Properties").font(.headline)
            
            let (lambda1, lambda2) = calculateEigenvalues()
            
            propertyCard(
                title: "Trace",
                formula: "tr(A) = λ₁ + λ₂",
                description: "Sum of eigenvalues = sum of diagonal elements = \(formatted(a11 + a22))",
                icon: "plus"
            )
            
            propertyCard(
                title: "Determinant",
                formula: "det(A) = λ₁ × λ₂",
                description: "Product of eigenvalues = determinant = \(formatted(a11 * a22 - a12 * a21))",
                icon: "multiply"
            )
            
            propertyCard(
                title: "Scaling",
                formula: "Av = λv",
                description: "Matrix only scales eigenvector, doesn't change direction",
                icon: "arrow.up.and.down"
            )
            
            propertyCard(
                title: "Diagonalization",
                formula: "A = PDP⁻¹",
                description: "If A has n independent eigenvectors, it's diagonalizable",
                icon: "square.grid.2x2"
            )
        }
    }
    
    private func propertyCard(title: String, formula: String, description: String, icon: String) -> some View {
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
    
    // MARK: - Calculations
    
    private func calculateEigenvalues() -> (Double, Double) {
        // For 2×2 matrix: λ² - tr(A)λ + det(A) = 0
        let trace = a11 + a22
        let det = a11 * a22 - a12 * a21
        
        let discriminant = trace * trace - 4 * det
        
        if discriminant >= 0 {
            let sqrtDisc = sqrt(discriminant)
            let lambda1 = (trace + sqrtDisc) / 2
            let lambda2 = (trace - sqrtDisc) / 2
            return (lambda1, lambda2)
        } else {
            // Complex eigenvalues - show real part only
            return (trace / 2, trace / 2)
        }
    }
    
    private func calculateEigenvector(lambda: Double) -> (Double, Double) {
        // Solve (A - λI)v = 0
        let b11 = a11 - lambda
        let b12 = a12
        let b21 = a21
        let b22 = a22 - lambda
        
        // Use first row: b11*x + b12*y = 0
        if abs(b12) > 0.001 {
            // y = -b11/b12 * x, let x = 1
            return (1.0, -b11 / b12)
        } else if abs(b11) > 0.001 {
            // x = 0, y = 1
            return (0.0, 1.0)
        } else {
            // Use second row
            if abs(b22) > 0.001 {
                return (1.0, -b21 / b22)
            } else {
                return (1.0, 0.0)
            }
        }
    }
    
    private func drawVectorSpace(_ ctx: GraphicsContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let scale: CGFloat = 40
        
        // Draw axes
        var axes = Path()
        axes.move(to: CGPoint(x: 0, y: centerY))
        axes.addLine(to: CGPoint(x: size.width, y: centerY))
        axes.move(to: CGPoint(x: centerX, y: 0))
        axes.addLine(to: CGPoint(x: centerX, y: size.height))
        ctx.stroke(axes, with: .color(.secondary.opacity(0.3)), lineWidth: 1)
        
        guard showVectors else { return }
        
        let (lambda1, lambda2) = calculateEigenvalues()
        let v1 = calculateEigenvector(lambda: lambda1)
        let v2 = calculateEigenvector(lambda: lambda2)
        
        // Draw eigenvectors
        drawVector(ctx, from: CGPoint(x: centerX, y: centerY),
                   to: CGPoint(x: centerX + CGFloat(v1.0) * scale,
                              y: centerY - CGFloat(v1.1) * scale),
                   color: .pink, label: "v₁")
        
        drawVector(ctx, from: CGPoint(x: centerX, y: centerY),
                   to: CGPoint(x: centerX + CGFloat(v2.0) * scale,
                              y: centerY - CGFloat(v2.1) * scale),
                   color: .purple, label: "v₂")
    }
    
    private func drawVector(_ ctx: GraphicsContext, from: CGPoint, to: CGPoint, color: Color, label: String) {
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        ctx.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        
        // Arrow head
        let angle = atan2(to.y - from.y, to.x - from.x)
        let arrowLength: CGFloat = 10
        let arrowAngle: CGFloat = .pi / 6
        
        var arrowPath = Path()
        arrowPath.move(to: to)
        arrowPath.addLine(to: CGPoint(
            x: to.x - arrowLength * cos(angle - arrowAngle),
            y: to.y - arrowLength * sin(angle - arrowAngle)
        ))
        arrowPath.move(to: to)
        arrowPath.addLine(to: CGPoint(
            x: to.x - arrowLength * cos(angle + arrowAngle),
            y: to.y - arrowLength * sin(angle + arrowAngle)
        ))
        ctx.stroke(arrowPath, with: .color(color), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        
        // Label
        ctx.draw(
            Text(label).font(.caption.bold()).foregroundStyle(color),
            at: CGPoint(x: to.x + 15, y: to.y - 5)
        )
    }
    
    private func formatted(_ value: Double) -> String {
        String(format: "%.2f", value)
    }
}

#Preview {
    EigenvalueView()
}
