//
//  ForLoopView.swift
//  EPFLearn
//
//  One idea: watch the loop's variables change on every executed line.
//  init sets i, the condition is checked each pass, the body updates sum,
//  and i += 2 advances - the two boxes tell the whole story.
//

import SwiftUI
import Combine

struct ForLoopView: View {
    @State private var step = 0
    @State private var playing = false
    private let timer = Timer.publish(every: 0.7, on: .main, in: .common).autoconnect()

    private let code = [
        "int sum = 0;",
        "for (int i = 1; i <= 5; i += 2) {",
        "    sum += i;",
        "}",
        "print(sum);"
    ]

    private struct Frame {
        let line: Int
        let i: Int?
        let sum: Int?
        let cond: Bool?
        let bodyHot: Bool
    }

    private let frames: [Frame] = [
        Frame(line: -1, i: nil, sum: nil, cond: nil,  bodyHot: false),
        Frame(line: 0,  i: nil, sum: 0,   cond: nil,  bodyHot: false),
        Frame(line: 1,  i: 1,   sum: 0,   cond: true, bodyHot: false),
        Frame(line: 2,  i: 1,   sum: 1,   cond: nil,  bodyHot: true),
        Frame(line: 1,  i: 3,   sum: 1,   cond: true, bodyHot: false),
        Frame(line: 2,  i: 3,   sum: 4,   cond: nil,  bodyHot: true),
        Frame(line: 1,  i: 5,   sum: 4,   cond: true, bodyHot: false),
        Frame(line: 2,  i: 5,   sum: 9,   cond: nil,  bodyHot: true),
        Frame(line: 1,  i: 7,   sum: 9,   cond: false,bodyHot: false),
        Frame(line: 4,  i: 7,   sum: 9,   cond: nil,  bodyHot: false)
    ]

    private var total: Int { frames.count - 1 }
    private var fr: Frame { frames[min(step, total)] }

    // Completed iterations, for the history strip.
    private let iters: [(i: Int, sum: Int)] = [(1, 1), (3, 4), (5, 9)]
    private var bodiesDone: Int { [3, 5, 7].filter { $0 <= step }.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PBHeader("For Loop")

            PBAdaptive {
                stage
            } code: {
                PBCodePane(lines: paneLines, current: fr.line, accent: .green)
                    .pbViewport()
            }

            PBStepper(step: $step, total: total, accent: .green, playing: $playing)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground))
        .onReceive(timer) { _ in
            guard playing else { return }
            if step < total { withAnimation(.spring(duration: 0.3)) { step += 1 } }
            else { playing = false }
        }
    }

    private var paneLines: [PBCodePane.Line] {
        code.indices.map { idx in
            var l = PBCodePane.Line(code: code[idx])
            if idx == 1, let c = fr.cond {
                l.badge = PBBadge(text: c ? "true" : "false", color: c ? .green : .pink)
            }
            return l
        }
    }

    // MARK: - Stage: displayed variables

    private var stage: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                varBox(name: "i", value: fr.i, color: .cyan,
                       hot: fr.line == 1)
                varBox(name: "sum", value: fr.sum, color: .green,
                       hot: fr.bodyHot)
            }

            history
        }
        .padding(16)
        .frame(minHeight: 175, alignment: .top)
        .pbViewport()
        .animation(.spring(duration: 0.3), value: step)
    }

    private func varBox(name: String, value: Int?, color: Color, hot: Bool) -> some View {
        VStack(spacing: 6) {
            Text(name)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(value.map(String.init) ?? "·")
                .font(.system(size: 40, weight: .black, design: .monospaced))
                .foregroundColor(value == nil ? .primary.opacity(0.2) : .primary)
                .contentTransition(.numericText())
                .frame(width: 108, height: 76)
                .background(RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(value == nil ? 0.05 : 0.16)))
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(color.opacity(hot ? 1 : (value == nil ? 0.2 : 0.45)),
                                  style: StrokeStyle(lineWidth: hot ? 2.5 : 1,
                                                     dash: value == nil ? [4] : [])))
                .shadow(color: hot ? color.opacity(0.7) : .clear, radius: 10)
        }
    }

    private var history: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("SUM AFTER EACH PASS")
                .font(.system(size: 8, weight: .bold)).tracking(0.8)
                .foregroundColor(.primary.opacity(0.35))
            HStack(spacing: 8) {
                ForEach(0..<iters.count, id: \.self) { k in
                    let done = k < bodiesDone
                    HStack(spacing: 5) {
                        Text("i=\(iters[k].i)")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(done ? .cyan : .primary.opacity(0.25))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.primary.opacity(done ? 0.4 : 0.15))
                        Text("\(iters[k].sum)")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(done ? .green : .primary.opacity(0.25))
                    }
                    .padding(.horizontal, 9).padding(.vertical, 6)
                    .background(RoundedRectangle(cornerRadius: 9)
                        .fill(done ? Color.green.opacity(0.12) : Color.primary.opacity(0.04)))
                    .overlay(RoundedRectangle(cornerRadius: 9)
                        .strokeBorder(done ? Color.green.opacity(0.35) : .primary.opacity(0.08),
                                      lineWidth: 1))
                }
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview { ForLoopView().preferredColorScheme(.dark) }
