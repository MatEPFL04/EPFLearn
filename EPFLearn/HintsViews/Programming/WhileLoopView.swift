//
//  WhileLoopView.swift
//  EPFLearn
//
//  Created on 22.07.2026.
//

import SwiftUI

struct WhileLoopView: View {
    @State private var isRunning = false
    @State private var currentLine = 0
    @State private var counter = 0
    @State private var maxIterations: Double = 5
    
    private var codeLines: [String] {
        [
            "int counter = 0;",
            "int max = \(Int(maxIterations));",
            "while (counter < max) {",
            "    counter++;",
            "    System.out.println(counter);",
            "}"
        ]
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("While Loop").font(.largeTitle.bold())
                
                controlsSection
                codeVisualization
                variablesSection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var controlsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button {
                    if isRunning {
                        stopExecution()
                    } else {
                        startExecution()
                    }
                } label: {
                    Label(isRunning ? "Stop" : "Run", systemImage: isRunning ? "stop.fill" : "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(isRunning ? .red : .green)
                .controlSize(.large)
                
                Button {
                    resetExecution()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                .controlSize(.large)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Max iterations: \(Int(maxIterations))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Slider(value: $maxIterations, in: 3...10, step: 1)
                    .disabled(isRunning)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
        }
    }
    
    private var codeVisualization: some View {
        VStack(alignment: .leading, spacing: 0) {
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
                            .fill(currentLine == index ? Color.blue : Color.clear)
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
                Text("counter")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(counter)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(.blue)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.1)))
            
            VStack(spacing: 8) {
                Text("max")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(Int(maxIterations))")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(.purple)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.purple.opacity(0.1)))
        }
    }
    
    private func startExecution() {
        isRunning = true
        counter = 0
        currentLine = 0
        executeNextLine()
    }
    
    private func executeNextLine() {
        guard isRunning else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                if currentLine == 0 {
                    counter = 0
                    currentLine = 1
                } else if currentLine == 1 {
                    currentLine = 2
                } else if currentLine == 2 {
                    if counter < Int(maxIterations) {
                        currentLine = 3
                    } else {
                        currentLine = 5
                        stopExecution()
                        return
                    }
                } else if currentLine == 3 {
                    counter += 1
                    currentLine = 4
                } else if currentLine == 4 {
                    currentLine = 2
                } else if currentLine == 5 {
                    stopExecution()
                    return
                }
            }
            executeNextLine()
        }
    }
    
    private func stopExecution() {
        isRunning = false
    }
    
    private func resetExecution() {
        isRunning = false
        currentLine = 0
        counter = 0
    }
}

#Preview {
    WhileLoopView()
}
