//
//  ForLoopView.swift
//  EPFLearn
//
//  Created on 22.07.2026.
//

import SwiftUI

struct ForLoopView: View {
    @State private var isRunning = false
    @State private var currentLine = 0
    @State private var i = 0
    @State private var sum = 0
    @State private var maxValue: Double = 5
    
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
    
    private func startExecution() {
        isRunning = true
        sum = 0
        i = 0
        currentLine = 0
        executeNextLine()
    }
    
    private func executeNextLine() {
        guard isRunning else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                if currentLine == 0 {
                    sum = 0
                    currentLine = 1
                } else if currentLine == 1 {
                    if i < Int(maxValue) {
                        currentLine = 2
                    } else {
                        currentLine = 4
                        stopExecution()
                        return
                    }
                } else if currentLine == 2 {
                    sum += i
                    currentLine = 3
                } else if currentLine == 3 {
                    i += 1
                    currentLine = 1
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
        i = 0
        sum = 0
    }
}

#Preview {
    ForLoopView()
}
