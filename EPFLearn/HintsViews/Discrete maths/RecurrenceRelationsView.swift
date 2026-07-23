//
//  RecurrenceRelationsView.swift
//  EPFLearn
//
//  Created on 20.07.2026.
//

import SwiftUI

/// Interactive view for exploring recurrence relations
struct RecurrenceRelationsView: View {
    @State private var selectedRelation = RecurrenceType.geometric
    @State private var steps: Double = 10
    
    private var stepCount: Int { max(1, min(20, Int(steps.rounded()))) }
    
    enum RecurrenceType: String, CaseIterable, Identifiable {
        case geometric = "Geometric"
        case arithmetic = "Arithmetic"
        case towerOfHanoi = "Tower of Hanoi"
        
        var id: Self { self }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                pickerSection
                formulaSection
                controlSection
                sequenceVisualization
                chartSection
                explanationSection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recurrence Relations").font(.largeTitle.bold())
            Text("A recurrence relation defines a sequence where each term is expressed using previous terms.")
                .font(.callout).foregroundStyle(.secondary)
        }
    }
    
    private var pickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select a relation").font(.subheadline.weight(.medium))
            Picker("Relation", selection: $selectedRelation) {
                ForEach(RecurrenceType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var formulaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Formula").font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(formula)
                    .font(.system(.title3, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12).fill(relationColor.opacity(0.12)))
                
                Text(description)
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }
    
    private var controlSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Number of terms", systemImage: "number")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(relationColor)
            Picker("Terms", selection: $steps) {
                ForEach(1...20, id: \.self) { value in
                    Text("\(value)").tag(Double(value))
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var sequenceVisualization: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sequence values").font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                ForEach(0..<stepCount, id: \.self) { n in
                    VStack(spacing: 4) {
                        Text("a\(subscriptString(n))")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                        Text("\(calculateValue(at: n))")
                            .font(.headline.monospacedDigit())
                            .foregroundStyle(relationColor)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(relationColor.opacity(0.08))
                    )
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
        }
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Growth visualization").font(.headline)
            
            Canvas { ctx, size in
                drawChart(ctx, size: size)
            }
            .frame(height: 220)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground)))
        }
    }
    
    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Applications").font(.headline)
            
            switch selectedRelation {
            case .geometric:
                applicationCard(
                    title: "Population Growth",
                    description: "Bacterial populations often grow geometrically: each generation doubles.",
                    icon: "chart.line.uptrend.xyaxis"
                )
                applicationCard(
                    title: "Compound Interest",
                    description: "Money grows geometrically with compound interest.",
                    icon: "dollarsign.circle"
                )
            case .arithmetic:
                applicationCard(
                    title: "Savings Plans",
                    description: "Adding a fixed amount monthly creates an arithmetic sequence.",
                    icon: "banknote"
                )
                applicationCard(
                    title: "Scheduling",
                    description: "Equally spaced events form an arithmetic sequence.",
                    icon: "calendar"
                )
            case .towerOfHanoi:
                applicationCard(
                    title: "Algorithm Analysis",
                    description: "Recursive algorithms often have recurrence relations similar to Tower of Hanoi.",
                    icon: "cpu"
                )
                applicationCard(
                    title: "Puzzle Solving",
                    description: "The Tower of Hanoi is a classic mathematical puzzle with 2ⁿ - 1 moves.",
                    icon: "puzzlepiece"
                )
            }
        }
    }
    
    private func applicationCard(title: String, description: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(relationColor)
                .frame(width: 44, height: 44)
                .background(Circle().fill(relationColor.opacity(0.12)))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(description).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
    }
    
    // MARK: - Helper Properties & Functions
    
    private var formula: String {
        switch selectedRelation {
        case .geometric:
            return "a(n) = 2 × a(n-1)\na(0) = 1"
        case .arithmetic:
            return "a(n) = a(n-1) + 3\na(0) = 1"
        case .towerOfHanoi:
            return "T(n) = 2T(n-1) + 1\nT(1) = 1"
        }
    }
    
    private var description: String {
        switch selectedRelation {
        case .geometric:
            return "Each term is double the previous term (ratio = 2)."
        case .arithmetic:
            return "Each term adds 3 to the previous term (difference = 3)."
        case .towerOfHanoi:
            return "Minimum moves to solve the Tower of Hanoi puzzle with n disks."
        }
    }
    
    private var relationColor: Color {
        switch selectedRelation {
        case .geometric: return .orange
        case .arithmetic: return .blue
        case .towerOfHanoi: return .green
        }
    }
    
    private func calculateValue(at n: Int) -> Int {
        switch selectedRelation {
        case .geometric:
            return geometric(n)
        case .arithmetic:
            return arithmetic(n)
        case .towerOfHanoi:
            return hanoi(n)
        }
    }
    
    private func geometric(_ n: Int) -> Int {
        return Int(pow(2.0, Double(n)))
    }
    
    private func arithmetic(_ n: Int) -> Int {
        return 1 + 3 * n
    }
    
    private func hanoi(_ n: Int) -> Int {
        return Int(pow(2.0, Double(n + 1))) - 1
    }
    
    private func subscriptString(_ n: Int) -> String {
        let subscripts = ["₀", "₁", "₂", "₃", "₄", "₅", "₆", "₇", "₈", "₉"]
        return String(n).map { subscripts[Int(String($0))!] }.joined()
    }
    
    private func drawChart(_ ctx: GraphicsContext, size: CGSize) {
        let padding: CGFloat = 40
        let plotWidth = size.width - 2 * padding
        let plotHeight = size.height - 2 * padding
        
        guard stepCount > 0 else { return }
        
        let values = (0..<stepCount).map { Double(calculateValue(at: $0)) }
        let maxValue = values.max() ?? 1
        
        // Axes
        var axes = Path()
        axes.move(to: CGPoint(x: padding, y: padding))
        axes.addLine(to: CGPoint(x: padding, y: size.height - padding))
        axes.addLine(to: CGPoint(x: size.width - padding, y: size.height - padding))
        ctx.stroke(axes, with: .color(.secondary.opacity(0.3)), lineWidth: 1.5)
        
        // Points and lines
        var linePath = Path()
        for i in 0..<values.count {
            let x = padding + plotWidth * CGFloat(i) / CGFloat(max(stepCount - 1, 1))
            let y = size.height - padding - plotHeight * CGFloat(values[i] / maxValue)
            
            if i == 0 {
                linePath.move(to: CGPoint(x: x, y: y))
            } else {
                linePath.addLine(to: CGPoint(x: x, y: y))
            }
            
            // Draw point
            ctx.fill(
                Path(ellipseIn: CGRect(x: x - 4, y: y - 4, width: 8, height: 8)),
                with: .color(relationColor)
            )
        }
        
        ctx.stroke(linePath, with: .color(relationColor), style: StrokeStyle(lineWidth: 2))
        
        // Labels
        ctx.draw(
            Text("n").font(.caption).foregroundStyle(.secondary),
            at: CGPoint(x: size.width - padding + 12, y: size.height - padding)
        )
        ctx.draw(
            Text("value").font(.caption).foregroundStyle(.secondary),
            at: CGPoint(x: padding, y: padding - 12)
        )
    }
}

#Preview {
    RecurrenceRelationsView()
}
