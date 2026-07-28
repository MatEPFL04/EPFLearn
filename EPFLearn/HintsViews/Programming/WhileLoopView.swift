//
//  WhileLoopView.swift
//  EPFLearn
//
//  One idea: while checks its condition BEFORE every pass.
//  n is halved until the check fails - checks = passes + 1,
//  and with n = 1 the body never runs at all.
//

import SwiftUI

struct WhileLoopView: View {
    @State private var startN = 24
    @State private var step = 0

    private var code: [String] {
        [
            "int n = \(startN);",
            "int steps = 0;",
            "while (n > 1) {",
            "    n = n / 2;",
            "    steps++;",
            "}"
        ]
    }

    private var trace: [Int] {
        var t = [startN]; var n = startN
        while n > 1 { n /= 2; t.append(n) }
        return t
    }

    private struct Frame { let line: Int; let check: Bool?; let n: Int; let steps: Int }

    private var frames: [Frame] {
        var f = [Frame(line: -1, check: nil, n: startN, steps: 0)]
        f.append(Frame(line: 0, check: nil, n: startN, steps: 0))
        f.append(Frame(line: 1, check: nil, n: startN, steps: 0))
        var n = startN; var s = 0
        while n > 1 {
            f.append(Frame(line: 2, check: true, n: n, steps: s))
            n /= 2
            f.append(Frame(line: 3, check: nil, n: n, steps: s))
            s += 1
            f.append(Frame(line: 4, check: nil, n: n, steps: s))
        }
        f.append(Frame(line: 2, check: false, n: n, steps: s))
        f.append(Frame(line: -1, check: nil, n: n, steps: s))
        return f
    }

    private var total: Int { frames.count - 1 }
    private var fr: Frame { frames[min(step, total)] }
    private var checks: Int { frames.prefix(step + 1).filter { $0.check != nil }.count }
    private var done: Bool { step == total }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                PBHeader("While Loop")

                PBScrub(label: "n", value: $startN, range: 1...64, accent: .cyan) { step = 0 }

                PBAdaptive {
                    stage
                } code: {
                    PBCodePane(lines: paneLines, current: fr.line, accent: .cyan)
                        .pbViewport()
                }

                PBStepper(step: $step, total: total, accent: .cyan)
            }
            .padding(14)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var paneLines: [PBCodePane.Line] {
        code.indices.map { i in
            var line = PBCodePane.Line(code: code[i])
            if i == 2, let c = fr.check {
                line.badge = PBBadge(text: c ? "true" : "false", color: c ? .green : .pink)
            }
            return line
        }
    }

    private var stage: some View {
        let visible = Array(trace.prefix(fr.steps + 1))
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
                            .foregroundColor(isCurrent ? .white : .white.opacity(0.4))
                            .contentTransition(.numericText())
                    }
                }
                .frame(height: 16)
            }
        }
        .padding(.horizontal, 14).padding(.top, 40).padding(.bottom, 14)
        .frame(minHeight: 170, alignment: .topLeading)
        .pbViewport()
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 5) {
                PBChip(label: "n", value: "\(fr.n)", color: .cyan, hot: fr.line == 3)
                PBChip(label: "steps", value: "\(fr.steps)", color: .green, hot: fr.line == 4)
                PBChip(label: "checks", value: "\(checks)", color: PB.num)
            }
            .padding(9)
        }
        .overlay(alignment: .bottomLeading) {
            if done {
                PBNote(text: fr.steps == 0
                       ? "check failed first - body never ran"
                       : "\(fr.steps) passes, \(fr.steps + 1) checks")
                    .padding(9)
            }
        }
        .animation(.spring(duration: 0.3), value: step)
    }
}

#Preview { WhileLoopView() }
