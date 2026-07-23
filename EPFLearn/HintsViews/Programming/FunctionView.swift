//
//  FunctionView.swift
//  EPFLearn
//
//  Created on 22.07.2026.
//

import SwiftUI

struct FunctionView: View {
    @State private var isRunning = false
    @State private var currentLine = 0
    @State private var inputA: Double = 5
    @State private var inputB: Double = 3
    @State private var result = 0
    @State private var callStack: [String] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Functions").font(.largeTitle.bold())
                
                inputSection
                controlsSection
                codeVisualization
                callStackSection
                resultSection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var inputSection: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("a = \(Int(inputA))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Slider(value: $inputA, in: 0...10, step: 1)
                    .disabled(isRunning)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("b = \(Int(inputB))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Slider(value: $inputB, in: 0...10, step: 1)
                    .disabled(isRunning)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
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
                "public static int multiply(int a, int b) {",
                "    int result = a * b;",
                "    return result;",
                "}",
                "",
                "int answer = multiply(\(Int(inputA)), \(Int(inputB)));",
                "System.out.println(answer);"
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
                            .fill(currentLine == index ? Color.purple : Color.clear)
                    )
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
        }
    }
    
    private var callStackSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if callStack.isEmpty {
                Text("Empty")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(callStack.enumerated()), id: \.offset) { index, call in
                        HStack {
                            Image(systemName: "arrow.right")
                                .foregroundStyle(.purple)
                            Text(call)
                                .font(.system(.body, design: .monospaced))
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.purple.opacity(0.1)))
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
    }
    
    private var resultSection: some View {
        VStack(spacing: 8) {
            Text("result")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(result)")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(.purple)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.purple.opacity(0.1)))
    }
    
    private func startExecution() {
        isRunning = true
        result = 0
        callStack = []
        currentLine = 5
        executeNextLine()
    }
    
    private func executeNextLine() {
        guard isRunning else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                switch currentLine {
                case 5:
                    callStack.append("multiply(\(Int(inputA)), \(Int(inputB)))")
                    currentLine = 0
                case 0:
                    currentLine = 1
                case 1:
                    result = Int(inputA) * Int(inputB)
                    currentLine = 2
                case 2:
                    if !callStack.isEmpty {
                        callStack.removeLast()
                    }
                    currentLine = 6
                case 6:
                    stopExecution()
                    return
                default:
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
        result = 0
        callStack = []
    }
}

#Preview {
    FunctionView()
}
