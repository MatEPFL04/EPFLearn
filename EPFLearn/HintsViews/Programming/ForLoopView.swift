//
//  ForLoopView.swift
//  EPFLearn
//
//  Created on 22.07.2026.
//

import SwiftUI

struct ForLoopView: View {
    @State private var currentStep = 0
    @State private var currentLine = 0
    @State private var i = 0
    @State private var sum = 0
    @State private var maxValue: Double = 5
    
    private var totalSteps: Int {
        Int(maxValue) * 2 + 2  // init + (check + add) * n + end
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("For Loop").font(.largeTitle.bold())
                
                controlsSection
                codeVisualization
                variablesSection
                arrayVisualization
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var controlsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Step \(currentStep) / \(totalSteps)")
                    .font(.headline)
                Spacer()
                Button {
                    currentStep = 0
                    updateState()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered)
                .tint(.blue)
            }
            
            Slider(value: Binding(
                get: { Double(currentStep) },
                set: { currentStep = Int($0) }
            ), in: 0...Double(totalSteps), step: 1)
            .onChange(of: currentStep) { _ in
                updateState()
            }
            
            HStack {
                Text("Start")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("End")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
    }
    
    private var codeVisualization: some View {
        VStack(alignment: .leading, spacing: 0) {
            let codeLines = [
                "int sum = 0;",
                "for (int i = 0; i < \(Int(maxValue)); i++) {",
                "    sum += i;",
                "    System.out.println(\"sum = \" + sum);",
                "}"
            ]
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(codeLines.enumerated()), id: \.offset) { index, line in
                    HStack(spacing: 12) {
                        Text("\(index + 1)")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                        
                        Text(line)
                            .font(.system(.callout, design: .monospaced))
                            .foregroundStyle(currentLine == index ? .white : .primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(currentLine == index ? Color.green : Color.clear)
                    )
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
        }
    }
    
    private var variablesSection: some View {
        HStack(spacing: 12) {
            VStack(spacing: 8) {
                Text("i")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(i)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(.blue)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.1)))
            
            VStack(spacing: 8) {
                Text("sum")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(sum)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(.green)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.green.opacity(0.1)))
        }
    }
    
    private var arrayVisualization: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                ForEach(0..<Int(maxValue), id: \.self) { index in
                    VStack(spacing: 4) {
                        Text("\(index)")
                            .font(.caption.monospaced().bold())
                            .foregroundStyle(index <= i ? .white : .secondary)
                        
                        Circle()
                            .fill(index == i ? Color.blue : (index < i ? Color.green : Color.gray.opacity(0.3)))
                            .frame(width: 32, height: 32)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
        }
    }
    
    
    private func updateState() {
        withAnimation(.spring(duration: 0.2)) {
            let max = Int(maxValue)
            
            if currentStep == 0 {
                // Init
                currentLine = 0
                sum = 0
                i = 0
            } else if currentStep <= max * 2 {
                // Loop iterations
                let iteration = (currentStep - 1) / 2
                let inIterationStep = (currentStep - 1) % 2
                
                i = iteration
                
                if inIterationStep == 0 {
                    // Check condition
                    currentLine = 1
                } else {
                    // Add to sum
                    currentLine = 2
                    sum = (0...iteration).reduce(0, +)
                }
            } else {
                // End
                currentLine = 4
                i = max
                sum = (0..<max).reduce(0, +)
            }
        }
    }
}

#Preview {
    ForLoopView()
}
