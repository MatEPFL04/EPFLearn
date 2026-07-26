//
//  ProgramVizKit.swift
//  EPFLearn
//
//  Shared building blocks for the "Programming basics" visualizations.
//
//  Design rule for every programming view: the view NEVER hard-codes a
//  "step number → highlighted line" table. Instead each view builds a full
//  execution trace ([Step]) by actually running the algorithm once, and the
//  UI is a pure function of trace[index]. Scrubbing, playing and stepping
//  backwards then come for free, and the animation can never desync from the
//  semantics of the program being taught.
//

import SwiftUI
import Combine
// MARK: - Panel

struct VizPanel<Content: View>: View {
    var title: String? = nil
    var accent: Color = .secondary
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title {
                Text(title.uppercased())
                    .font(.caption2.weight(.bold))
                    .tracking(0.9)
                    .foregroundStyle(accent)
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemGroupedBackground)))
    }
}

// MARK: - Code pane

/// Source listing with a highlighted current line and optional inline badges.
struct CodePane: View {
    let lines: [String]
    var activeLine: Int? = nil
    var accent: Color = .blue
    /// line index → short badge shown on the right (e.g. "×3", "skipped")
    var annotations: [Int: String] = [:]
    /// line indices drawn dimmed (dead / not reachable in this run)
    var faded: Set<Int> = []
    var showNumbers: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(Array(lines.enumerated()), id: \.offset) { i, line in
                row(index: i, text: line)
            }
        }
    }

    private func row(index i: Int, text: String) -> some View {
        let active = (i == activeLine)
        let textColor: Color = active ? .white
            : (faded.contains(i) ? Color.secondary.opacity(0.45) : .primary)

        return HStack(alignment: .firstTextBaseline, spacing: 8) {
            if showNumbers {
                Text("\(i + 1)")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(active ? Color.white.opacity(0.7) : Color.secondary.opacity(0.6))
                    .frame(width: 14, alignment: .trailing)
            }
            Text(text.isEmpty ? " " : text)
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(textColor)
            Spacer(minLength: 4)
            if let note = annotations[i] {
                Text(note)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(active ? .white : accent)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(active ? Color.white.opacity(0.22) : accent.opacity(0.15)))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(RoundedRectangle(cornerRadius: 6).fill(active ? accent : Color.clear))
    }
}

// MARK: - Step player (play / pause / scrub)

struct StepPlayer: View {
    @Binding var index: Int
    let count: Int
    var accent: Color = .blue

    @State private var playing = false
    @State private var tick = 0
    @State private var speedIndex = 1

    private let speeds: [Double] = [0.5, 1, 2]
    private let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()

    private var last: Int { max(count - 1, 0) }
    private var ticksPerStep: Int { max(Int((1.0 / speeds[speedIndex]) / 0.15), 1) }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 18) {
                control("backward.end.fill") { playing = false; index = 0 }
                control("chevron.left") { playing = false; index = max(index - 1, 0) }

                Button {
                    if index >= last { index = 0 }
                    playing.toggle()
                    tick = 0
                } label: {
                    Image(systemName: playing ? "pause.fill" : "play.fill")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(Circle().fill(accent))
                }
                .buttonStyle(.plain)

                control("chevron.right") { playing = false; index = min(index + 1, last) }
                control("forward.end.fill") { playing = false; index = last }
            }

            HStack(spacing: 10) {
                Text("step \(index)/\(last)")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .frame(width: 78, alignment: .leading)

                Slider(
                    value: Binding(
                        get: { Double(index) },
                        set: { playing = false; index = Int($0.rounded()) }
                    ),
                    in: 0...Double(max(last, 1)),
                    step: 1
                )
                .tint(accent)

                Menu("\(speeds[speedIndex], specifier: "%g")×") {
                    ForEach(Array(speeds.enumerated()), id: \.offset) { i, s in
                        Button("\(s, specifier: "%g")×") { speedIndex = i }
                    }
                }
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .frame(width: 38)
            }
        }
        .onReceive(timer) { _ in
            guard playing else { return }
            tick += 1
            guard tick >= ticksPerStep else { return }
            tick = 0
            if index >= last { playing = false } else { index += 1 }
        }
        .onChange(of: count) { _ in
            playing = false
            index = min(index, max(count - 1, 0))
        }
    }

    private func control(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(accent)
                .frame(width: 30, height: 30)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Console

struct OutputConsole: View {
    let lines: [String]
    var accent: Color = .green
    var minLines: Int = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            ForEach(0..<max(lines.count, minLines), id: \.self) { i in
                HStack(spacing: 6) {
                    Text(">")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.secondary.opacity(0.5))
                    Text(i < lines.count ? lines[i] : " ")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(i < lines.count ? accent : .clear)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.28)))
    }
}

// MARK: - Small pieces

/// The commentary attached to the current step. Colored, not grey: it is the
/// single most important text of the screen.
struct StepNote: View {
    let text: String
    var accent: Color = .blue
    var icon: String = "arrow.turn.down.right"

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(accent)
                .padding(.top, 1)
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(accent.opacity(0.12)))
    }
}

struct VarChip: View {
    let name: String
    let value: String
    var type: String? = nil
    var color: Color = .blue
    var highlighted: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Text(name)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.secondary)
                if let type {
                    Text(type)
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(color.opacity(0.8))
                }
            }
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(highlighted ? 0.28 : 0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(highlighted ? 0.9 : 0), lineWidth: 1.5)
        )
    }
}

struct VizTitle: View {
    let title: String
    let subtitle: String
    var accent: Color = .blue

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.title2.bold())
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundStyle(accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Boolean verdict pill used by several views.
struct VerdictPill: View {
    let text: String
    let ok: Bool
    var trueColor: Color = .green
    var falseColor: Color = .red

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: ok ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 11, weight: .bold))
            Text(text).font(.system(size: 12, weight: .semibold, design: .monospaced))
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .foregroundStyle(ok ? trueColor : falseColor)
        .background(Capsule().fill((ok ? trueColor : falseColor).opacity(0.16)))
    }
}
