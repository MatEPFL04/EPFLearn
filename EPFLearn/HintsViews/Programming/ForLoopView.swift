//
//  ForLoopView.swift
//  EPFLearn
//
//  One idea: the highlighted line IS the story. The header line lights up on
//  every check and every increment, the body line only when a pass happens.
//
//  In the nested mode the highlight bounces back to the inner header on each
//  j++ and only occasionally up to the outer header: the inner loop spins,
//  the outer one crawls.
//

import SwiftUI

struct ForLoopView: View {

    enum Mode: String, CaseIterable {
        case single = "one loop"
        case nested = "nested"
    }

    @State private var mode: Mode = .single
    @State private var step = 0

    // for (int i = from; i < to; i += by)
    @State private var from = 0
    @State private var to = 4
    @State private var by = 1

    @State private var outer = 2
    @State private var inner = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                PBHeader("For Loop")
                Picker("", selection: $mode) {
                    ForEach(Mode.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .onChange(of: mode) { reset() }
            }

            if mode == .single {
                VStack(spacing: 5) {
                    PBScrub(label: "start i", value: $from, range: 0...8, accent: .cyan) { reset() }
                    PBScrub(label: "run while i <", value: $to, range: 0...10, accent: .green) { reset() }
                    PBScrub(label: "step i +=", value: $by, range: 1...4, accent: PB.num) { reset() }
                }
            } else {
                VStack(spacing: 5) {
                    PBScrub(label: "outer i <", value: $outer, range: 1...4, accent: .cyan) { reset() }
                    PBScrub(label: "inner j <", value: $inner, range: 1...4, accent: PB.num) { reset() }
                }
            }

            PBAdaptive {
                mode == .single ? AnyView(singleStage) : AnyView(nestedStage)
            } code: {
                PBCodePane(lines: paneLines,
                           current: mode == .single ? singleFrame.line : nestedFrame.line,
                           accent: .green)
                    .pbViewport()
            }

            PBStepper(step: $step, total: total, accent: .green)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground))
    }

    private func reset() { step = 0 }

    private var total: Int {
        mode == .single ? singleFrames.count - 1 : nestedFrames.count - 1
    }

    private var paneLines: [PBCodePane.Line] {
        if mode == .single {
            return singleCode.indices.map { idx in
                var l = PBCodePane.Line(code: singleCode[idx])
                if idx == 1, let c = singleFrame.cond {
                    l.badge = PBBadge(text: c ? "true" : "false", color: c ? .green : .pink)
                }
                return l
            }
        }
        let fr = nestedFrame
        return nestedCode.indices.map { idx in
            var l = PBCodePane.Line(code: nestedCode[idx])
            if idx == 0, let i = fr.i { l.badge = PBBadge(text: "i=\(i)", color: .cyan) }
            if idx == 1, let j = fr.j { l.badge = PBBadge(text: "j=\(j)", color: PB.num) }
            return l
        }
    }

    // MARK: - One loop

    private var singleCode: [String] {
        ["int c = 0;",
         "for (int i = \(from); i < \(to); i += \(by)) {",
         "    c = c + 1;",
         "}"]
    }

    private struct Frame {
        let line: Int
        let i: Int?
        let cond: Bool?
        let passes: Int
        let note: String
    }

    /// Every check and every increment lands back on line 1, the header.
    private var singleFrames: [Frame] {
        var f: [Frame] = [Frame(line: -1, i: nil, cond: nil, passes: 0, note: "drag the step slider to run")]
        f.append(Frame(line: 0, i: nil, cond: nil, passes: 0, note: "c = 0"))
        var i = from, passes = 0, guardCount = 0
        while guardCount < 40 {
            guardCount += 1
            let cond = i < to
            f.append(Frame(line: 1, i: i, cond: cond, passes: passes,
                           note: passes == 0 && !cond
                             ? "\(i) < \(to) is false already: the body never runs"
                             : "check \(i) < \(to) → \(cond)"))
            if !cond { break }
            passes += 1
            f.append(Frame(line: 2, i: i, cond: nil, passes: passes, note: "pass \(passes)"))
            i += by
            f.append(Frame(line: 1, i: i, cond: nil, passes: passes,
                           note: "back to the header: i += \(by) → \(i)"))
        }
        f.append(Frame(line: 3, i: i, cond: nil, passes: passes,
                       note: "\(passes) pass\(passes == 1 ? "" : "es"), \(passes + 1) checks"))
        return f
    }

    private var singleFrame: Frame { singleFrames[min(step, singleFrames.count - 1)] }

    private var visitedIs: [Int] {
        var out: [Int] = []
        var i = from
        while i < to, out.count < 40 { out.append(i); i += by }
        return out
    }

    private var singleStage: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                PBChip(label: "i", value: singleFrame.i.map(String.init) ?? "·",
                       color: .cyan, hot: singleFrame.line == 1)
                PBChip(label: "passes", value: "\(singleFrame.passes)", color: .green, hot: true)
                Spacer(minLength: 0)
            }

            // One tile per value i takes; filled as the body actually runs.
            HStack(spacing: 5) {
                if visitedIs.isEmpty {
                    Text("no value of i satisfies i < \(to)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.primary.opacity(0.4))
                } else {
                    ForEach(visitedIs.indices, id: \.self) { k in
                        Text("\(visitedIs[k])")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(k < singleFrame.passes ? .black : .primary.opacity(0.3))
                            .frame(width: 26, height: 26)
                            .background(RoundedRectangle(cornerRadius: 6)
                                .fill(k < singleFrame.passes ? Color.green : Color.primary.opacity(0.07)))
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .padding(10)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .topLeading)
        .pbViewport()
        .overlay(alignment: .bottomLeading) { PBNote(text: singleFrame.note).padding(7) }
        .animation(.spring(duration: 0.22), value: step)
    }

    // MARK: - Nested loops

    private var nestedCode: [String] {
        ["for (int i = 0; i < \(outer); i++) {",
         "    for (int j = 0; j < \(inner); j++) {",
         "        print(i, j);",
         "    }",
         "}"]
    }

    private struct NFrame {
        let line: Int
        let i: Int?
        let j: Int?
        let runs: Int
        let note: String
    }

    /// The highlight walks: outer header (i set) → inner header (j set) →
    /// body → inner header (j++) → body … → inner header (j fails) → outer
    /// header (i++). That bouncing is the whole lesson.
    private var nestedFrames: [NFrame] {
        var f: [NFrame] = [NFrame(line: -1, i: nil, j: nil, runs: 0, note: "drag the step slider to run")]
        var runs = 0
        for i in 0..<outer {
            f.append(NFrame(line: 0, i: i, j: nil, runs: runs,
                            note: i == 0 ? "outer starts: i = 0" : "outer advances: i = \(i)"))
            for j in 0..<inner {
                f.append(NFrame(line: 1, i: i, j: j, runs: runs,
                                note: j == 0 ? "inner restarts from j = 0" : "inner advances: j = \(j)"))
                runs += 1
                f.append(NFrame(line: 2, i: i, j: j, runs: runs, note: "body run \(runs)"))
            }
            f.append(NFrame(line: 1, i: i, j: inner, runs: runs,
                            note: "j = \(inner) fails j < \(inner): inner loop ends"))
        }
        f.append(NFrame(line: 4, i: nil, j: nil, runs: runs,
                        note: "\(outer) outer passes × \(inner) inner = \(runs)"))
        return f
    }

    private var nestedFrame: NFrame { nestedFrames[min(step, nestedFrames.count - 1)] }

    private var nestedStage: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                PBChip(label: "i", value: nestedFrame.i.map(String.init) ?? "·", color: .cyan,
                       hot: nestedFrame.line == 0)
                PBChip(label: "j", value: nestedFrame.j.map(String.init) ?? "·", color: PB.num,
                       hot: nestedFrame.line == 1)
                PBChip(label: "runs", value: "\(nestedFrame.runs)", color: .green, hot: true)
                Spacer(minLength: 0)
            }

            // One row per outer pass, one cell per inner pass.
            VStack(alignment: .leading, spacing: 4) {
                ForEach(0..<outer, id: \.self) { i in
                    HStack(spacing: 4) {
                        Text("i=\(i)")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.cyan.opacity(nestedFrame.i == i ? 1 : 0.4))
                            .frame(width: 26, alignment: .leading)
                        ForEach(0..<inner, id: \.self) { j in
                            let done = i * inner + j < nestedFrame.runs
                            let now = nestedFrame.i == i && nestedFrame.j == j && nestedFrame.line == 2
                            RoundedRectangle(cornerRadius: 5)
                                .fill(done ? Color.green.opacity(now ? 1 : 0.4) : Color.primary.opacity(0.07))
                                .frame(height: 20)
                        }
                    }
                }
            }
        }
        .padding(10)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .topLeading)
        .pbViewport()
        .overlay(alignment: .bottomLeading) { PBNote(text: nestedFrame.note).padding(7) }
        .animation(.spring(duration: 0.2), value: step)
    }
}

#Preview { ForLoopView().preferredColorScheme(.dark) }
