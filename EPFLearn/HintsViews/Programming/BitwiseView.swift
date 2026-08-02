//
//  BitwiseView.swift
//  EPFLearn
//
//  One idea: see bitwise operators act bit by bit.
//  Tap bits to toggle them, switch the operator, read the Java line.
//

import SwiftUI

struct BitwiseView: View {

    enum Op: String, CaseIterable {
        case and = "&", or = "|", xor = "^", not = "~", shl = "<<", shr = ">>"

        var color: Color {
            switch self {
            case .and: return .cyan
            case .or:  return .green
            case .xor: return PB.num
            case .not: return .pink
            case .shl: return Color(red: 0.72, green: 0.52, blue: 1.0)
            case .shr: return .mint
            }
        }
        var needsB: Bool { self == .and || self == .or || self == .xor }

        func compute(_ a: Int, _ b: Int) -> Int {
            switch self {
            case .and: return a & b
            case .or:  return a | b
            case .xor: return a ^ b
            case .not: return ~a & 0xFF
            case .shl: return (a << 1) & 0xFF
            case .shr: return a >> 1
            }
        }

        func java(_ a: Int, _ b: Int, _ r: Int) -> [String] {
            switch self {
            case .and: return ["int r = a & b;", "// \(a) & \(b) = \(r)"]
            case .or:  return ["int r = a | b;", "// \(a) | \(b) = \(r)"]
            case .xor: return ["int r = a ^ b;", "// \(a) ^ \(b) = \(r)"]
            case .not: return ["int r = ~a & 0xFF;", "// = \(r)"]
            case .shl: return ["int r = a << 1;", "// \(a) << 1 = \(r)"]
            case .shr: return ["int r = a >> 1;", "// \(a) >> 1 = \(r)"]
            }
        }
    }

    @State private var a = 0b0000_1100
    @State private var b = 0b0000_0101
    @State private var op: Op = .and

    private var result: Int { op.compute(a, b) }

    private var opNote: String {
        switch op {
        case .and: return "and: a result bit is 1 only where both a and b have a 1"
        case .or:  return "or: a result bit is 1 where either a or b (or both) has a 1"
        case .xor: return "xor: a result bit is 1 where a and b differ"
        case .not: return "not: every bit of a is flipped, 0 becomes 1 and 1 becomes 0"
        case .shl: return "shift left: every bit moves one place left and a 0 fills in on the right, doubling the value"
        case .shr: return "shift right: every bit moves one place right and a 0 fills in on the left, halving the value"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PBHeader("Bitwise")

            Picker("", selection: $op) {
                ForEach(Op.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)

            PBAdaptive {
                stage
            } code: {
                PBCodePane(lines: op.java(a, b, result).map { PBCodePane.Line(code: $0) },
                           current: 0, accent: op.color)
                    .pbViewport()
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground))
    }

    private var stage: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                PBChip(label: "a", value: "\(a)", color: .cyan)
                if op.needsB { PBChip(label: "b", value: "\(b)", color: .green) }
                PBChip(label: "r", value: "\(result)", color: op.color, hot: true)
            }
            indexHeader
            bitRow(value: a, color: .cyan, label: "a", editable: true) { a ^= (1 << $0) }
            if op.needsB {
                bitRow(value: b, color: .green, label: "b", editable: true) { b ^= (1 << $0) }
            }
            Rectangle().fill(.primary.opacity(0.12)).frame(height: 1).padding(.vertical, 2)
            bitRow(value: result, color: op.color, label: "r")
            PBNote(text: opNote)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .pbViewport()
        .animation(.spring(duration: 0.22), value: a)
        .animation(.spring(duration: 0.22), value: b)
        .animation(.spring(duration: 0.22), value: op)
    }

    private var indexHeader: some View {
        HStack(spacing: 4) {
            Color.clear.frame(width: 18, height: 1)
            ForEach(Array((0..<8).reversed()), id: \.self) { k in
                Text("\(k)")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.3))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func bitRow(value: Int, color: Color, label: String,
                        editable: Bool = false, onToggle: ((Int) -> Void)? = nil) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(color).frame(width: 18, alignment: .leading)
            ForEach(Array((0..<8).reversed()), id: \.self) { k in
                let bit = (value >> k) & 1
                Text("\(bit)")
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundColor(bit == 1 ? .black : .primary.opacity(0.35))
                    .frame(maxWidth: .infinity).frame(height: 40)
                    .background(RoundedRectangle(cornerRadius: 8)
                        .fill(bit == 1 ? color : Color.primary.opacity(0.07)))
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(editable ? color.opacity(0.35) : .clear, lineWidth: 1))
                    .shadow(color: bit == 1 ? color.opacity(0.45) : .clear, radius: 5)
                    .contentShape(Rectangle())
                    .onTapGesture { if editable { onToggle?(k) } }
            }
        }
    }
}

#Preview { BitwiseView() }
