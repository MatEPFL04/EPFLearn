//
//  WhileLoopView.swift
//  EPFLearn
//
//  One idea: while checks its condition BEFORE every pass, and only the body
//  can make that condition become false.
//    · halve      - v is halved until the check fails (checks = passes + 1,
//                   and with v = 1 the body never runs at all)
//    · count up   - the loop stops ON the first value that fails the test,
//                   which is one more than the last value it accepted
//    · no update  - the body never touches x, so the loop never ends
//

import SwiftUI

struct WhileLoopView: View {

    enum Mode: String, CaseIterable {
        case halve = "v = v / 2"
        case countUp = "c = c + 1"
        case noUpdate = "no update"
    }

    @State private var mode: Mode = .halve
    @State private var startN = 24
    @State private var target = 3
    @State private var step = 0

    private var accent: Color { mode == .noUpdate ? .pink : .cyan }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            PBHeader("While Loop")

            Picker("", selection: $mode) {
                ForEach(Mode.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .onChange(of: mode) { _ in step = 0 }

            switch mode {
            case .halve:
                PBScrub(label: "n", value: $startN, range: 1...64, accent: .cyan) { step = 0 }
            case .countUp:
                PBScrub(label: "stop below", value: $target, range: 0...8, accent: .cyan) { step = 0 }
            case .noUpdate:
                EmptyView()
            }

            PBAdaptive {
                stage
            } code: {
                PBCodePane(lines: paneLines, current: fr.line, accent: accent)
                    .pbViewport()
            }

            PBStepper(step: $step, total: total, accent: accent)

        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Code

    private var code: [String] {
        switch mode {
        case .halve:
            return [
                "int v = \(startN);",
                "int k = 0;",
                "while (v > 1) {",
                "    v = v / 2;",
                "    k++;",
                "}"
            ]
        case .countUp:
            return [
                "int c = 0;",
                "",
                "while (c < \(target)) {",
                "    c = c + 1;",
                "}"
            ]
        case .noUpdate:
            return [
                "int x = 4;",
                "",
                "while (x > 0) {",
                "    print(x);",
                "    // x is never touched",
                "}"
            ]
        }
    }

    // MARK: - Frames

    private struct Frame {
        let line: Int
        let check: Bool?
        let value: Int      // n, or count
        let passes: Int
        let note: String
    }

    private var frames: [Frame] {
        switch mode {
        case .halve:    return halveFrames
        case .countUp:  return countUpFrames
        case .noUpdate: return noUpdateFrames
        }
    }

    private var halveFrames: [Frame] {
        var f = [Frame(line: -1, check: nil, value: startN, passes: 0,
                       note: "drag the step slider to run")]
        f.append(Frame(line: 0, check: nil, value: startN, passes: 0, note: "v = \(startN)"))
        f.append(Frame(line: 1, check: nil, value: startN, passes: 0, note: "k = 0"))
        var n = startN, s = 0
        while n > 1 {
            f.append(Frame(line: 2, check: true, value: n, passes: s,
                           note: "\(n) > 1 → true"))
            n /= 2
            f.append(Frame(line: 3, check: nil, value: n, passes: s, note: "v = \(n)"))
            s += 1
            f.append(Frame(line: 4, check: nil, value: n, passes: s, note: "k = \(s)"))
        }
        f.append(Frame(line: 2, check: false, value: n, passes: s,
                       note: "\(n) > 1 → false, exit"))
        f.append(Frame(line: -1, check: nil, value: n, passes: s,
                       note: s == 0
                         ? "body never ran, k = 0"
                         : "\(s) passes, \(s + 1) checks"))
        return f
    }

    private var countUpFrames: [Frame] {
        var f = [Frame(line: -1, check: nil, value: 0, passes: 0,
                       note: "drag the step slider to run")]
        f.append(Frame(line: 0, check: nil, value: 0, passes: 0, note: "c = 0"))
        var c = 0, s = 0
        while c < target {
            f.append(Frame(line: 2, check: true, value: c, passes: s,
                           note: "\(c) < \(target) → true"))
            c += 1
            s += 1
            f.append(Frame(line: 3, check: nil, value: c, passes: s, note: "c = \(c)"))
        }
        f.append(Frame(line: 2, check: false, value: c, passes: s,
                       note: "\(c) < \(target) → false, exit"))
        f.append(Frame(line: -1, check: nil, value: c, passes: s,
                       note: s == 0
                         ? "0 passes, c stays 0"
                         : "\(s) passes, exits on \(c)"))
        return f
    }

    /// Deliberately finite: enough passes to make the pattern obvious, then a
    /// frame that says out loud that this repeats forever.
    private var noUpdateFrames: [Frame] {
        var f = [Frame(line: -1, check: nil, value: 4, passes: 0,
                       note: "drag the step slider to run")]
        f.append(Frame(line: 0, check: nil, value: 4, passes: 0, note: "x = 4"))
        for s in 0..<4 {
            f.append(Frame(line: 2, check: true, value: 4, passes: s,
                           note: "4 > 0 → true"))
            f.append(Frame(line: 3, check: nil, value: 4, passes: s + 1,
                           note: "prints 4, x untouched"))
        }
        f.append(Frame(line: 2, check: true, value: 4, passes: 4,
                       note: "x never changes → never ends"))
        return f
    }

    private var total: Int { frames.count - 1 }
    private var fr: Frame { frames[min(step, total)] }
    private var checks: Int { frames.prefix(step + 1).filter { $0.check != nil }.count }
    private var done: Bool { step == total }

    private var paneLines: [PBCodePane.Line] {
        code.indices.map { i in
            var line = PBCodePane.Line(code: code[i])
            if i == 2, let c = fr.check {
                line.badge = PBBadge(text: c ? "true" : "false", color: c ? .green : .pink)
            }
            return line
        }
    }

    // MARK: - Stage

    @ViewBuilder
    private var stage: some View {
        switch mode {
        case .halve:    halveStage
        case .countUp:  countUpStage
        case .noUpdate: noUpdateStage
        }
    }

    private var chips: some View {
        HStack(spacing: 5) {
            PBChip(label: mode == .countUp ? "c" : "v", value: "\(fr.value)",
                   color: .cyan, hot: fr.line == 3)
            PBChip(label: mode == .halve ? "k" : "passes", value: "\(fr.passes)",
                   color: .green, hot: fr.line == 4 || (mode != .halve && fr.line == 3))
            PBChip(label: "checks", value: mode == .noUpdate ? "∞" : "\(checks)", color: PB.num)
        }
        .padding(7)
    }

    private var trace: [Int] {
        var t = [startN]; var n = startN
        while n > 1 { n /= 2; t.append(n) }
        return t
    }

    private var halveStage: some View {
        let visible = Array(trace.prefix(fr.passes + 1))
        let maxN = CGFloat(max(startN, 1))
        return VStack(alignment: .leading, spacing: 6) {
            ForEach(visible.indices, id: \.self) { i in
                let v = visible[i]
                let isCurrent = i == visible.count - 1
                GeometryReader { geo in
                    HStack(spacing: 8) {
                        Capsule()
                            .fill(isCurrent
                                  ? AnyShapeStyle(LinearGradient(colors: [.cyan, .mint],
                                                                 startPoint: .leading, endPoint: .trailing))
                                  : AnyShapeStyle(Color.cyan.opacity(0.25)))
                            .frame(width: max(10, (geo.size.width - 44) * CGFloat(v) / maxN))
                            .shadow(color: isCurrent ? .cyan.opacity(0.5) : .clear, radius: 6)
                        Text("\(v)").font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(isCurrent ? .primary : .primary.opacity(0.4))
                            .contentTransition(.numericText())
                    }
                }
                .frame(height: 16)
            }
        }
        .padding(.horizontal, 10).padding(.top, 34).padding(.bottom, 10)
        .frame(minHeight: 116, alignment: .topLeading)
        .pbViewport()
        .overlay(alignment: .topTrailing) { chips }
        .overlay(alignment: .bottomLeading) { PBNote(text: fr.note).padding(7) }
        .animation(.spring(duration: 0.3), value: step)
    }

    /// A number line from 0 to target + 1: the exit value sits just past the
    /// last accepted one, which is the whole point of the mode.
    private var countUpStage: some View {
        let lastAccepted = max(target - 1, 0)
        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                ForEach(0...max(target, 1), id: \.self) { v in
                    let reached = v <= fr.value
                    let isNow = v == fr.value
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(isNow ? Color.cyan
                                        : (reached ? Color.cyan.opacity(0.3) : Color.primary.opacity(0.07)))
                            .frame(height: 42)
                            .overlay(
                                Text("\(v)")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(isNow ? .black : .primary.opacity(reached ? 0.8 : 0.35))
                            )
                            .shadow(color: isNow ? .cyan.opacity(0.6) : .clear, radius: 8)
                        Text(v < target ? "< \(target)" : "stop")
                            .font(.system(size: 8, weight: .semibold, design: .monospaced))
                            .foregroundColor(v < target ? .green.opacity(0.7) : .pink.opacity(0.8))
                    }
                }
            }

            if done {
                Text(target == 0
                     ? "false from the start: 0 passes"
                     : "last accepted \(lastAccepted)  ·  exits on \(fr.value)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 10).padding(.top, 36).padding(.bottom, 26)
        .frame(maxWidth: .infinity, minHeight: 116, alignment: .topLeading)
        .pbViewport()
        .overlay(alignment: .topTrailing) { chips }
        .overlay(alignment: .bottomLeading) { PBNote(text: fr.note).padding(7) }
        .animation(.spring(duration: 0.3), value: step)
    }

    private var noUpdateStage: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CONSOLE")
                .font(.system(size: 8, weight: .bold)).tracking(0.8)
                .foregroundColor(.primary.opacity(0.35))

            VStack(alignment: .leading, spacing: 3) {
                ForEach(0..<fr.passes, id: \.self) { _ in
                    Text("4")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.pink)
                }
                if step >= total {
                    Text("4\n4\n…")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.pink.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                Text("x")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.5))
                Text("4")
                    .font(.system(size: 20, weight: .black, design: .monospaced))
                    .foregroundColor(.pink)
                Text("never changes")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.4))
                Spacer(minLength: 0)
                if step >= total {
                    Text("∞")
                        .font(.system(size: 26, weight: .black))
                        .foregroundColor(.pink)
                }
            }
        }
        .padding(.horizontal, 10).padding(.top, 36).padding(.bottom, 26)
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
        .pbViewport()
        .overlay(alignment: .topTrailing) { chips }
        .overlay(alignment: .bottomLeading) { PBNote(text: fr.note).padding(7) }
        .animation(.spring(duration: 0.3), value: step)
    }
}

#Preview { WhileLoopView() }
