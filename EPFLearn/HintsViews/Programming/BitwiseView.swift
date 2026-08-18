//
//  BitwiseView.swift
//  EPFLearn
//
//  One idea: a bitwise operator acts on each column of bits on its own.
//  Eight bits are drawn - the 24 above them behave exactly the same way.
//  Tap a bit to flip it, pick an operator, and read the result row.
//
//  Deliberately kept small: one operator picker, one optional mask, one
//  offset. Everything else the student has to work out is in the question.
//

import SwiftUI

struct BitwiseView: View {

    /// Set in challenge mode so the run can grade what the student assembles.
    var onReading: ((ChallengeReading) -> Void)? = nil

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
        var isShift: Bool { self == .shl || self == .shr }

        /// Everything stays inside the drawn byte: bits pushed past bit 7 by
        /// `<<` leave the window, exactly as `& 0xFF` would keep them.
        func compute(_ a: Int, _ b: Int, _ k: Int) -> Int {
            switch self {
            case .and: return a & b
            case .or:  return a | b
            case .xor: return a ^ b
            case .not: return ~a & 0xFF
            case .shl: return (a << k) & 0xFF
            case .shr: return a >> k
            }
        }
    }

    @State private var a = 0b0000_1100
    @State private var freeB = 0b0000_0101
    @State private var op: Op = .and
    /// The second operand is either tapped in by hand or the single-bit mask
    /// `1 << k`, which is the one idiom every exam question is built on.
    @State private var useMask = false
    @State private var k = 2

    private var b: Int { useMask ? (1 << k) & 0xFF : freeB }
    private var result: Int { op.compute(a, b, k) }

    private var reading: BitwiseReading {
        BitwiseReading(a: a, b: b, result: result, op: op.rawValue, shift: k)
    }

    private let bits = Array((0..<8).reversed())

    /// Is the k slider doing anything right now?
    private var kMatters: Bool { op.isShift || (op.needsB && useMask) }

    private var javaLine: String {
        switch op {
        case .and, .or, .xor:
            return "int r = a \(op.rawValue) \(useMask ? "(1 << \(k))" : "b");"
        case .not:
            return "int r = ~a & 0xFF;"
        case .shl, .shr:
            return "int r = a \(op.rawValue) \(k);"
        }
    }

    private var opNote: String {
        switch op {
        case .and: return useMask ? "keeps bit k only: this is how a bit is tested"
                                  : "1 only where a and b both have a 1"
        case .or:  return useMask ? "forces bit k to 1, never back to 0"
                                  : "1 where a or b has a 1"
        case .xor: return useMask ? "flips bit k, leaves the others alone"
                                  : "1 where a and b differ"
        case .not: return "every bit flips"
        case .shl: return "bits move k places left: × 2ᵏ"
        case .shr: return "bits move k places right: ÷ 2ᵏ"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            PBHeader("Bitwise")

            HStack(spacing: 12) {
                Picker("", selection: $op) {
                    ForEach(Op.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu)
                .labelsHidden()

                Spacer(minLength: 0)

                if op.needsB {
                    Toggle(isOn: $useMask) {
                        Text("b = 1 << k")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                    }
                    .toggleStyle(.switch)
                    .fixedSize()
                }
            }

            if op.needsB {
                Text(useMask
                     ? "b is the mask 1 << k: a single 1 at position k, moved by the k slider."
                     : "b is yours to set: tap its bits below to turn them on and off.")
                    .font(.system(size: 10.5))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if kMatters {
                PBScrub(label: "k", value: $k, range: 0...7, accent: op.color)
            }

            PBAdaptive {
                stage
            } code: {
                PBCodePane(lines: [PBCodePane.Line(code: javaLine),
                                   PBCodePane.Line(code: "// r = \(result)")],
                           current: 0, accent: op.color)
                    .pbViewport()
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground))
        .onChange(of: reading, initial: true) { _, new in
            onReading?(.bitwise(new))
        }
    }

    private var stage: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                PBChip(label: "a", value: "\(a)", color: .cyan)
                if op.needsB {
                    PBChip(label: useMask ? "mask" : "b", value: "\(b)", color: .green)
                }
                PBChip(label: "r", value: "\(result)", color: op.color, hot: true)
            }

            indexHeader
            bitRow(value: a, color: .cyan, label: "a", editable: true) { a ^= (1 << $0) }
            if op.needsB {
                bitRow(value: b, color: .green, label: useMask ? "m" : "b",
                       editable: !useMask) { freeB ^= (1 << $0) }
            }
            Rectangle().fill(.primary.opacity(0.12)).frame(height: 1).padding(.vertical, 2)
            bitRow(value: result, color: op.color, label: "r")

            PBNote(text: opNote)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .pbViewport()
        .animation(.spring(duration: 0.22), value: a)
        .animation(.spring(duration: 0.22), value: freeB)
        .animation(.spring(duration: 0.22), value: op)
        .animation(.spring(duration: 0.22), value: useMask)
        .animation(.spring(duration: 0.22), value: k)
    }

    private var indexHeader: some View {
        HStack(spacing: 6) {
            Color.clear.frame(width: 18, height: 1)
            HStack(spacing: 4) {
                ForEach(bits, id: \.self) { i in
                    Text("\(i)")
                        .font(.system(size: 9,
                                      weight: kMatters && i == k ? .bold : .regular,
                                      design: .monospaced))
                        .foregroundColor(kMatters && i == k ? op.color : .primary.opacity(0.3))
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func bitRow(value: Int, color: Color, label: String,
                        editable: Bool = false, onToggle: ((Int) -> Void)? = nil) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .frame(width: 18, alignment: .leading)

            HStack(spacing: 4) {
                ForEach(bits, id: \.self) { i in
                    let bit = (value >> i) & 1
                    Text("\(bit)")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(bit == 1 ? .black : .primary.opacity(0.35))
                        .frame(maxWidth: .infinity).frame(height: 34)
                        .background(RoundedRectangle(cornerRadius: 8)
                            .fill(bit == 1 ? color : Color.primary.opacity(0.07)))
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(kMatters && i == k ? op.color.opacity(0.9)
                                                             : (editable ? color.opacity(0.35) : .clear),
                                          lineWidth: kMatters && i == k ? 1.6 : 1))
                        .shadow(color: bit == 1 ? color.opacity(0.45) : .clear, radius: 5)
                        .contentShape(Rectangle())
                        .onTapGesture { if editable { onToggle?(i) } }
                }
            }
        }
    }
}

#Preview { BitwiseView() }
