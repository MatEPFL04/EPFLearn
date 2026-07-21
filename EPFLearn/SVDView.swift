//
//  SVDView.swift
//  EPFLearn
//
//  Created on 21.07.2026.
//

import SwiftUI

/// Singular Value Decomposition (SVD) educational view
struct SVDView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Singular Value Decomposition").font(.largeTitle.bold())
                Text("SVD factorizes any m×n matrix A into A = UΣVᵀ, revealing its fundamental structure.")
                    .font(.callout).foregroundStyle(.secondary)
                
                formulaSection
                componentsSection
                applicationsSection
                interpretationSection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var formulaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SVD Formula").font(.headline)
            
            Text("A = UΣVᵀ")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.pink)
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.pink.opacity(0.12)))
        }
    }
    
    private var componentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Components").font(.headline)
            
            componentCard(
                title: "U (Left Singular Vectors)",
                description: "m×m orthogonal matrix",
                details: "Columns are orthonormal eigenvectors of AAᵀ",
                color: .pink,
                icon: "arrow.left"
            )
            
            componentCard(
                title: "Σ (Singular Values)",
                description: "m×n diagonal matrix",
                details: "Diagonal entries σᵢ ≥ 0 measure importance/scaling",
                color: .purple,
                icon: "slider.horizontal.3"
            )
            
            componentCard(
                title: "Vᵀ (Right Singular Vectors)",
                description: "n×n orthogonal matrix",
                details: "Rows are orthonormal eigenvectors of AᵀA",
                color: .blue,
                icon: "arrow.right"
            )
        }
    }
    
    private var applicationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Applications").font(.headline)
            
            applicationCard(
                title: "Data Compression",
                description: "Keep only largest singular values for approximation",
                icon: "arrow.down.circle"
            )
            
            applicationCard(
                title: "Image Processing",
                description: "Reduce image size while preserving important features",
                icon: "photo"
            )
            
            applicationCard(
                title: "Recommendation Systems",
                description: "Find patterns in user-item matrices (Netflix, Amazon)",
                icon: "star"
            )
            
            applicationCard(
                title: "Least Squares",
                description: "Solve overdetermined systems Ax ≈ b optimally",
                icon: "function"
            )
            
            applicationCard(
                title: "Principal Component Analysis",
                description: "Dimensionality reduction in data science",
                icon: "chart.bar"
            )
        }
    }
    
    private var interpretationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Geometric Interpretation").font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Text("1").font(.title2.bold()).foregroundStyle(.pink).frame(width: 40)
                    VStack(alignment: .leading) {
                        Text("Vᵀ rotates input space")
                            .font(.subheadline.weight(.semibold))
                        Text("Aligns with principal directions")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                
                HStack(spacing: 12) {
                    Text("2").font(.title2.bold()).foregroundStyle(.purple).frame(width: 40)
                    VStack(alignment: .leading) {
                        Text("Σ scales along axes")
                            .font(.subheadline.weight(.semibold))
                        Text("σᵢ values determine stretching")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                
                HStack(spacing: 12) {
                    Text("3").font(.title2.bold()).foregroundStyle(.blue).frame(width: 40)
                    VStack(alignment: .leading) {
                        Text("U rotates output space")
                            .font(.subheadline.weight(.semibold))
                        Text("Final orientation")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Key Properties")
                    .font(.subheadline.weight(.semibold))
                
                Label("Singular values σ₁ ≥ σ₂ ≥ ... ≥ σᵣ ≥ 0", systemImage: "arrow.down")
                    .font(.caption)
                
                Label("rank(A) = number of non-zero singular values", systemImage: "number")
                    .font(.caption)
                
                Label("||A||₂ = σ₁ (largest singular value)", systemImage: "arrow.up.right")
                    .font(.caption)
                
                Label("Pseudo-inverse: A⁺ = VΣ⁺Uᵀ", systemImage: "arrow.triangle.2.circlepath")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
        }
    }
    
    private func componentCard(title: String, description: String, details: String, color: Color, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 50, height: 50)
                .background(Circle().fill(color.opacity(0.12)))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(description).font(.caption).foregroundStyle(color)
                Text(details).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
    }
    
    private func applicationCard(title: String, description: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.pink)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.pink.opacity(0.12)))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(description).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
    }
}

#Preview {
    SVDView()
}
