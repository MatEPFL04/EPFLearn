//
//  CombinatoricsView.swift
//  EPFLearn
//
//  Created on 20.07.2026.
//

import SwiftUI

/// The three counting rules: ordered without repetition (P), unordered (C),
/// and ordered with repetition (nᵏ).
///
/// Every size in the sample list is derived from k against a conservative
/// content width, so no combination of n and k - including n = k = 8 - can
/// push a row past the panel it lives in.
struct CombinatoricsView: View {

    enum Mode: String, CaseIterable, Identifiable {
        case permutations = "Permutations"
        case combinations = "Combinations"
        case repetition   = "Repetition"
        var id: Self { self }

        var rule: String {
            switch self {
            case .permutations: return "Order matters, each item used once."
            case .combinations: return "Order does not matter."
            case .repetition:   return "Order matters, items may repeat."
            }
        }

        var tint: Color {
            switch self {
            case .permutations: return .blue
            case .combinations: return .green
            case .repetition:   return .orange
            }
        }
    }

    @State private var n: Int = 5
    @State private var k: Int = 2
    @State private var mode: Mode = .permutations
    @State private var generated: [[Int]] = []

    private let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .cyan]

    /// Narrower than any supported device, so the arithmetic below is safe.
    private let contentWidth: CGFloat = 270

    // MARK: - Counting

    private var result: Int {
        switch mode {
        case .permutations: return permutations(n, k)
        case .combinations: return combinations(n, k)
        case .repetition:   return power(n, k)
        }
    }

    private var symbol: String {
        switch mode {
        case .permutations: return "P(\(n),\(k))"
        case .combinations: return "C(\(n),\(k))"
        case .repetition:   return "\(n)^\(k)"
        }
    }

    private var breakdown: String {
        switch mode {
        case .permutations:
            return "\(factors(descending: true)) = \(result)"
        case .combinations:
            return "\(factors(descending: true)) / \(k)! = \(permutations(n, k))/\(factorial(k)) = \(result)"
        case .repetition:
            return "\(factors(descending: false)) = \(result)"
        }
    }

    private func factors(descending: Bool) -> String {
        (0..<k).map { descending ? "\(n - $0)" : "\(n)" }.joined(separator: "×")
    }

    private var note: String {
        switch mode {
        case .permutations: return "The pool shrinks slot by slot."
        case .combinations: return "Every choice appears \(k)! = \(factorial(k)) times in the ordered list, so divide by it."
        case .repetition:   return "Nothing leaves the pool: all \(k) slots have \(n) choices."
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            VizHeader("Counting", subtitle: "Does order matter, and may items repeat?")

            resultPanel

            itemsRow

            sampleList

            // Under the panels they drive, like every other picker in the app.
            Picker("Mode", selection: $mode) {
                ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .onChange(of: mode) {
                // With repetition k is free of n entirely: you can draw 8
                // times from a pool of 2. Only P and C need k <= n.
                if mode != .repetition { k = min(k, n) }
                regenerate()
            }

            HStack(spacing: 10) {
                counter("n", value: $n, range: 2...8)
                counter("k", value: $k, range: 1...(mode == .repetition ? 8 : n))
            }

            Spacer(minLength: 0)
        }
        .padding()
        .onAppear { regenerate() }
    }

    private func counter(_ title: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        VizSlider(label: title, intValue: value, range: range, accent: .blue) {
            if mode != .repetition, k > n { k = n }
            regenerate()
        }
    }

    private var resultPanel: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(symbol)
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundStyle(.secondary)
                Text("\(result)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(mode.tint)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Spacer(minLength: 0)
                if mode != .repetition {
                    Text("P \(permutations(n, k))  ·  C \(combinations(n, k))")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
            }

            Text(breakdown)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(mode.tint)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Text(mode.rule + " " + note)
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.gray.opacity(0.2)))
    }

    /// Tokens size themselves from n so eight items never push the row wider.
    private var itemsRow: some View {
        let size = min(30, (contentWidth - 40 - CGFloat(n - 1) * 6) / CGFloat(n))
        return HStack(spacing: 6) {
            Text("items")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
            ForEach(0..<n, id: \.self) { i in
                token(i, size: size)
            }
            Spacer(minLength: 0)
        }
    }

    private func token(_ index: Int, size: CGFloat) -> some View {
        Circle()
            .fill(colors[index % colors.count])
            .frame(width: size, height: size)
            .overlay(
                Text("\(index + 1)")
                    .font(.system(size: size * 0.5, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            )
    }

    private var sampleList: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(result > generated.count ? "first \(generated.count) of \(result)" : "all \(result)")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6),
                                     count: gridColumns),
                      spacing: 6) {
                ForEach(0..<generated.count, id: \.self) { index in
                    comboCard(generated[index])
                }
            }
            .clipped()
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.gray.opacity(0.2)))
    }

    private func comboCard(_ combo: [Int]) -> some View {
        let ordered = mode != .combinations
        return HStack(spacing: 2) {
            ForEach(combo.indices, id: \.self) { i in
                token(combo[i], size: tokenSize)
                if ordered && i < combo.count - 1 {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 6, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 8)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 5)
        .background(RoundedRectangle(cornerRadius: 7).fill(Color(.tertiarySystemBackground)))
    }

    // MARK: - Metrics
    //
    // One column budget, one token size: a row is physically incapable of
    // exceeding its column, whatever n and k are.

    private var gridColumns: Int {
        switch k {
        case 1, 2: return 4
        case 3:    return 3
        case 4:    return 2
        default:   return 1
        }
    }

    private var maxDisplay: Int {
        switch k {
        case 1, 2: return 8
        case 3:    return 6
        case 4:    return 4
        default:   return 4
        }
    }

    private var tokenSize: CGFloat {
        let cols = CGFloat(gridColumns)
        let columnWidth = (contentWidth - (cols - 1) * 6) / cols
        let arrow: CGFloat = mode == .combinations ? 0 : 8
        let gaps = CGFloat(k - 1) * (2 + arrow)
        return max(9, min(22, (columnWidth - 8 - gaps) / CGFloat(k)))
    }

    // MARK: - Enumeration (capped: full lists run to tens of thousands)

    private func regenerate() {
        generated = enumerateFirst(maxDisplay)
    }

    private func enumerateFirst(_ limit: Int) -> [[Int]] {
        var out: [[Int]] = []
        var current: [Int] = []

        switch mode {
        case .permutations:
            var used = Array(repeating: false, count: n)
            func walk() {
                if out.count >= limit { return }
                if current.count == k { out.append(current); return }
                for i in 0..<n where !used[i] {
                    if out.count >= limit { return }
                    used[i] = true
                    current.append(i)
                    walk()
                    current.removeLast()
                    used[i] = false
                }
            }
            walk()

        case .combinations:
            func walk(_ start: Int) {
                if out.count >= limit { return }
                if current.count == k { out.append(current); return }
                for i in start..<n {
                    if out.count >= limit { return }
                    current.append(i)
                    walk(i + 1)
                    current.removeLast()
                }
            }
            walk(0)

        case .repetition:
            func walk() {
                if out.count >= limit { return }
                if current.count == k { out.append(current); return }
                for i in 0..<n {
                    if out.count >= limit { return }
                    current.append(i)
                    walk()
                    current.removeLast()
                }
            }
            walk()
        }
        return out
    }

    // MARK: - Arithmetic

    private func permutations(_ n: Int, _ k: Int) -> Int {
        guard k >= 0, k <= n else { return 0 }
        return (0..<k).reduce(1) { $0 * (n - $1) }
    }

    private func combinations(_ n: Int, _ k: Int) -> Int {
        guard k >= 0, k <= n else { return 0 }
        return permutations(n, k) / factorial(k)
    }

    private func power(_ n: Int, _ k: Int) -> Int {
        (0..<k).reduce(1) { acc, _ in acc * n }
    }

    private func factorial(_ n: Int) -> Int {
        guard n > 1 else { return 1 }
        return (1...n).reduce(1, *)
    }
}

#Preview {
    CombinatoricsView()
}
