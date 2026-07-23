//
//  VariablesView.swift
//  EPFLearn
//
//  Created on 22.07.2026.
//

import SwiftUI

struct VariablesView: View {
    @State private var isRunning = false
    @State private var currentLine = 0
    @State private var intValue = 0
    @State private var stringValue = ""
    @State private var boolValue = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Variables").font(.largeTitle.bold())
                
                controlsSection
                codeVisualization
                variablesSection
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
                "int age = 25;",
                "String name = \"Java\";",
                "boolean isActive = true;",
                "System.out.println(age + name + isActive);"
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
                            .fill(currentLine == index ? Color.blue : Color.clear)
                    )
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
        }
    }
    
    private var variablesSection: some View {
        VStack(spacing: 12) {
            variableCard(name: "age", value: "\(intValue)", type: "int", color: .blue)
            variableCard(name: "name", value: "\"\(stringValue)\"", type: "String", color: .green)
            variableCard(name: "isActive", value: "\(boolValue)", type: "boolean", color: .orange)
        }
    }
    
    private func variableCard(name: String, value: String, type: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(name)
                    .font(.headline)
                Spacer()
                Text(type)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.2))
                    .foregroundStyle(color)
                    .clipShape(Capsule())
            }
            
            Text(value)
                .font(.system(.title2, design: .monospaced))
                .foregroundStyle(color)
                .contentTransition(.opacity)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(color.opacity(0.1)))
    }
    
    private func startExecution() {
        isRunning = true
        resetExecution()
        executeNextLine()
    }
    
    private func executeNextLine() {
        guard isRunning else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation {
                switch currentLine {
                case 0:
                    intValue = 25
                    currentLine = 1
                case 1:
                    stringValue = "Java"
                    currentLine = 2
                case 2:
                    boolValue = true
                    currentLine = 3
                case 3:
                    currentLine = 4
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
        intValue = 0
        stringValue = ""
        boolValue = false
    }
}

#Preview {
    VariablesView()
}
