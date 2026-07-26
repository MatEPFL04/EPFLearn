//
//  FunctionView.swift
//  EPFLearn
//
//  What this view teaches:
//    1. A call is not a jump: it PUSHES a frame holding its own parameters and
//       locals. Returning POPS it. That is why locals are private per call.
//    2. Recursion is nothing special — just several frames of the same
//       function alive at once. The view shows them stacked, with the caller
//       frozen on the line it is waiting on.
//    3. fib shows the same subcall being recomputed again and again: the
//       call counter makes the exponential blow-up (and the case for
//       memoization) tangible.
//    4. swap() shows that Java passes arguments BY VALUE: the callee mutates
//       its own copies and the caller sees nothing.
//
//  The whole trace is produced by really running the algorithm below, with a
//  simulated stack — no hand-written step table.
//

import SwiftUI

// MARK: - Model

private struct CallFrame: Identifiable {
    let id: Int               // unique frame id (call order)
    let name: String
    let args: [(String, String)]
    var locals: [(String, String)] = []
    var line: Int             // line this frame is currently on
    var returning: String? = nil
}

private struct FnStep {
    let frames: [CallFrame]
    let line: Int
    let note: String
    let output: [String]
    let calls: Int
    var popped: Bool = false
}

private enum FnDemo: String, CaseIterable, Identifiable {
    case factorial, fibonacci, swap
    var id: String { rawValue }

    var label: String {
        switch self {
        case .factorial: return "fact(n)"
        case .fibonacci: return "fib(n)"
        case .swap:      return "swap(a,b)"
        }
    }

    var accent: Color {
        switch self {
        case .factorial: return .purple
        case .fibonacci: return .indigo
        case .swap:      return .orange
        }
    }

    var code: [String] {
        switch self {
        case .factorial:
            return [
                "static int fact(int n) {",
                "    if (n <= 1) return 1;",
                "    int r = n * fact(n - 1);",
                "    return r;",
                "}",
            ]
        case .fibonacci:
            return [
                "static int fib(int n) {",
                "    if (n < 2) return n;",
                "    return fib(n-1) + fib(n-2);",
                "}",
            ]
        case .swap:
            return [
                "static void swap(int x, int y) {",
                "    int t = x;",
                "    x = y;",
                "    y = t;",
                "}",
                "",
                "int a = 1, b = 2;",
                "swap(a, b);",
                "// a and b are UNCHANGED",
            ]
        }
    }

    var moral: String {
        switch self {
        case .factorial:
            return "Each frame owns its own n and r. The caller is frozen on line 3 until the callee returns — that is the whole mechanism of recursion."
        case .fibonacci:
            return "fib(n) calls itself twice, so the number of calls roughly doubles at each level: ~2^n frames created for a value computable in n steps. Memoizing collapses it to linear."
        case .swap:
            return "Java passes arguments by value: x and y are copies. Swapping copies changes nothing outside. To swap for real, return the pair, mutate an array/object, or use a wrapper."
        }
    }
}

// MARK: - View

struct FunctionView: View {

    @State private var demo: FnDemo = .factorial
    @State private var n: Double = 4
    @State private var index = 0

    private var accent: Color { demo.accent }
    private var steps: [FnStep] { Self.buildTrace(demo: demo, n: Int(n)) }
    private var step: FnStep { steps[min(index, steps.count - 1)] }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                VizTitle(title: "Functions & the call stack",
                         subtitle: "A call pushes a frame. A return pops it.",
                         accent: accent)

                Picker("Demo", selection: $demo) {
                    ForEach(FnDemo.allCases) { d in Text(d.label).tag(d) }
                }
                .pickerStyle(.segmented)
                .onChange(of: demo) { _ in index = 0 }

                if demo != .swap {
                    VizPanel(title: "input", accent: accent) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("n = \(Int(n))")
                                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                .foregroundStyle(accent)
                            Slider(value: $n, in: 1...(demo == .fibonacci ? 6 : 6), step: 1)
                                .tint(accent)
                                .onChange(of: n) { _ in index = 0 }
                        }
                    }
                }

                VizPanel { CodePane(lines: demo.code, activeLine: step.line, accent: accent) }

                VizPanel { StepPlayer(index: $index, count: steps.count, accent: accent) }

                StepNote(text: step.note, accent: accent,
                         icon: step.popped ? "arrow.uturn.left" : "arrow.turn.down.right")

                stackPanel

                if demo == .fibonacci { costPanel }
                if !step.output.isEmpty || demo == .swap {
                    VizPanel(title: "output", accent: .green) {
                        OutputConsole(lines: step.output)
                    }
                }

                VizPanel(title: "what to remember", accent: accent) {
                    Text(demo.moral)
                        .font(.system(size: 13))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(18)
        }
        .background(Color(.systemGroupedBackground))
        .animation(.spring(duration: 0.28), value: index)
    }

    // MARK: Call stack

    private var stackPanel: some View {
        VizPanel(title: "call stack  ·  depth \(step.frames.count)", accent: accent) {
            VStack(spacing: 6) {
                if step.frames.isEmpty {
                    Text("stack empty")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                ForEach(step.frames.reversed()) { frame in
                    frameRow(frame, isTop: frame.id == step.frames.last?.id)
                }
            }
        }
    }

    private func frameRow(_ f: CallFrame, isTop: Bool) -> some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text("\(f.name)(\(f.args.map { "\($0.0)=\($0.1)" }.joined(separator: ", ")))")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    if isTop {
                        Text("running")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5).padding(.vertical, 2)
                            .background(Capsule().fill(accent))
                    } else {
                        Text("waiting on line \(f.line + 1)")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                if !f.locals.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(Array(f.locals.enumerated()), id: \.offset) { _, l in
                            Text("\(l.0) = \(l.1)")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 5).padding(.vertical, 2)
                                .background(RoundedRectangle(cornerRadius: 4).fill(Color.secondary.opacity(0.12)))
                        }
                    }
                }
            }
            Spacer(minLength: 4)
            if let r = f.returning {
                Text("↩ \(r)")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundStyle(.green)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 9)
                .fill(accent.opacity(isTop ? 0.22 : 0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .stroke(accent.opacity(isTop ? 0.8 : 0.15), lineWidth: 1)
        )
    }

    // MARK: Cost panel (fib only)

    private var costPanel: some View {
        let calls = step.calls
        let total = steps.last?.calls ?? 1
        return VizPanel(title: "cost", accent: accent) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    VarChip(name: "calls so far", value: "\(calls)", color: accent, highlighted: true)
                    VarChip(name: "total calls", value: "\(total)", color: .secondary)
                    VarChip(name: "with memo", value: "\(max(Int(n) + 1, 1))", color: .green)
                }
                ProgressView(value: Double(calls), total: Double(max(total, 1)))
                    .tint(accent)
            }
        }
    }

    // MARK: - Trace builders

    private static func buildTrace(demo: FnDemo, n: Int) -> [FnStep] {
        switch demo {
        case .factorial: return factorialTrace(n)
        case .fibonacci: return fibTrace(n)
        case .swap:      return swapTrace()
        }
    }

    private static func factorialTrace(_ n0: Int) -> [FnStep] {
        var steps: [FnStep] = []
        var stack: [CallFrame] = []
        var nextID = 0
        var calls = 0

        func emit(_ line: Int, _ note: String, popped: Bool = false) {
            steps.append(FnStep(frames: stack, line: line, note: note,
                                output: [], calls: calls, popped: popped))
        }

        @discardableResult
        func fact(_ n: Int) -> Int {
            calls += 1
            let id = nextID; nextID += 1
            stack.append(CallFrame(id: id, name: "fact", args: [("n", "\(n)")], line: 0))
            emit(0, "Call fact(\(n)): a new frame is pushed with its own copy of n.")

            if !stack.isEmpty { stack[stack.count - 1].line = 1 }
            if n <= 1 {
                emit(1, "n = \(n) ≤ 1 → base case reached. This is what stops the recursion; without it the stack would grow until StackOverflowError.")
                stack[stack.count - 1].returning = "1"
                emit(1, "fact(\(n)) returns 1 and its frame is popped.", popped: true)
                stack.removeLast()
                return 1
            }

            emit(1, "n = \(n) > 1 → not the base case, keep going.")
            stack[stack.count - 1].line = 2
            emit(2, "To compute n × fact(n−1) the machine must know fact(\(n - 1)) first. This frame freezes on line 3 and a new call starts.")

            let sub = fact(n - 1)

            let r = n * sub
            stack[stack.count - 1].locals = [("r", "\(r)")]
            emit(2, "fact(\(n - 1)) came back with \(sub). Execution resumes exactly where it stopped: r = \(n) × \(sub) = \(r).")
            stack[stack.count - 1].line = 3
            stack[stack.count - 1].returning = "\(r)"
            emit(3, "fact(\(n)) returns \(r), its frame is popped and its locals disappear.", popped: true)
            stack.removeLast()
            return r
        }

        emit(-1, "Nothing running yet. Press play, or step through manually.")
        let result = fact(max(n0, 1))
        steps.append(FnStep(frames: [], line: -1,
                            note: "Stack empty again: fact(\(n0)) = \(result). Every frame that was created has been destroyed, in reverse order.",
                            output: ["fact(\(n0)) = \(result)"], calls: calls, popped: true))
        return steps
    }

    private static func fibTrace(_ n0: Int) -> [FnStep] {
        var steps: [FnStep] = []
        var stack: [CallFrame] = []
        var nextID = 0
        var calls = 0
        var seen: [Int: Int] = [:]     // how many times fib(k) was computed

        func emit(_ line: Int, _ note: String, popped: Bool = false) {
            steps.append(FnStep(frames: stack, line: line, note: note,
                                output: [], calls: calls, popped: popped))
        }

        @discardableResult
        func fib(_ n: Int) -> Int {
            calls += 1
            seen[n, default: 0] += 1
            let id = nextID; nextID += 1
            stack.append(CallFrame(id: id, name: "fib", args: [("n", "\(n)")], line: 0))
            let repeated = seen[n]! > 1
            emit(0, repeated
                 ? "Call fib(\(n)) — again. This exact subproblem has already been solved \(seen[n]! - 1)× in this run, and the machine has no memory of it."
                 : "Call fib(\(n)): frame pushed.")

            stack[stack.count - 1].line = 1
            if n < 2 {
                stack[stack.count - 1].returning = "\(n)"
                emit(1, "n < 2 → base case, return \(n).", popped: true)
                stack.removeLast()
                return n
            }

            stack[stack.count - 1].line = 2
            emit(2, "Two recursive calls are needed. The left one, fib(\(n - 1)), goes first; fib(\(n - 2)) will not even start before the left subtree is fully finished.")
            let a = fib(n - 1)
            stack[stack.count - 1].locals = [("left", "\(a)")]
            emit(2, "Left branch returned \(a). Now the right one, fib(\(n - 2)).")
            let b = fib(n - 2)
            let r = a + b
            stack[stack.count - 1].locals = [("left", "\(a)"), ("right", "\(b)")]
            stack[stack.count - 1].returning = "\(r)"
            emit(2, "fib(\(n)) = \(a) + \(b) = \(r), frame popped.", popped: true)
            stack.removeLast()
            return r
        }

        emit(-1, "Nothing running yet.")
        let result = fib(max(n0, 1))
        let duplicated = seen.filter { $0.value > 1 }.count
        steps.append(FnStep(frames: [], line: -1,
                            note: "fib(\(n0)) = \(result) in \(calls) calls, while only \(n0 + 1) distinct subproblems exist — \(duplicated) of them were recomputed several times. Storing results (memoization) turns this into a linear algorithm.",
                            output: ["fib(\(n0)) = \(result)", "calls = \(calls)"],
                            calls: calls, popped: true))
        return steps
    }

    private static func swapTrace() -> [FnStep] {
        var steps: [FnStep] = []
        func s(_ frames: [CallFrame], _ line: Int, _ note: String, _ out: [String] = [], popped: Bool = false) {
            steps.append(FnStep(frames: frames, line: line, note: note, output: out, calls: 0, popped: popped))
        }

        let main0 = CallFrame(id: 0, name: "main", args: [], locals: [("a", "1"), ("b", "2")], line: 6)
        var mainWaiting = main0; mainWaiting.line = 7

        s([main0], 6, "main declares a = 1 and b = 2 in its own frame.", ["a = 1, b = 2"])

        var callee = CallFrame(id: 1, name: "swap", args: [("x", "1"), ("y", "2")], line: 0)
        s([mainWaiting, callee], 0,
          "swap(a, b) pushes a frame whose parameters x and y are COPIES of the values 1 and 2. The link with a and b is already broken here.",
          ["a = 1, b = 2"])

        callee.locals = [("t", "1")]; callee.line = 1
        s([mainWaiting, callee], 1, "t receives the copy x = 1.", ["a = 1, b = 2"])

        callee = CallFrame(id: 1, name: "swap", args: [("x", "2"), ("y", "2")], locals: [("t", "1")], line: 2)
        s([mainWaiting, callee], 2, "x becomes 2. Only the copy inside the frame changes.", ["a = 1, b = 2"])

        callee = CallFrame(id: 1, name: "swap", args: [("x", "2"), ("y", "1")], locals: [("t", "1")], line: 3)
        s([mainWaiting, callee], 3, "y becomes 1: inside swap, the exchange really happened.", ["a = 1, b = 2"])

        s([main0], 8,
          "The frame is popped and x, y, t vanish with it. Back in main, a is still 1 and b is still 2 — the swap was performed on values that no longer exist.",
          ["a = 1, b = 2", "swap had no effect"], popped: true)
        return steps
    }
}

#Preview {
    FunctionView()
}
