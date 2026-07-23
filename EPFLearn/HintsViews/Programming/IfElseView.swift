//
//  IfElseView.swift
//  EPFLearn
//
//  Created on 22.07.2026.
//

import SwiftUI

struct IfElseView: View {
    @State private var isRunning = false
    @State private var currentLine = 0
    @State private var temperature: Double = 20
    @State private var message = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("If / Else").font(.largeTitle.bold())
                
                temperatureSlider
                controlsSection
                codeVisualization
                resultSection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var temperatureSlider: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Temperature: \(Int(temperature))°C")
                .font(.headline)
            
            Slider(value: $temperature, in: -10...40, step: 1)
                .disabled(isRunning)
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
                "int temp = \(Int(temperature));",
                "if (temp < 0) {",
                "    message = \"Freezing!\";",
                "} else if (temp < 15) {",
                "    message = \"Cold\";",
                "} else if (temp < 25) {",
                "    message = \"Nice!\";",
                "} else {",
                "    message = \"Hot!\";",
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
                            .fill(currentLine == index ? Color.orange : Color.clear)
                    )
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
        }
    }
    
    private var resultSection: some View {
        HStack {
            Image(systemName: iconForMessage)
                    .font(.system(size: 40))
                    .foregroundStyle(colorForMessage)
                    .contentTransition(.symbolEffect(.replace))
                
                Spacer()
                
                Text(message.isEmpty ? "—" : message)
                    .font(.system(.title, design: .rounded).bold())
                    .foregroundStyle(colorForMessage)
                    .contentTransition(.opacity)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(colorForMessage.opacity(0.1)))
    }
    
    private var iconForMessage: String {
        switch message {
        case "Freezing!": return "snowflake"
        case "Cold": return "wind"
        case "Nice!": return "sun.max.fill"
        case "Hot!": return "flame.fill"
        default: return "thermometer.medium"
        }
    }
    
    private var colorForMessage: Color {
        switch message {
        case "Freezing!": return .blue
        case "Cold": return .cyan
        case "Nice!": return .green
        case "Hot!": return .red
        default: return .gray
        }
    }
    
    private func startExecution() {
        isRunning = true
        message = ""
        currentLine = 0
        executeNextLine()
    }
    
    private func executeNextLine() {
        guard isRunning else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                let temp = Int(temperature)
                
                switch currentLine {
                case 0:
                    currentLine = 1
                case 1:
                    if temp < 0 {
                        currentLine = 2
                    } else {
                        currentLine = 3
                    }
                case 2:
                    message = "Freezing!"
                    currentLine = 9
                case 3:
                    if temp < 15 {
                        currentLine = 4
                    } else {
                        currentLine = 5
                    }
                case 4:
                    message = "Cold"
                    currentLine = 9
                case 5:
                    if temp < 25 {
                        currentLine = 6
                    } else {
                        currentLine = 7
                    }
                case 6:
                    message = "Nice!"
                    currentLine = 9
                case 7:
                    currentLine = 8
                case 8:
                    message = "Hot!"
                    currentLine = 9
                case 9:
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
        message = ""
    }
}

#Preview {
    IfElseView()
}
