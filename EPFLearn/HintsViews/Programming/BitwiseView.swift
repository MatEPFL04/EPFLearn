//
//  BitwiseView.swift
//  EPFLearn
//
//  Created on 22.07.2026.
//

import SwiftUI

enum BitwiseOperation: String, CaseIterable {
    case and = "AND (&)"
    case or = "OR (|)"
    case xor = "XOR (^)"
    case not = "NOT (~)"
    case leftShift = "<< 1"
    case rightShift = ">> 1"
    
    var symbol: String {
        switch self {
        case .and: return "&"
        case .or: return "|"
        case .xor: return "^"
        case .not: return "~"
        case .leftShift: return "<<"
        case .rightShift: return ">>"
        }
    }
    
    func compute(a: Int, b: Int) -> Int {
        switch self {
        case .and: return a & b
        case .or: return a | b
        case .xor: return a ^ b
        case .not: return ~a
        case .leftShift: return a << 1
        case .rightShift: return a >> 1
        }
    }
    
    var color: Color {
        switch self {
        case .and: return .blue
        case .or: return .green
        case .xor: return .orange
        case .not: return .red
        case .leftShift: return .purple
        case .rightShift: return .indigo
        }
    }
    
    var needsB: Bool {
        switch self {
        case .and, .or, .xor: return true
        case .not, .leftShift, .rightShift: return false
        }
    }
}

struct BitwiseView: View {
    @State private var valueA: Double = 12
    @State private var valueB: Double = 5
    @State private var selectedOperation: BitwiseOperation = .and
    
    private var result: Int {
        selectedOperation.compute(a: Int(valueA), b: Int(valueB))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Bitwise Operations").font(.title.bold())
            
            // Input sliders
            VStack(spacing: 12) {
                inputRow(label: "a", value: $valueA, color: .blue)
                if selectedOperation.needsB {
                    inputRow(label: "b", value: $valueB, color: .green)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
            
            // Operation picker
            Picker("", selection: $selectedOperation) {
                ForEach(BitwiseOperation.allCases, id: \.self) { op in
                    Text(op.rawValue).tag(op)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 100)
            .padding(.horizontal)
            
            // Visual operation
            VStack(spacing: 8) {
                binaryOperationRow(value: Int(valueA), color: .blue, showLabel: true, label: "a")
                if selectedOperation.needsB {
                    HStack {
                        Text(selectedOperation.symbol)
                            .font(.title2.bold())
                            .foregroundStyle(selectedOperation.color)
                            .frame(width: 20)
                        Spacer()
                    }
                    binaryOperationRow(value: Int(valueB), color: .green, showLabel: true, label: "b")
                }
                
                Divider()
                
                binaryOperationRow(value: result, color: selectedOperation.color, showLabel: true, label: "=")
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(selectedOperation.color.opacity(0.1)))
            
            // Result decimal
            Text("\(result)")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(selectedOperation.color)
                .contentTransition(.numericText())
            
            Spacer()
        }
        .padding(16)
        .background(Color(.systemGroupedBackground))
    }
    
    private func inputRow(label: String, value: Binding<Double>, color: Color) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.headline)
                .foregroundStyle(color)
                .frame(width: 20)
            
            Text("\(Int(value.wrappedValue))")
                .font(.system(.body, design: .monospaced))
                .frame(width: 30, alignment: .trailing)
            
            Slider(value: value, in: 0...255, step: 1)
        }
    }
    
    private func binaryOperationRow(value: Int, color: Color, showLabel: Bool, label: String) -> some View {
        HStack(spacing: 4) {
            if showLabel {
                Text(label)
                    .font(.system(.body, design: .monospaced).bold())
                    .foregroundStyle(color)
                    .frame(width: 20)
            }
            
            let binaryString = String(value, radix: 2)
            let paddedBinary = String(repeating: "0", count: max(0, 8 - binaryString.count)) + binaryString
            
            ForEach(Array(paddedBinary.enumerated()), id: \.offset) { index, bit in
                Text(String(bit))
                    .font(.system(.body, design: .monospaced).bold())
                    .foregroundStyle(bit == "1" ? color : .secondary)
                    .frame(width: 28)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(bit == "1" ? color.opacity(0.2) : Color.gray.opacity(0.05))
                    )
            }
        }
    }
}

#Preview {
    BitwiseView()
}
