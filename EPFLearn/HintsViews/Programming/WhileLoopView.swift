//
//  WhileLoopView.swift
//  EPFLearn
//
//  A while loop is three questions, and this view answers them separately for
//  every step:
//    • GUARD    — is the condition true right now, with the current values?
//    • INVARIANT— what stays true at every passage, and is therefore still
//                 true when the loop exits (that is what proves correctness).
//    • VARIANT  — which quantity strictly decreases in ℕ, and therefore
//                 forces termination. Collatz is included precisely because
//                 nobody knows its variant: the loop is not proven to stop.
//
//  A trace table fills up as you step, exactly the table asked for in exams.
//

import SwiftUI

// MARK: - Model

private struct WhileStep {
    let line: Int
    let note: String
    let guardText: String
    let guardValue: Bool
    let guardChecked: Bool
    let variant: String
    let vars: [(String, String)]
    let rows: [[String]]
    let iteration: Int
    let search: (lo: Int, hi: Int, mid: Int?)?
    let done: Bool
}

private enum WhileDemo: String, CaseIterable, Identifiable {
    case gcd, binarySearch, collatz
    var id: String { rawValue }

    var label: String {
        switch self {
        case .gcd: return "gcd"
        case .binarySearch: return "binary search"
        case .collatz: return "collatz"
        }
    }

    var accent: Color {
        switch self {
        case .gcd: return .blue
        case .binarySearch: return .teal
        case .collatz: return .pink
        }
    }

    var code: [String] {
        switch self {
        case .gcd:
            return [
                "while (b != 0) {",
                "    int t = b;",
                "    b = a % b;",
                "    a = t;",
                "}",
                "// gcd is in a",
            ]
        case .binarySearch:
            return [
                "int lo = 0, hi = n - 1;",
                "while (lo <= hi) {",
                "    int mid = (lo + hi) / 2;",
                "    if (a[mid] == x) return mid;",
                "    if (a[mid] < x) lo = mid + 1;",
                "    else            hi = mid - 1;",
                "}",
                "return -1;",
            ]
        case .collatz:
            return [
                "int steps = 0;",
                "while (n != 1) {",
                "    if (n % 2 == 0) n = n / 2;",
                "    else            n = 3 * n + 1;",
                "    steps++;",
                "}",
            ]
        }
    }

    var columns: [String] {
        switch self {
        case .gcd: return ["it.", "a", "b", "b != 0"]
        case .binarySearch: return ["it.", "lo", "hi", "mid", "a[mid]"]
        case .collatz: return ["it.", "n", "parity", "steps"]
        }
    }

    var invariant: String {
        switch self {
        case .gcd: return "gcd(a, b) never changes: replacing (a, b) by (b, a mod b) preserves the set of common divisors. So when b hits 0, a holds the answer."
        case .binarySearch: return "If x is in the array, then its index is inside [lo, hi]. Never violated — which is why returning −1 when the window becomes empty is a proof of absence, not a guess."
        case .collatz: return "None known. This is an open problem since 1937, verified by computer up to ~2^68 without a proof."
        }
    }

    var variantName: String {
        switch self {
        case .gcd: return "b"
        case .binarySearch: return "hi − lo + 1"
        case .collatz: return "unknown"
        }
    }

    var variantExplain: String {
        switch self {
        case .gcd: return "b is a natural number and a mod b < b, so b strictly decreases at each turn: it must reach 0. Termination is guaranteed in O(log min(a,b)) turns."
        case .binarySearch: return "The window size is at least halved at each turn, so it reaches 0 after ⌈log₂ n⌉ turns at most. This is why searching a million sorted items costs 20 comparisons."
        case .collatz: return "No decreasing measure is known, so nothing proves this loop terminates for every n. A loop without a variant is a loop you cannot certify — even if it always stopped in your tests."
        }
    }
}

// MARK: - View

struct WhileLoopView: View {

    @State private var demo: WhileDemo = .gcd
    @State private var index = 0
    @State private var a: Double = 48
    @State private var b: Double = 18
    @State private var target: Double = 23
    @State private var n: Double = 7

    private let sorted = [2, 5, 8, 12, 16, 23, 38, 56]
    private var accent: Color { demo.accent }

    private var steps: [WhileStep] {
        switch demo {
        case .gcd: return Self.gcdTrace(Int(a), Int(b))
        case .binarySearch: return Self.searchTrace(sorted, Int(target))
        case .collatz: return Self.collatzTrace(Int(n))
        }
    }
    private var step: WhileStep { steps[min(index, steps.count - 1)] }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                VizTitle(title: "While loops",
                         subtitle: "Guard · invariant · variant — the three things a loop is made of.",
                         accent: accent)

                Picker("Demo", selection: $demo) {
                    ForEach(WhileDemo.allCases) { d in Text(d.label).tag(d) }
                }
                .pickerStyle(.segmented)
                .onChange(of: demo) { _ in index = 0 }

                inputPanel

                VizPanel { CodePane(lines: demo.code, activeLine: step.line, accent: accent) }

                VizPanel { StepPlayer(index: $index, count: steps.count, accent: accent) }

                StepNote(text: step.note, accent: accent,
                         icon: step.done ? "flag.checkered" : "arrow.turn.down.right")

                guardPanel

                if demo == .binarySearch { arrayPanel }

                varsPanel
                tablePanel
                terminationPanel
            }
            .padding(18)
        }
        .background(Color(.systemGroupedBackground))
        .animation(.spring(duration: 0.28), value: index)
    }

    // MARK: Inputs

    @ViewBuilder
    private var inputPanel: some View {
        VizPanel(title: "input", accent: accent) {
            switch demo {
            case .gcd:
                VStack(alignment: .leading, spacing: 8) {
                    slider(title: "a = \(Int(a))", value: $a, range: 1...120)
                    slider(title: "b = \(Int(b))", value: $b, range: 0...120)
                }
            case .binarySearch:
                VStack(alignment: .leading, spacing: 8) {
                    slider(title: "x = \(Int(target))", value: $target, range: 0...60)
                    Text(sorted.contains(Int(target))
                         ? "x is in the array"
                         : "x is NOT in the array — watch the window shrink to nothing")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            case .collatz:
                slider(title: "n = \(Int(n))", value: $n, range: 2...60)
            }
        }
    }

    private func slider(title: String, value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundStyle(accent)
            Slider(value: value, in: range, step: 1)
                .tint(accent)
                .onChange(of: value.wrappedValue) { _ in index = 0 }
        }
    }

    // MARK: Guard

    private var guardPanel: some View {
        VizPanel(title: "guard", accent: accent) {
            HStack {
                Text(step.guardText)
                    .font(.system(size: 14, design: .monospaced))
                Spacer()
                if step.guardChecked {
                    VerdictPill(text: step.guardValue ? "true → enter body" : "false → exit loop",
                                ok: step.guardValue)
                } else {
                    Text("not evaluated yet")
                        .font(.system(size: 11)).foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: Array (binary search)

    private var arrayPanel: some View {
        VizPanel(title: "search window", accent: accent) {
            HStack(spacing: 4) {
                ForEach(Array(sorted.enumerated()), id: \.offset) { k, v in
                    let s = step.search
                    let inWindow = s.map { k >= $0.lo && k <= $0.hi } ?? true
                    let isMid = s?.mid == k
                    VStack(spacing: 2) {
                        Text("\(v)")
                            .font(.system(size: 12, weight: isMid ? .bold : .regular, design: .monospaced))
                            .foregroundStyle(isMid ? .white : (inWindow ? .primary : .secondary.opacity(0.4)))
                            .frame(maxWidth: .infinity, minHeight: 32)
                            .background(RoundedRectangle(cornerRadius: 6)
                                .fill(isMid ? accent : (inWindow ? accent.opacity(0.16) : Color.secondary.opacity(0.06))))
                        Text("\(k)").font(.system(size: 9, design: .monospaced)).foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    // MARK: Variables

    private var varsPanel: some View {
        HStack(spacing: 10) {
            ForEach(Array(step.vars.enumerated()), id: \.offset) { _, v in
                VarChip(name: v.0, value: v.1, color: accent, highlighted: true)
            }
        }
    }

    // MARK: Trace table

    private var tablePanel: some View {
        VizPanel(title: "trace table", accent: accent) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(demo.columns, id: \.self) { c in
                        Text(c)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 5)

                if step.rows.isEmpty {
                    Text("no iteration completed yet")
                        .font(.system(size: 11)).foregroundStyle(.secondary)
                        .padding(.vertical, 6)
                }

                ForEach(Array(step.rows.enumerated()), id: \.offset) { r, row in
                    HStack(spacing: 0) {
                        ForEach(Array(row.enumerated()), id: \.offset) { _, cell in
                            Text(cell)
                                .font(.system(size: 12, design: .monospaced))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.vertical, 5)
                    .background(RoundedRectangle(cornerRadius: 6)
                        .fill(r == step.rows.count - 1 ? accent.opacity(0.16) : .clear))
                }
            }
        }
    }

    // MARK: Termination

    private var terminationPanel: some View {
        VStack(spacing: 12) {
            VizPanel(title: "invariant", accent: accent) {
                Text(demo.invariant)
                    .font(.system(size: 13))
                    .fixedSize(horizontal: false, vertical: true)
            }
            VizPanel(title: "variant — why it stops", accent: demo == .collatz ? .red : accent) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(demo.variantName)
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundStyle(demo == .collatz ? .red : accent)
                        Spacer()
                        Text(step.variant)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(demo == .collatz ? .red : accent)
                            .contentTransition(.numericText())
                    }
                    Text(demo.variantExplain)
                        .font(.system(size: 13))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    // MARK: - Traces

    private static func gcdTrace(_ a0: Int, _ b0: Int) -> [WhileStep] {
        var steps: [WhileStep] = []
        var rows: [[String]] = []
        var a = a0, b = b0, it = 0

        func emit(_ line: Int, _ note: String, guardChecked: Bool, guardValue: Bool, done: Bool = false) {
            steps.append(WhileStep(line: line, note: note,
                                   guardText: "b != 0   →   \(b) != 0",
                                   guardValue: guardValue, guardChecked: guardChecked,
                                   variant: "\(b)",
                                   vars: [("a", "\(a)"), ("b", "\(b)")],
                                   rows: rows, iteration: it, search: nil, done: done))
        }

        emit(-1, "Start with a = \(a), b = \(b). The loop will keep replacing the pair by (b, a mod b).", guardChecked: false, guardValue: b != 0)

        var safety = 0
        while b != 0 && safety < 60 {
            safety += 1
            it += 1
            emit(0, "Guard checked BEFORE the body: b = \(b) ≠ 0, so we run one more turn (turn \(it)).", guardChecked: true, guardValue: true)
            let t = b
            let newB = a % b
            emit(1, "t saves the old b = \(b); it will become the new a.", guardChecked: true, guardValue: true)
            let oldA = a, oldB = b
            b = newB
            emit(2, "b = a mod b = \(oldA) mod \(oldB) = \(newB). The remainder is strictly smaller than the divisor — this is exactly the variant decreasing.", guardChecked: true, guardValue: true)
            a = t
            rows.append(["\(it)", "\(a)", "\(b)", b != 0 ? "true" : "false"])
            emit(3, "a = \(a). The pair (\(oldA), \(oldB)) has become (\(a), \(b)) with the same gcd.", guardChecked: true, guardValue: true)
        }

        emit(0, "b = 0 → the guard is false, the body is skipped and the loop exits. The invariant says gcd(a, b) = gcd(a, 0) = a, so gcd(\(a0), \(b0)) = \(a).", guardChecked: true, guardValue: false, done: true)
        return steps
    }

    private static func searchTrace(_ arr: [Int], _ x: Int) -> [WhileStep] {
        var steps: [WhileStep] = []
        var rows: [[String]] = []
        var lo = 0, hi = arr.count - 1, it = 0

        func emit(_ line: Int, _ note: String, mid: Int?, guardChecked: Bool, guardValue: Bool, done: Bool = false) {
            steps.append(WhileStep(line: line, note: note,
                                   guardText: "lo <= hi   →   \(lo) <= \(hi)",
                                   guardValue: guardValue, guardChecked: guardChecked,
                                   variant: "\(max(hi - lo + 1, 0))",
                                   vars: [("lo", "\(lo)"), ("hi", "\(hi)"), ("mid", mid.map(String.init) ?? "—")],
                                   rows: rows, iteration: it, search: (lo, hi, mid), done: done))
        }

        emit(0, "The window starts as the whole array: lo = 0, hi = \(hi). Looking for x = \(x).", mid: nil, guardChecked: false, guardValue: lo <= hi)

        while lo <= hi {
            it += 1
            emit(1, "lo ≤ hi: the window still contains \(hi - lo + 1) candidate(s), so the search continues.", mid: nil, guardChecked: true, guardValue: true)
            let mid = (lo + hi) / 2
            emit(2, "mid = (\(lo) + \(hi)) / 2 = \(mid) — integer division, so mid leans left. a[\(mid)] = \(arr[mid]).", mid: mid, guardChecked: true, guardValue: true)
            rows.append(["\(it)", "\(lo)", "\(hi)", "\(mid)", "\(arr[mid])"])

            if arr[mid] == x {
                emit(3, "a[\(mid)] = \(x): found at index \(mid), after \(it) comparison(s) instead of up to \(arr.count) with a linear scan.", mid: mid, guardChecked: true, guardValue: true, done: true)
                return steps
            }
            if arr[mid] < x {
                let old = lo
                lo = mid + 1
                emit(4, "a[\(mid)] = \(arr[mid]) < \(x). The array is sorted, so everything left of mid is too small: lo jumps from \(old) to \(lo) and half the candidates disappear at once.", mid: mid, guardChecked: true, guardValue: true)
            } else {
                let old = hi
                hi = mid - 1
                emit(5, "a[\(mid)] = \(arr[mid]) > \(x): everything right of mid is too big, hi drops from \(old) to \(hi).", mid: mid, guardChecked: true, guardValue: true)
            }
        }

        emit(7, "lo > hi: the window is empty. The invariant guaranteed that x could only be inside it, so x = \(x) is definitely absent — return −1. \(it) comparisons were enough to prove absence.", mid: nil, guardChecked: true, guardValue: false, done: true)
        return steps
    }

    private static func collatzTrace(_ n0: Int) -> [WhileStep] {
        var steps: [WhileStep] = []
        var rows: [[String]] = []
        var n = n0, count = 0, it = 0
        var peak = n0

        func emit(_ line: Int, _ note: String, guardChecked: Bool, guardValue: Bool, done: Bool = false) {
            steps.append(WhileStep(line: line, note: note,
                                   guardText: "n != 1   →   \(n) != 1",
                                   guardValue: guardValue, guardChecked: guardChecked,
                                   variant: "?",
                                   vars: [("n", "\(n)"), ("steps", "\(count)"), ("peak", "\(peak)")],
                                   rows: rows, iteration: it, search: nil, done: done))
        }

        emit(0, "Start at n = \(n). Halve when even, 3n+1 when odd, until n reaches 1 — if it ever does.", guardChecked: false, guardValue: n != 1)

        var safety = 0
        while n != 1 && safety < 200 {
            safety += 1
            it += 1
            emit(1, "n = \(n) ≠ 1 → one more turn.", guardChecked: true, guardValue: true)
            let even = n % 2 == 0
            let old = n
            n = even ? n / 2 : 3 * n + 1
            peak = max(peak, n)
            count += 1
            rows.append(["\(it)", "\(n)", even ? "even" : "odd", "\(count)"])
            emit(even ? 2 : 3,
                 even ? "\(old) is even → n = \(old)/2 = \(n). This turn made n smaller."
                      : "\(old) is odd → n = 3×\(old)+1 = \(n). This turn made n BIGGER: no quantity here is decreasing monotonically, which is exactly why no termination proof exists.",
                 guardChecked: true, guardValue: true)
        }

        emit(1, "n = 1 → the loop exits after \(count) steps, having climbed as high as \(peak) on the way. It worked for \(n0), and for every number ever tested — but «tested» is not «proved».",
             guardChecked: true, guardValue: false, done: true)
        return steps
    }
}

#Preview {
    WhileLoopView()
}
