//
//  BitwiseView.swift
//  EPFLearn
//
//  Bits are editable: tap one and it flips. Everything else on screen —
//  decimal value, place-value decomposition, signed reading, result of the
//  operator, masks, idioms — recomputes from there, so the link between the
//  binary pattern and the number stops being a conversion exercise.
//
//  Three tabs:
//    • OPERATORS — column by column, with the column you tap explained in
//      words ("bit 4: 1 & 0 = 0"). Shifts show what falls off the edge.
//    • MASKS — the four things you actually do in real code: set, clear,
//      toggle and test bit k, each with the mask `1 << k` drawn above.
//    • IDIOMS — the tricks that appear in exams and in real bit-twiddling:
//      parity, powers of two, isolating and clearing the lowest set bit,
//      XOR as its own inverse, shifts as ×2 and ÷2 (with the negative-number
//      trap spelled out).
//

import SwiftUI

// MARK: - Operators

private enum BitOp: String, CaseIterable, Identifiable {
    case and = "&", or = "|", xor = "^", not = "~", shl = "<<", shr = ">>"
    var id: String { rawValue }

    var binary: Bool { self == .and || self == .or || self == .xor }

    var name: String {
        switch self {
        case .and: return "AND"
        case .or:  return "OR"
        case .xor: return "XOR"
        case .not: return "NOT"
        case .shl: return "left shift"
        case .shr: return "right shift"
        }
    }

    var color: Color {
        switch self {
        case .and: return .blue
        case .or:  return .green
        case .xor: return .orange
        case .not: return .red
        case .shl: return .purple
        case .shr: return .indigo
        }
    }

    func apply(_ a: Int, _ b: Int) -> Int {
        switch self {
        case .and: return a & b
        case .or:  return a | b
        case .xor: return a ^ b
        case .not: return (~a) & 0xFF
        case .shl: return (a << 1) & 0xFF
        case .shr: return a >> 1
        }
    }

    var rule: String {
        switch self {
        case .and: return "1 only when BOTH bits are 1 → keeps what the mask selects, zeroes the rest. This is how you read a field."
        case .or:  return "1 as soon as ONE bit is 1 → forces bits to 1 without touching the others. This is how you switch a flag on."
        case .xor: return "1 when the bits DIFFER → flips exactly the bits set in the mask, and applying it twice restores the original."
        case .not: return "flips every bit. On 8 bits, ~x = 255 − x; in a real Java `int` it acts on 32 bits, so ~5 prints −6, not 250."
        case .shl: return "every bit moves one place to the left, a 0 enters on the right: this multiplies by 2 — until the top bit falls off the edge and the value silently wraps."
        case .shr: return "every bit moves one place right and the last one is lost: this is an integer division by 2, rounded down. For negative numbers, `>>` keeps the sign bit while `>>>` does not."
        }
    }
}

// MARK: - View

struct BitwiseView: View {

    private enum Tab: String, CaseIterable, Identifiable {
        case ops = "operators", masks = "masks", idioms = "idioms"
        var id: String { rawValue }
    }

    @State private var tab: Tab = .ops
    @State private var a: Int = 0b1100_1010
    @State private var b: Int = 0b0101_1100
    @State private var op: BitOp = .and
    @State private var selectedBit: Int? = nil     // 0 = LSB
    @State private var maskBit: Double = 3
    @State private var signed = false

    private var accent: Color { op.color }
    private var result: Int { op.apply(a, b) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                VizTitle(title: "Bitwise operations",
                         subtitle: "Tap any bit to flip it — everything below follows.",
                         accent: accent)

                Picker("Tab", selection: $tab) {
                    ForEach(Tab.allCases) { t in Text(t.rawValue).tag(t) }
                }
                .pickerStyle(.segmented)

                switch tab {
                case .ops:    opsTab
                case .masks:  masksTab
                case .idioms: idiomsTab
                }
            }
            .padding(18)
        }
        .background(Color(.systemGroupedBackground))
        .animation(.easeInOut(duration: 0.18), value: a)
        .animation(.easeInOut(duration: 0.18), value: b)
        .animation(.easeInOut(duration: 0.18), value: op)
    }

    // MARK: - Tab 1: operators

    private var opsTab: some View {
        VStack(alignment: .leading, spacing: 16) {

            Picker("op", selection: $op) {
                ForEach(BitOp.allCases) { o in Text(o.rawValue).tag(o) }
            }
            .pickerStyle(.segmented)

            VizPanel(title: "\(op.name)  ·  \(op == .not ? "~a" : (op.binary ? "a \(op.rawValue) b" : "a \(op.rawValue) 1"))",
                     accent: accent) {
                VStack(spacing: 8) {
                    weightsRow
                    bitRow(label: "a", value: a, color: .blue) { k in a = a ^ (1 << k) }
                    if op.binary {
                        bitRow(label: op.rawValue, value: b, color: .green) { k in b = b ^ (1 << k) }
                    }
                    Divider()
                    bitRow(label: "=", value: result, color: accent, editable: false)
                }
            }

            columnExplanation

            HStack(spacing: 12) {
                VarChip(name: "a", value: "\(a)", type: "0x" + String(a, radix: 16, uppercase: true), color: .blue)
                if op.binary {
                    VarChip(name: "b", value: "\(b)", type: "0x" + String(b, radix: 16, uppercase: true), color: .green)
                }
                VarChip(name: "result", value: "\(result)", type: "0x" + String(result, radix: 16, uppercase: true),
                        color: accent, highlighted: true)
            }

            decompositionPanel
            signedPanel

            VizPanel(title: "rule", accent: accent) {
                Text(op.rule)
                    .font(.system(size: 13))
                    .fixedSize(horizontal: false, vertical: true)
            }

            if op == .shl && a >= 128 {
                StepNote(text: "The top bit of a is 1, so shifting left pushes it out of the 8-bit register: \(a) << 1 would be \(a * 2), but only \(result) fits. This is exactly how integer overflow happens in a fixed-width type.",
                         accent: .red, icon: "exclamationmark.triangle.fill")
            }
        }
    }

    private var weightsRow: some View {
        HStack(spacing: 4) {
            Text(" ").frame(width: 22)
            ForEach(0..<8, id: \.self) { k in
                let bit = 7 - k
                Text("\(1 << bit)")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func bitRow(label: String, value: Int, color: Color,
                        editable: Bool = true, onTap: ((Int) -> Void)? = nil) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
                .frame(width: 22, alignment: .leading)

            ForEach(0..<8, id: \.self) { k in
                let bit = 7 - k
                let on = (value >> bit) & 1 == 1
                let selected = selectedBit == bit
                Button {
                    selectedBit = bit
                    if editable { onTap?(bit) }
                } label: {
                    Text(on ? "1" : "0")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundStyle(on ? .white : color.opacity(0.55))
                        .frame(maxWidth: .infinity, minHeight: 34)
                        .background(RoundedRectangle(cornerRadius: 6)
                            .fill(on ? color : color.opacity(0.10)))
                        .overlay(RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.primary.opacity(selected ? 0.55 : 0), lineWidth: 1.5))
                }
                .buttonStyle(.plain)
                .disabled(!editable && onTap == nil && false)
            }
        }
    }

    private var columnExplanation: some View {
        let k = selectedBit ?? 0
        let ab = (a >> k) & 1
        let bb = (b >> k) & 1
        let rb = (result >> k) & 1
        let text: String = {
            switch op {
            case .and, .or, .xor:
                return "bit \(k) (weight \(1 << k)):  \(ab) \(op.rawValue) \(bb) = \(rb)"
            case .not:
                return "bit \(k) (weight \(1 << k)):  ~\(ab) = \(rb)"
            case .shl:
                return "bit \(k) of the result comes from bit \(k - 1) of a" + (k == 0 ? " — nothing to take, a 0 enters here" : ": \(k - 1 >= 0 ? "\((a >> (k-1)) & 1)" : "0")")
            case .shr:
                return "bit \(k) of the result comes from bit \(k + 1) of a" + (k == 7 ? " — nothing above, a 0 enters here" : ": \((a >> (k+1)) & 1)")
            }
        }()
        return StepNote(text: text + ". Tap any column to inspect it; tap a bit of a or b to flip it.",
                        accent: accent, icon: "hand.tap.fill")
    }

    private var decompositionPanel: some View {
        let parts = (0..<8).reversed().compactMap { k -> String? in
            ((result >> k) & 1) == 1 ? "\(1 << k)" : nil
        }
        return VizPanel(title: "why this pattern is \(result)", accent: accent) {
            Text(parts.isEmpty ? "no bit set → 0"
                 : parts.joined(separator: " + ") + " = \(result)")
                .font(.system(size: 14, design: .monospaced))
                .foregroundStyle(accent)
        }
    }

    private var signedPanel: some View {
        let unsigned = result
        let asSigned = result >= 128 ? result - 256 : result
        return VizPanel(title: "how to read the same 8 bits", accent: .secondary) {
            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: $signed) {
                    Text("interpret as signed (two's complement)")
                        .font(.system(size: 13, weight: .medium))
                }
                .tint(accent)

                HStack(spacing: 12) {
                    VarChip(name: "unsigned", value: "\(unsigned)", color: .secondary, highlighted: !signed)
                    VarChip(name: "signed", value: "\(asSigned)", color: .secondary, highlighted: signed)
                }

                Text(result >= 128
                     ? "The top bit is 1, so in two's complement this pattern means \(unsigned) − 256 = \(asSigned). Nothing changed in memory — only the reading. Java's `byte` reads it as \(asSigned); `int` would need the pattern extended over 32 bits."
                     : "The top bit is 0, so both readings agree: \(unsigned). The sign bit is the one carrying weight \(128) — that is all «negative» means here.")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Tab 2: masks

    private var masksTab: some View {
        let k = Int(maskBit)
        let mask = 1 << k
        return VStack(alignment: .leading, spacing: 16) {

            VizPanel(title: "target bit", accent: .purple) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("k = \(k)   →   mask = 1 << \(k) = \(mask)")
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.purple)
                    Slider(value: $maskBit, in: 0...7, step: 1).tint(.purple)
                }
            }

            VizPanel(title: "x and the mask", accent: .purple) {
                VStack(spacing: 8) {
                    weightsRow
                    bitRow(label: "x", value: a, color: .blue) { i in a = a ^ (1 << i) }
                    bitRow(label: "m", value: mask, color: .purple, editable: false)
                }
            }

            maskCard(title: "test bit k", code: "(x >> k) & 1", value: (a >> k) & 1,
                     color: .teal,
                     text: "Shifts the wanted bit down to position 0 and cuts everything else. Result is 0 or 1 — never «true» directly, so compare it: `((x >> k) & 1) == 1`.")

            maskCard(title: "set bit k", code: "x | (1 << k)", value: a | mask,
                     color: .green,
                     text: "OR forces that single bit to 1 and provably leaves the other seven untouched, since `y | 0 = y`.")

            maskCard(title: "clear bit k", code: "x & ~(1 << k)", value: a & ~mask & 0xFF,
                     color: .red,
                     text: "The complement of the mask is 1 everywhere except at k, so AND keeps everything and zeroes only that bit.")

            maskCard(title: "toggle bit k", code: "x ^ (1 << k)", value: a ^ mask,
                     color: .orange,
                     text: "XOR flips exactly the bits set in the mask. Apply it twice and you are back where you started — that is the whole idea behind XOR ciphers.")

            VizPanel(title: "why it matters", accent: .purple) {
                Text("This is how flags are packed: one boolean per bit means 8 options in a single byte instead of 8 booleans. Permissions (rwx = 4|2|1), pixel channels, chess bitboards and network headers are all read exactly like this.")
                    .font(.system(size: 13))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func maskCard(title: String, code: String, value: Int, color: Color, text: String) -> some View {
        VizPanel(title: title, accent: color) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(code)
                        .font(.system(size: 13, design: .monospaced))
                    Spacer()
                    Text("\(value)")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(color)
                        .contentTransition(.numericText())
                }
                bitRow(label: "→", value: value, color: color, editable: false)
                Text(text)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Tab 3: idioms

    private var idiomsTab: some View {
        VStack(alignment: .leading, spacing: 16) {

            VizPanel(title: "x", accent: .blue) {
                VStack(spacing: 8) {
                    weightsRow
                    bitRow(label: "x", value: a, color: .blue) { k in a = a ^ (1 << k) }
                    HStack {
                        Text("x = \(a)")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundStyle(.blue)
                        Spacer()
                        Text("popcount = \(Self.popcount(a))")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            idiomCard(code: "x & 1", value: "\(a & 1)", color: .green,
                      text: a % 2 == 0 ? "0 → x is even. The last bit alone decides parity, which is why `x & 1` is the fastest parity test there is."
                                       : "1 → x is odd.")

            idiomCard(code: "x >> 1", value: "\(a >> 1)", color: .indigo,
                      text: "Integer division by 2, rounded DOWN. Careful: for negative numbers this rounds towards −∞ while `/ 2` rounds towards zero — −7 >> 1 is −4, but −7 / 2 is −3.")

            idiomCard(code: "x << 1", value: "\((a << 1) & 0xFF)", color: .purple,
                      text: a >= 128 ? "Multiplication by 2 — but the top bit fell off the 8-bit register, so the true value \(a * 2) wrapped to \((a << 1) & 0xFF)."
                                     : "Multiplication by 2, as long as nothing falls off the top of the register.")

            idiomCard(code: "x & (x - 1)", value: "\(a & max(a - 1, 0))", color: .orange,
                      text: a == 0 ? "x is 0, nothing to clear."
                                   : "Clears the LOWEST set bit (\(Self.lowestBit(a))) and leaves everything else alone. Repeating it until x is 0 counts the 1s in popcount(x) turns instead of 8 — this is Kernighan's trick.")

            idiomCard(code: "x & (x - 1) == 0", value: (a & max(a - 1, 0)) == 0 && a != 0 ? "true" : "false", color: .teal,
                      text: "Power-of-two test: a power of two has a single 1, so removing it leaves nothing. (0 has to be excluded by hand.)")

            idiomCard(code: "x & -x", value: "\(a & (-a & 0xFF))", color: .pink,
                      text: a == 0 ? "x is 0, no lowest set bit." : "Isolates the lowest set bit (\(Self.lowestBit(a))) and drops all the others. Used everywhere in Fenwick trees and bitboards to walk over set bits one at a time.")

            idiomCard(code: "x ^ y ^ y", value: "\(a ^ b ^ b)", color: .red,
                      text: "XOR is its own inverse, so applying the same key twice returns the original — the basis of the one-time pad, and of the classic «find the element appearing once» exercise.")

            VizPanel(title: "warning", accent: .red) {
                Text("`&` and `|` also exist as boolean operators, and there they do NOT short-circuit: `i < n & a[i] > 0` evaluates both sides and crashes. Bit operators on booleans are almost always a typo for `&&` and `||`.")
                    .font(.system(size: 13))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func idiomCard(code: String, value: String, color: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text(code)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundStyle(color)
                Text(text)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 6)
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .contentTransition(.numericText())
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(color.opacity(0.10)))
    }

    // MARK: - Helpers

    private static func popcount(_ x: Int) -> Int {
        var v = x, c = 0
        while v != 0 { v &= v - 1; c += 1 }
        return c
    }

    private static func lowestBit(_ x: Int) -> Int {
        x & (-x & 0xFF)
    }
}

#Preview {
    BitwiseView()
}
